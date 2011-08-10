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
CREATE OR REPLACE FUNCTION "api"."get_systems"(input_username text) RETURNS SETOF "systems"."system_data" AS $$
	BEGIN
		IF input_username IS NULL THEN
			RETURN QUERY (SELECT "system_name","type","os_name","owner","comment","renew_date","date_created","date_modified","last_modifier"
			FROM "systems"."systems" ORDER BY "system_name" ASC);
		ELSE
			RETURN QUERY (SELECT "system_name","type","os_name","owner","comment","renew_date","date_created","date_modified","last_modifier"
			FROM "systems"."systems" WHERE "owner" = input_username ORDER BY "system_name" ASC);
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

/* API - get_interface_owner */
CREATE OR REPLACE FUNCTION "api"."get_interface_owner"(input_mac macaddr) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "owner" FROM "systems"."interfaces" 
			JOIN "systems"."systems" ON "systems"."interfaces"."system_name" = "systems"."systems"."system_name"
			WHERE "mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_owner"(macaddr) IS 'Get the owner of the system that contains the mac address';

/* API - get_interface_address_system */
CREATE OR REPLACE FUNCTION "api"."get_interface_address_system"(input_address inet) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "system_name" FROM "systems"."interface_addresses"
		JOIN "systems"."interfaces" ON "systems"."interface_addresses"."mac" = "systems"."interfaces"."mac"
		WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_address_system"(inet) IS 'Get the name of the system to which the given address is assigned';

/* API - get_system_interface_address */
CREATE OR REPLACE FUNCTION "api"."get_system_interface_address"(input_address inet) RETURNS SETOF "systems"."interface_address_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "mac","address","family","config","class","isprimary","comment","renew_date","date_created","date_modified","last_modifier"
		FROM "systems"."interface_addresses" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_interface_address"(inet) IS 'Get all interface address data for an address';

/* API - get_owned_interface_addresses */
CREATE OR REPLACE FUNCTION "api"."get_owned_interface_addresses"(input_owner text) RETURNS SETOF "systems"."interface_address_data" AS $$
	BEGIN
		IF input_owner IS NULL THEN
			RETURN QUERY (SELECT "mac","address","family","config","class","isprimary","comment","renew_date","date_created","date_modified","last_modifier"
			FROM "systems"."interface_addresses");
		ELSE
			RETURN QUERY (SELECT "mac","address","family","config","class","isprimary","comment","renew_date","date_created","date_modified","last_modifier"
			FROM "systems"."interface_addresses" WHERE api.get_interface_address_owner("address") = input_owner);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_owned_interface_addresses"(text) IS 'Get all interface address data for all addresses owned by a given user';

/* API - get_system_primary_address */
CREATE OR REPLACE FUNCTION "api"."get_system_primary_address"(input_system_name text) RETURNS INET AS $$
	BEGIN
		RETURN (SELECT "address" FROM "systems"."systems" 
		JOIN "systems"."interfaces" ON "systems"."interfaces"."system_name" = "systems"."systems"."system_name"
		JOIN "systems"."interface_addresses" ON "systems"."interfaces"."mac" = "systems"."interface_addresses"."mac"
		WHERE "isprimary" = TRUE AND "systems"."systems"."system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION  "api"."get_system_primary_address"(text) IS 'Get the primary address of a system';

/* API - get_interface_system*/
CREATE OR REPLACE FUNCTION "api"."get_interface_system"(input_mac macaddr) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "system_name" FROM "systems"."interfaces" WHERE "mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_system"(macaddr) IS 'Get the system name that a mac address is on';

/* API - get_system_interface_switchport*/
CREATE OR REPLACE FUNCTION "api"."get_system_interface_switchport"(input_mac macaddr) RETURNS SETOF "network"."switchport_data" AS $$
	BEGIN
		RETURN QUERY (
		SELECT  "network"."switchports"."system_name",
			"network"."switchports"."port_name",
			"network"."switchports"."type",
			"network"."switchports"."description",
			"network"."switchport_states"."port_state",
			"network"."switchport_states"."admin_state",
			"network"."switchports"."date_created",
			"network"."switchports"."date_modified",
			"network"."switchports"."last_modifier"
		FROM "network"."switchports"
		LEFT JOIN "network"."switchport_states" 
		ON "network"."switchports"."port_name" = "network"."switchport_states"."port_name" 
		JOIN "network"."switchport_macs" 
		ON "network"."switchports"."port_name" = "network"."switchport_macs"."port_name"
		AND "network"."switchports"."system_name" = "network"."switchport_macs"."system_name"
		WHERE "network"."switchport_macs"."mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_interface_switchport"(macaddr) IS 'Get the switchport data that a mac address is on';