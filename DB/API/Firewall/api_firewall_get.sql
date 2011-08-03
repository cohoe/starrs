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

/* API - get_firewall_metahosts */
CREATE OR REPLACE FUNCTION "api"."get_firewall_metahosts"(input_username text) RETURNS SETOF "firewall"."metahost_data" AS $$
	BEGIN
		IF input_username IS NULL THEN
			RETURN QUERY (SELECT "name","comment","owner","date_created","date_modified","last_modifier" FROM "firewall"."metahosts");
		ELSE
			RETURN QUERY (SELECT "name","comment","owner","date_created","date_modified","last_modifier" FROM "firewall"."metahosts" WHERE "owner" = input_username);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_metahosts"(text) IS 'Get all data on firewall metahosts';

/* API - get_firewall_metahost */
CREATE OR REPLACE FUNCTION "api"."get_firewall_metahost"(input_metahost_name text) RETURNS SETOF "firewall"."metahost_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","comment","owner","date_created","date_modified","last_modifier" FROM "firewall"."metahosts" WHERE "name" = input_metahost_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_metahost"(text) IS 'Get all data on a firewall metahost';

/* API - get_firewall_metahost_members */
CREATE OR REPLACE FUNCTION "api"."get_firewall_metahost_members"(input_metahost_name text) RETURNS SETOF "firewall"."metahost_member_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","address","date_created","date_modified","last_modifier" FROM "firewall"."metahost_members" WHERE "name" = input_metahost_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_metahost_members"(text) IS 'Get a list of all members of a specific metahost';

/* API - get_firewall_metahost_member*/
CREATE OR REPLACE FUNCTION "api"."get_firewall_metahost_member"(input_address inet) RETURNS SETOF "firewall"."metahost_member_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","address","date_created","date_modified","last_modifier" FROM "firewall"."metahost_members" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_metahost_member"(inet) IS 'Get all of the information about a single metahost member';

/* API - get_firewall_standalone_rules */
CREATE OR REPLACE FUNCTION "api"."get_firewall_standalone_rules"(input_address inet) RETURNS SETOF "firewall"."standalone_rule_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "address","port","transport","deny","comment","owner","date_created","date_modified","last_modifier"
		FROM "firewall"."rules" WHERE "address" = input_address AND "source" = 'standalone-standalone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_standalone_rules"(inet) IS 'Get all standalone rules for an address';

/* API - get_firewall_standalone_program_rules */
CREATE OR REPLACE FUNCTION "api"."get_firewall_standalone_program_rules"(input_address inet) RETURNS SETOF "firewall"."standalone_program_data" AS $$
	BEGIN
		RETURN QUERY (SELECT 
			"firewall"."program_rules"."address",
			"firewall"."programs"."name",
			"firewall"."program_rules"."port",
			"firewall"."programs"."transport",
			"firewall"."program_rules"."deny",
			"firewall"."program_rules"."comment",
			"firewall"."program_rules"."owner",
			"firewall"."program_rules"."date_created",
			"firewall"."program_rules"."date_modified",
			"firewall"."program_rules"."last_modifier"
		FROM "firewall"."program_rules" JOIN "firewall"."programs"
		ON "firewall"."program_rules"."port" = "firewall"."programs"."port"
		WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_standalone_program_rules"(inet) IS 'Get all standalone rules for an address';

/* API - get_firewall_metahost_rules */
CREATE OR REPLACE FUNCTION "api"."get_firewall_metahost_rules"(input_metahost_name text) RETURNS SETOF "firewall"."metahost_standalone_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "firewall"."metahost_rules"."name","port","transport","deny","firewall"."metahost_rules"."comment","owner","firewall"."metahost_rules"."date_created","firewall"."metahost_rules"."date_modified","firewall"."metahost_rules"."last_modifier"
		FROM "firewall"."metahost_rules" 
		JOIN "firewall"."metahosts" ON "firewall"."metahost_rules"."name" = "firewall"."metahosts"."name"
		WHERE "firewall"."metahost_rules"."name" = input_metahost_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_metahost_rules"(text) IS 'Get all info on rules applying to a specific metahost';

/* API - get_firewall_metahost_program_rules */
CREATE OR REPLACE FUNCTION "api"."get_firewall_metahost_program_rules"(input_metahost_name text) RETURNS SETOF "firewall"."metahost_program_data" AS $$
	BEGIN
		RETURN QUERY (SELECT 
			"firewall"."metahost_program_rules"."name",
			"firewall"."programs"."name",
			"firewall"."programs"."port",
			"firewall"."programs"."transport",
			"deny",
			"firewall"."metahost_program_rules"."comment",
			"firewall"."metahosts"."owner",
			"firewall"."metahost_program_rules"."date_created",
			"firewall"."metahost_program_rules"."date_modified",
			"firewall"."metahost_program_rules"."last_modifier"
		FROM "firewall"."metahost_program_rules" 
		JOIN "firewall"."metahosts" ON "firewall"."metahost_program_rules"."name" = "firewall"."metahosts"."name"
		JOIN "firewall"."programs" ON "firewall"."metahost_program_rules"."port" = "firewall"."programs"."port"
		WHERE "firewall"."metahost_program_rules"."name" = input_metahost_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_metahost_program_rules"(text) IS 'Get all info on rules applying to a specific metahost';

CREATE OR REPLACE FUNCTION "api"."get_firewall_addresses"(input_subnet cidr) RETURNS SETOF "firewall"."address_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "subnet","address","isprimary","date_created","date_modified","last_modifier" FROM "firewall"."addresses" WHERE "subnet" = input_subnet);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_addresses"(cidr) IS 'Get all firewall addresses for a subnet';

/* API - get_firewall_default_data */
CREATE OR REPLACE FUNCTION "api"."get_firewall_default_data"(input_subnet cidr) RETURNS SETOF "firewall"."default_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "address","deny" FROM "firewall"."defaults" WHERE "address" IN 
		(SELECT"address" FROM "systems"."interface_addresses") AND "address" << input_subnet);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_default_data"(cidr) IS 'Get firewall default action data';

/* API - get_firewall_database */
CREATE OR REPLACE FUNCTION "api"."get_firewall_database"(input_subnet cidr) RETURNS SETOF "firewall"."rule_export_data" AS $$
	BEGIN
		RETURN QUERY (SELECT 'INSERT',"address","port","transport","deny" FROM "firewall"."rules" WHERE "address" << input_subnet ORDER BY "address","port","transport" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_database"(cidr) IS 'Get the complete firewall database for a subnet';

/* API - get_firewall_rule_queue */
CREATE OR REPLACE FUNCTION "api"."get_firewall_rule_queue"(input_subnet cidr) RETURNS SETOF "firewall"."rule_export_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "action","address","port","transport","deny" FROM "firewall"."rule_queue" WHERE "address" << input_subnet ORDER BY "timestamp","action","address","port","transport" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_rule_queue"(cidr) IS 'Get the current firewall queue for a subnet';

/* API - get_firewall_default_queue */
CREATE OR REPLACE FUNCTION "api"."get_firewall_default_queue"(input_subnet cidr) RETURNS SETOF "firewall"."default_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "address","deny" FROM "firewall"."default_queue" WHERE "address" << input_subnet ORDER BY "timestamp","address" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_default_queue"(cidr) IS 'Get firewall default action change queue';