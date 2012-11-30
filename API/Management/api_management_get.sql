/* api_management_get.sql
	1) get_current_user
	2) get_current_user_level
	3) get_ldap_user_level
	4) get_site_configuration
*/

/* API - get_current_user_level */
CREATE OR REPLACE FUNCTION "api"."get_current_user_level"() RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "privilege"
		FROM "user_privileges"
		WHERE "allow" = TRUE
		AND "privilege" ~* '^admin|program|user$');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_current_user_level"() IS 'Get the level of the current session user';

CREATE OR REPLACE FUNCTION "api"."get_site_configuration_all"() RETURNS SETOF "management"."configuration" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "management"."configuration" ORDER BY "option" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_site_configuration_all"() IS 'Get all site configuration directives';

CREATE OR REPLACE FUNCTION "api"."get_search_data"() RETURNS SETOF "management"."search_data" AS $$
	BEGIN
		RETURN QUERY (SELECT
	"systems"."systems"."datacenter",
	(SELECT "zone" FROM "ip"."ranges" WHERE "name" =  "api"."get_address_range"("systems"."interface_addresses"."address")) AS "availability_zone",
	"systems"."systems"."system_name",
	"systems"."systems"."asset",
	"systems"."systems"."group",
	"systems"."systems"."platform_name",
	"systems"."interfaces"."mac",
	"systems"."interface_addresses"."address",
	"systems"."interface_addresses"."config",
	"systems"."systems"."owner" AS "system_owner",
	"systems"."systems"."last_modifier" AS "system_last_modifier",
	"api"."get_address_range"("systems"."interface_addresses"."address") AS "range",
	"dns"."a"."hostname",
	"dns"."cname"."alias",
	"dns"."srv"."alias",
	"dns"."a"."zone",
	"dns"."a"."owner" AS "dns_owner",
	"dns"."a"."last_modifier" AS "dns_last_modifier"
FROM 	"systems"."systems"
LEFT JOIN	"systems"."interfaces" ON "systems"."interfaces"."system_name" = "systems"."systems"."system_name"
LEFT JOIN	"systems"."interface_addresses" ON "systems"."interface_addresses"."mac" = "systems"."interfaces"."mac"
LEFT JOIN	"dns"."a" ON "dns"."a"."address" = "systems"."interface_addresses"."address"
LEFT JOIN	"dns"."cname" ON "dns"."cname"."address" = "systems"."interface_addresses"."address"
LEFT JOIN	"dns"."srv" ON "dns"."srv"."address" = "systems"."interface_addresses"."address"
ORDER BY "systems"."interface_addresses"."address","systems"."interfaces"."mac");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_search_data"() IS 'Get search data to parse';

CREATE OR REPLACE FUNCTION "api"."get_function_counts"(input_schema TEXT) RETURNS TABLE("function" TEXT, calls INTEGER) AS $$
	BEGIN
		RETURN QUERY(
			SELECT "information_schema"."routines"."routine_name"::text,"pg_stat_user_functions"."calls"::integer 
			FROM "information_schema"."routines" 
			LEFT JOIN "pg_stat_user_functions" ON "pg_stat_user_functions"."funcname" = "information_schema"."routines"."routine_name" 
			WHERE "information_schema"."routines"."routine_schema" = input_schema
		);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_function_counts"(TEXT) IS 'Get statistics on number of calls to each function in a schema';

CREATE OR REPLACE FUNCTION "api"."get_current_user_groups"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY(SELECT "group" FROM "management"."group_members" WHERE "user" = api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_current_user_groups"() IS 'Get the groups of the current user';

CREATE OR REPLACE FUNCTION "api"."get_group_admins"(input_group text) RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY(SELECT "user" FROM "management"."group_members" WHERE "group" = input_group AND "privilege" = 'ADMIN');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_group_admins"(text) IS 'Get a list of all admins for a group';

CREATE OR REPLACE FUNCTION "api"."get_system_permissions"(input_system_name text) RETURNS TABLE(read boolean, write boolean) AS $$
	DECLARE
		read BOOLEAN;
		write BOOLEAN;
		sysowner TEXT;
		sysgroup TEXT;
	BEGIN
		SELECT "owner","group" INTO sysowner, sysgroup
		FROM "systems"."systems"
		WHERE "system_name" = input_system_name;

		IF sysowner IS NULL THEN
			RAISE EXCEPTION 'System % not found!',input_system_name;
		END IF;
		
		IF sysgroup IN (SELECT * FROM api.get_current_user_groups()) THEN
			IF api.get_current_user() IN (SELECT * FROM api.get_group_admins(sysgroup)) THEN
				read := TRUE;
				write := TRUE;
			ELSE
				read := TRUE;
				write := FALSE;
			END IF;
		ELSE
			read := TRUE;
			write := FALSE;
		END IF;

		IF sysowner = api.get_current_user() THEN
			read := TRUE;
			write := TRUE;
			
		END IF;

		IF api.get_current_user_level() ~* 'ADMIN' THEN
			read := TRUE;
			write := TRUE;
		END IF;
		RETURN QUERY (SELECT read, write);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_permissions"(text) IS 'Get the current user permissions on a system';

CREATE OR REPLACE FUNCTION "api"."get_groups"() RETURNS SETOF "management"."groups" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "management"."groups" ORDER BY "group");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_groups"() IS 'Get all of the configured groups';

CREATE OR REPLACE FUNCTION "api"."get_group_members"(input_group text) RETURNS SETOF "management"."group_members" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "management"."group_members" WHERE "group" = input_group ORDER BY "user");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_group_members"(text) IS 'Get all members of a group';

CREATE OR REPLACE FUNCTION "api"."get_local_user_level"(input_user text) RETURNS TEXT AS $$
	BEGIN
		IF input_user = 'root' THEN
			RETURN 'admin';
		END IF;

		IF input_user IN (SELECT "user" FROM api.get_group_members(api.get_site_configuration('DEFAULT_LOCAL_ADMIN_GROUP'))) THEN
			RETURN 'ADMIN';
		END IF;

		IF input_user IN (SELECT "user" FROM "management"."group_members" JOIN "management"."groups" ON "management"."groups"."group" = "management"."group_members"."group" WHERE "management"."groups"."privilege" = 'USER') THEN
			RETURN 'USER';
		END IF;

		IF input_user IN (SELECT "user" FROM "management"."group_members" JOIN "management"."groups" ON "management"."groups"."group" = "management"."group_members"."group" WHERE "management"."groups"."privilege" = 'PROGRAM') THEN
			RETURN 'PROGRAM';
		END IF;
		
		IF input_user IN (SELECT "user" FROM api.get_group_members(api.get_site_configuration('DEFAULT_LOCAL_USER_GROUP'))) THEN
			RETURN 'USER';
		END IF;
		
		RETURN 'NONE';
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_local_user_level"(text) IS 'Get the users privilege level based on local tables';

CREATE OR REPLACE FUNCTION "api"."get_user_email"(input_user TEXT) RETURNS TEXT AS $$
	BEGIN
		IF api.get_site_configuration('USER_PRIVILEGE_SOURCE') ~* '^ad$' THEN
			RETURN api.get_ad_user_email(input_user);
		ELSE
			RETURN input_user||'@'||api.get_site_configuration('EMAIL_DOMAIN');
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_user_email"(text) IS 'Get the email address of a user';

CREATE OR REPLACE FUNCTION "api"."get_user_groups"(input_user text) RETURNS SETOF "management"."groups" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "management"."groups" WHERE "group" IN (
		SELECT "group" FROM "management"."group_members" WHERE "user" = input_user)
		ORDER BY "group"
		);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_user_groups"(text) IS 'Get all of the groups that a user belongs to';
