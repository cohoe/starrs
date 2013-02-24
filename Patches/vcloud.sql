DROP TABLE IF EXISTS "management"."group_settings" CASCADE;
DROP FUNCTION IF EXISTS "api"."remove_group_settings"(text);

CREATE TABLE "management"."group_settings" (
"group" TEXT NOT NULL,
"privilege" TEXT NOT NULL DEFAULT 'USER',
"provider" TEXT NOT NULL,
"hostname" TEXT,
"id" TEXT,
"username" TEXT,
"password" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
PRIMARY KEY ("group")
)
WITHOUT OIDS;
COMMENT ON TABLE "management"."group_settings" IS 'Authentication and provider settings for groups';

ALTER TABLE "management"."group_settings" ADD CONSTRAINT "fk_group_settings_group" FOREIGN KEY ("group") REFERENCES "management"."groups"("group") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION "api"."create_group_settings"(input_group text, input_provider text, input_id text, input_hostname text, input_username text, input_password text, input_privilege text) RETURNS SETOF "management"."group_settings" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can create group provider settings';
		END IF;

		-- Check provider
		IF input_provider !~* 'local|vcloud|ldap|ad' THEN
			RAISE EXCEPTION 'Invalid provider given: %',input_provider;
		END IF;

		-- NULLs
		IF input_provider ~* 'vcloud|ldap|ad' THEN
			IF input_hostname IS NULL THEN
				RAISE EXCEPTION 'Need to give a hostname.';
			END IF;
			IF input_id IS NULL THEN
				RAISE EXCEPTION 'Need to give an ID.';
			END IF;
			IF input_username IS NULL THEN
				RAISE EXCEPTION 'Need to give a username.';
			END IF;
			if input_password IS NULL THEN
				RAISE EXCEPTION 'Need to give a password.';
			END IF;
		END IF;

		-- Check privilege level
		IF input_privilege!~* 'USER|ADMIN' THEN
			RAISE EXCEPTION 'Invalid privilege given: %',input_privilege;
		END IF;

		INSERT INTO "management"."group_settings" ("group","provider","id","hostname","username","password","privilege")
		VALUES (input_group, input_provider, input_id,input_hostname, input_username, input_password, input_privilege);

		--PERFORM api.syslog('create_group_settings:"'||input_group||'","'||input_provider||'","'||input_id||'","'||input_hostname||'","'||input_username||'","'||input_privilege||'"');
		RETURN QUERY (SELECT * FROM "management"."group_settings" WHERE "group" = input_group);

	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_group_settings"(text, text, text, text, text, text, text) IS 'Create authentication settings';

CREATE OR REPLACE FUNCTION "api"."modify_group_settings"(input_old_group text, input_field text, input_new_value text) RETURNS SETOF "management"."group_settings" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can create group provider settings';
		END IF;

		IF input_field !~* 'group|provider|id|hostname|username|password|privilege' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

          EXECUTE 'UPDATE "management"."group_settings" SET ' || quote_ident($2) || ' = $3,
          date_modified = localtimestamp(0), last_modifier = api.get_current_user()
          WHERE "group" = $1'
          USING input_old_group, input_field, input_new_value;

          PERFORM api.syslog('modify_group_settings:"'||input_old_group||'","'||input_field||'","'||input_new_value||'"');
          IF input_field ~* 'group' THEN
               RETURN QUERY (SELECT * FROM "management"."group_settings" WHERE "group" = input_new_value);
          ELSE
               RETURN QUERY (SELECT * FROM "management"."group_settings" WHERE "group" = input_old_group);
          END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_group_settings"(text, text, text) IS 'Modify group authentication and provider settings';

CREATE OR REPLACE FUNCTION "api"."remove_group_settings"(input_group text) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can remove group provider settings';
		END IF;

		DELETE FROM "management"."group_settings" WHERE "group" = input_group;

		PERFORM api.syslog('remove_group_settings:"'||input_group||'"');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_group_settings"(text) IS 'remove group authentication providers';

CREATE OR REPLACE FUNCTION "api"."get_group_settings"(input_group text) RETURNS SETOF "management"."group_settings" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can view group provider settings';
		END IF;

		-- return
		RETURN QUERY (SELECT * FROM "management"."group_settings" WHERE "group" = input_group);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_group_settings"(text) IS 'Get group settings';

DROP FUNCTION IF EXISTS "api"."get_ldap_group_members"(text, text, text, text);
CREATE OR REPLACE FUNCTION "api"."get_ldap_group_members"(text, text, text, text) RETURNS SETOF TEXT AS $$
	use strict;
	use warnings;
	use Net::LDAP;

	# Get the credentials
	my $hostname = $_[0] or die "Need to give a hostname";
	my $id= $_[1] or die "Need to give an ID";
	my $binddn = $_[2] or die "Need to give a username";
	my $password = $_[3] or die "Need to give a password";

	my $srv = Net::LDAP->new ($hostname) or die "Could not connect to LDAP server ($hostname)\n";
	my $mesg = $srv->bind($binddn,password=>$password) or die "Could not bind to LDAP server";

	my @members;

	my @dnparts = split(/,/, $id);
	my $filter = shift(@dnparts);
	my $base = join(",",@dnparts);


	$mesg = $srv->search(filter=>"($filter)",base=>$base);
	foreach my $entry ($mesg->entries) {
		my @vals = $entry->get_value('member');
		foreach my $val (@vals) {
			$val =~ s/^uid=(.*?),(.*?)$/$1/;
			push(@members, $val);
		}
	}

	return \@members;

$$ LANGUAGE 'plperlu';

CREATE OR REPLACE FUNCTION "api"."reload_group_members"(input_group text) RETURNS SETOF "management"."group_members" AS $$
	DECLARE
		MemberData RECORD;
		ReloadData RECORD;
		Settings RECORD;
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can reload group members';
		END IF;

		SELECT * INTO Settings FROM api.get_group_settings(input_group);

		IF (Settings."provider") !~* 'ldap|vcloud|ad' THEN
			RAISE EXCEPTION 'Cannot reload local group';
		END IF;

		FOR MemberData IN (SELECT * FROM api.get_group_members(input_group)) LOOP
			PERFORM api.remove_group_member(input_group, MemberData."user");
		END LOOP;

		IF Settings."provider" ~* 'LDAP' THEN
			FOR ReloadData IN (SELECT * FROM api.get_ldap_group_members(Settings."hostname", Settings."id", Settings."username", Settings."password")) LOOP
				PERFORM api.create_group_member(input_group, ReloadData.get_ldap_group_members, Settings."privilege");
			END LOOP;
		END IF;

		PERFORM api.syslog('reload_group_members:"'||input_group||'"');
		RETURN QUERY (SELECT * FROM api.get_group_members(input_group));
		
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION "api"."get_group_members"(input_group text) RETURNS SETOF "management"."group_members" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "management"."group_members" WHERE "group" = input_group ORDER BY "user");
	END;
$$ LANGUAGE 'plpgsql';

GRANT ALL PRIVILEGES ON "management"."group_settings" TO impulse_admin;
GRANT ALL PRIVILEGES ON "management"."group_settings" TO impulse_client;
