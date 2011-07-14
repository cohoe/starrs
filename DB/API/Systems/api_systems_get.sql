/* API - get_system_types
	1) Return all available system types
*/
CREATE OR REPLACE FUNCTION "api"."get_system_types"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "type" FROM "systems"."device_types" ORDER BY "type" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_types"() IS 'Get a list of all available system types';

/* API - get_operating_systems
	1) Return all available operating systems
*/
CREATE OR REPLACE FUNCTION "api"."get_operating_systems"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "name" FROM "systems"."os" ORDER BY "name" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_operating_systems"() IS 'Get a list of all available system types';

/* API - get_system_owner */
CREATE OR REPLACE FUNCTION "api"."get_system_owner"(input_system text) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_owner"(text) IS 'Easily get the owner of a system';

/* API - get_interface_address_owner */
CREATE OR REPLACE FUNCTION "api"."get_interface_address_owner"(input_address inet) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "owner" FROM "systems"."interface_addresses"
		JOIN "systems"."interfaces" ON "systems"."interface_addresses"."mac" = "systems"."interfaces"."mac"
		JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
		WHERE "address" = '10.21.50.1');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_address_owner"(inet) IS 'Get the owner of an existing interface address';

/* API - get_system_interface_addresses */
CREATE OR REPLACE FUNCTION "api"."get_system_interface_addresses"(input_mac macaddr) RETURNS SETOF "systems"."interface_address_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "mac","address","family","config","class","isprimary","comment","renew_date","date_created","date_modified","last_modifier"
			FROM "systems"."interface_addresses" WHERE "mac" = input_mac ORDER BY family(address),address ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_interface_addresses"(macaddr) IS 'Get all interface addresses on a specified MAC';

/* API - get_system_interfaces */
CREATE OR REPLACE FUNCTION "api"."get_system_interfaces"(input_system_name text) RETURNS SETOF "systems"."interface_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "system_name","mac","name","comment","date_created","date_modified","last_modifier"
			FROM "systems"."interfaces" WHERE "system_name" = input_system_name  ORDER BY mac ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_interfaces"(text) IS 'Get all interface information on a system';

/* API - get_system_interface_data */
CREATE OR REPLACE FUNCTION "api"."get_system_interface_data"(input_mac macaddr) RETURNS SETOF "systems"."interface_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "system_name","mac","name","comment","date_created","date_modified","last_modifier"
			FROM "systems"."interfaces" WHERE "mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_interface_data"(macaddr) IS 'Get all interface information on a system for a specific interface';

/* API - get_system_data */
CREATE OR REPLACE FUNCTION "api"."get_system_data"(input_system_name text) RETURNS SETOF "systems"."system_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "system_name","type","os_name","owner","comment","renew_date","date_created","date_modified","last_modifier"
			FROM "systems"."systems" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';

/* API - get_systems */
CREATE OR REPLACE FUNCTION "api"."get_systems"(input_username text) RETURNS SETOF text AS $$
	BEGIN
		IF input_username IS NULL THEN
			RETURN QUERY (SELECT "system_name" FROM "systems"."systems" ORDER BY "system_name" ASC);
		ELSE
			RETURN QUERY (SELECT "system_name" FROM "systems"."systems" WHERE "owner" = input_username ORDER BY "system_name" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_systems"(text) IS 'Get all system names owned by a given user';

/* API - get_os_family_distribution */
CREATE OR REPLACE FUNCTION "api"."get_os_family_distribution"() RETURNS SETOF "systems"."os_family_distribution" AS $$
	BEGIN
		RETURN QUERY(SELECT "family",count("family")::integer,round(count("family")::numeric/(SELECT count(*)::numeric FROM "systems"."systems")*100,0)::integer AS "percentage"
		FROM "systems"."systems" 
		JOIN "systems"."os" ON "systems"."systems"."os_name" = "systems"."os"."name" 
		GROUP BY "family");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_os_family_distribution"() IS 'Get fun statistics on registered operating system families';

/* API - get_os_distribution */
CREATE OR REPLACE FUNCTION "api"."get_os_distribution"() RETURNS SETOF "systems"."os_distribution" AS $$
	BEGIN
		RETURN QUERY(SELECT "os_name",count("os_name")::integer,round(count("os_name")::numeric/(SELECT count(*)::numeric FROM "systems"."systems")*100,0)::integer AS "percentage"
		FROM "systems"."systems" 
		JOIN "systems"."os" ON "systems"."systems"."os_name" = "systems"."os"."name" 
		GROUP BY "os_name");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_os_distribution"() IS 'Get fun statistics on registered operating systems';

