/* API - regenerate_documentation */
CREATE OR REPLACE FUNCTION "api"."regenerate_documentation"() RETURNS VOID AS $$
	DECLARE
		regex TEXT;
		schemas RECORD;
	BEGIN
		-- Delete functions
		DELETE FROM "documentation"."functions" WHERE "specific_name" NOT IN (SELECT "specific_name" FROM "information_schema"."routines");

		-- Insert new functions
		INSERT INTO "documentation"."functions" ("specific_name","returns","name","definition","comment") (
		SELECT "specific_name","data_type","routine_name",regexp_replace(pg_get_functiondef(('api.'||"routine_name")::regproc::oid),E'^(CREATE OR REPLACE FUNCTION )(.*)\n RETURNS(.*)',E'\\2') AS "definition", obj_description(pg_proc.oid) AS "comment" 
		FROM information_schema.routines 
		JOIN pg_proc ON information_schema.routines.routine_name = pg_proc.proname 
		WHERE specific_schema = 'api'
		AND "specific_name" NOT IN (
		SELECT "specific_name" FROM "documentation"."functions"));
		
		FOR schemas IN (select "schema_name" from information_schema.schemata where schema_name !~* 'pg_|information_schema') LOOP
			regex := '(get|create|remove|modify)_'||schemas.schema_name;
			UPDATE "documentation"."functions" SET "schema" = schemas.schema_name WHERE "name" ~* regex;
		END LOOP;

		UPDATE "documentation"."functions" SET "schema" = 'systems' WHERE "name" ~* '(get|create|remove|modify)_(system|interface)';

		-- Insert new arguments
		INSERT INTO "documentation"."arguments" ("specific_name","argument","type","position") (
		SELECT "specific_name","parameter_name","udt_name","ordinal_position"
		FROM "information_schema"."parameters"
		WHERE "specific_schema" = 'api' AND "parameter_name" IS NOT NULL AND ("specific_name","parameter_name") NOT IN (SELECT "specific_name","parameter_name" FROM "documentation"."arguments"));
		
		INSERT INTO "documentation"."arguments" ("specific_name","argument","type","position") (
		SELECT "specific_name",'$'||"ordinal_position","udt_name","ordinal_position"
		FROM "information_schema"."parameters"
		WHERE "specific_schema" = 'api' AND "parameter_name" IS NULL AND ("specific_name","ordinal_position") NOT IN (SELECT "specific_name","ordinal_position" FROM "documentation"."arguments"));
		
		-- Delete old arguments
		DELETE FROM "documentation"."arguments" WHERE ("specific_name","argument") NOT IN (SELECT "specific_name","parameter_name" FROM "information_schema"."parameters");

		DELETE FROM "documentation"."arguments" WHERE "specific_name" NOT IN (SELECT "specific_name" FROM "information_schema"."parameters");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."regenerate_documentation"() IS 'Regenerate the API documentation directly from the existing functions';