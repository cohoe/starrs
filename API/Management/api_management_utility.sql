/* api_management_utility
	1) validate_nospecial
	2) validate_name
	3) renew_system
	6) intialize
	7) deinitialize
	8) reset_database
	9) exec
*/

/* API - validate_nospecial */
CREATE OR REPLACE FUNCTION "api"."validate_nospecial"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9]*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."validate_nospecial"(text) IS 'Block all special characters';

/* API - validate_name */
CREATE OR REPLACE FUNCTION "api"."validate_name"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\:\_\/ ]*\-*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		IF input = '' THEN
			RAISE EXCEPTION 'Name cannot be blank';
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."validate_name"(text) IS 'Allow certain characters for names';

/* API - initialize
	1) Get level
	2) Create privilege table
	3) Populate privileges
	4) Set level
*/
CREATE OR REPLACE FUNCTION "api"."initialize"(input_username text) RETURNS TEXT AS $$
	DECLARE
		Level TEXT;
	BEGIN
		-- Get level
		SELECT api.get_ldap_user_level(input_username) INTO Level;
		--IF input_username ~* 'cohoe|clockfort|russ|dtyler|worr|benrr101' THEN
			--Level := 'ADMIN';
		--ELSE
			--Level := 'USER';
		--END IF;
		IF Level='NONE' THEN
			RAISE EXCEPTION 'Could not identify "%".',input_username;
		END IF;

		-- Create privilege table
		DROP TABLE IF EXISTS "user_privileges";

		CREATE TEMPORARY TABLE "user_privileges"
		(username text NOT NULL,privilege text NOT NULL,
		allow boolean NOT NULL DEFAULT false);

		-- Populate privileges
		INSERT INTO "user_privileges" VALUES (input_username,'USERNAME',TRUE);
		INSERT INTO "user_privileges" VALUES (input_username,'ADMIN',FALSE);
		INSERT INTO "user_privileges" VALUES (input_username,'PROGRAM',FALSE);
		INSERT INTO "user_privileges" VALUES (input_username,'USER',FALSE);
		ALTER TABLE "user_privileges" ALTER COLUMN "username" SET DEFAULT api.get_current_user();

		-- Set level
		UPDATE "user_privileges" SET "allow" = TRUE WHERE "privilege" = Level;

		PERFORM api.create_log_entry('API','INFO','User "'||input_username||'" ('||Level||') has successfully initialized.');
		RETURN 'Greetings '||lower(Level)||'!';
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."initialize"(text) IS 'Setup user access to the database';

/* API - deinitialize */
CREATE OR REPLACE FUNCTION "api"."deinitialize"() RETURNS VOID AS $$
	BEGIN
		DROP TABLE IF EXISTS "user_privileges";
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."deinitialize"() IS 'Reset user permissions to activate a new user';

/* API - exec */
CREATE OR REPLACE FUNCTION "api"."exec"(text) RETURNS VOID AS $$
	BEGIN
		EXECUTE $1;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."exec"(text) IS 'Execute a query in a plpgsql context';

/* API - change_username */
CREATE OR REPLACE FUNCTION "api"."change_username"(old_username text, new_username text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','Begin api.change_username');
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied to change username');
			RAISE EXCEPTION 'Only admins can change usernames';
		END IF;
		
		-- Perform update
		UPDATE "dhcp"."class_options" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dhcp"."range_options" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dhcp"."global_options" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dhcp"."classes" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dhcp"."subnet_options" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dhcp"."config_types" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."types" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."ns" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."ns" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."srv" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."srv" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."cname" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."cname" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."mx" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."mx" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."zones" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."zones" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."keys" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."keys" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."txt" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."txt" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."a" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "dns"."a" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "dns"."soa" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "ip"."range_uses" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "ip"."subnets" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "ip"."subnets" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "ip"."ranges" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "ip"."addresses" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "ip"."addresses" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "systems"."device_types" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "systems"."os_family" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "systems"."interface_addresses" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "systems"."systems" SET "owner" = new_username WHERE "owner" = old_username;
		UPDATE "systems"."systems" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "systems"."os" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "systems"."interfaces" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "systems"."type_family" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "network"."switchports" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "network"."switchport_types" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "management"."configuration" SET "last_modifier" = new_username WHERE "last_modifier" = old_username;
		UPDATE "management"."log_master" SET "user" = new_username WHERE "user" = old_username;
		PERFORM api.create_log_entry('API','INFO','Changed user '||old_username||' to '||new_username);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','End api.change_username');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."change_username"(text, text) IS 'Change all references to an old username to a new one';

/* API - validate_soa_contact */
CREATE OR REPLACE FUNCTION "api"."validate_soa_contact"(input text) RETURNS BOOLEAN AS $$
	DECLARE
		BadCrap TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\.]*\-*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		IF input = '' THEN
			RAISE EXCEPTION 'Contact cannot be blank';
		END IF;
		RETURN TRUE;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."validate_soa_contact"(text) IS 'Ensure that the SOA contact is properly formatted';

CREATE OR REPLACE FUNCTION "api"."clean_log"() RETURNS VOID AS $$
	BEGIN
		DELETE FROM "management"."log_master" WHERE "timestamp" < localtimestamp(0) - interval '1 month';
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."clean_log"() IS 'Remove all log entries older than a month';
