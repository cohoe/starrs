/* API - get_system_types
	1) Return all available system types
*/
CREATE OR REPLACE FUNCTION "api"."get_system_types"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "type" FROM "systems"."device_types");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_types"() IS 'Get a list of all available system types';

/* API - get_operating_systems
	1) Return all available operating systems
*/
CREATE OR REPLACE FUNCTION "api"."get_operating_systems"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "name" FROM "systems"."os");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_operating_systems"() IS 'Get a list of all available system types';