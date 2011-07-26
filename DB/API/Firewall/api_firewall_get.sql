/* API - get_firewall_default */
CREATE OR REPLACE FUNCTION "api"."get_firewall_default"(input_address inet) RETURNS boolean AS $$
	BEGIN
		RETURN (SELECT "deny" FROM "firewall"."defaults" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_default"(inet) IS 'Get the default firewall action of an address';

/* API - get_firewall_program_name */
CREATE OR REPLACE FUNCTION "api"."get_firewall_program_name"(input_port integer) RETURNS text AS $$
	BEGIN
		RETURN (SELECT "name" FROM "firewall"."programs" WHERE "port" = input_port);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_program_name"(integer) IS 'Get the name of a preconfigured firewall program';

/* API  - get_firewall_rules */
CREATE OR REPLACE FUNCTION "api"."get_firewall_rules"(input_address inet) RETURNS SETOF "firewall"."rule_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "address","port","transport","deny","owner","comment","source","date_created","date_modified","last_modifier"
			FROM "firewall"."rules" WHERE "address" = input_address ORDER BY source,port ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION  "api"."get_firewall_rules"(inet) IS 'Get all firewall rule data for an address';

/* API - get_firewall_transports */
CREATE OR REPLACE FUNCTION "api"."get_firewall_transports"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "transport" FROM "firewall"."transports");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_transports"() IS 'Get a list of all firewall transports';

/* API - get_firewall_program_data */
CREATE OR REPLACE FUNCTION "api"."get_firewall_program_data"() RETURNS SETOF "firewall"."program_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","port","transport","date_created","date_modified","last_modifier" FROM "firewall"."programs");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_program_data"() IS 'Get all firewall program data';