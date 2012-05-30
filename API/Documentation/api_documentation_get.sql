/* API - get_function_definition */
CREATE OR REPLACE FUNCTION "api"."get_function_definition"(input_specific_name text) RETURNS TEXT AS $$
	DECLARE
		Definition TEXT := 'api.';
		Arguments RECORD;
	BEGIN
		-- Set the function name
		Definition := Definition||(SELECT "routine_name" FROM "information_schema"."routines" WHERE "specific_name" = input_specific_name);

		-- Syntax
		Definition := Definition||'(';

		-- Get args
		FOR Arguments IN SELECT "parameter_name","udt_name" FROM "information_schema"."parameters" WHERE "specific_name" = input_specific_name ORDER BY "ordinal_position" ASC LOOP
			IF Arguments.parameter_name IS NOT NULL THEN
				Definition := Definition||Arguments.parameter_name;
			ELSE
				Definition := Definition||Arguments.udt_name;
			END IF;

			Definition := Definition||', ';
		END LOOP;

		Definition := regexp_replace(Definition,', $','');
		Definition := Definition||')';

		RETURN Definition;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_function_definition"(text) IS 'Generate the function definition for documentation';