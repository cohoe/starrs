/* Document.sql */

INSERT INTO "documentation"."functions" ("specific_name","returns","name","definition") (
SELECT "specific_name","data_type","routine_name",api.get_function_definition("specific_name")
FROM "information_schema"."routines"
WHERE "specific_schema" = 'api');

INSERT INTO "documentation"."arguments" ("specific_name","argument","type","position") (
SELECT "specific_name","parameter_name","udt_name","ordinal_position"
FROM "information_schema"."parameters"
WHERE "specific_schema" = 'api' AND "parameter_name" IS NOT NULL);

INSERT INTO "documentation"."arguments" ("specific_name","argument","type","position") (
SELECT "specific_name",'$'||"ordinal_position","udt_name","ordinal_position"
FROM "information_schema"."parameters"
WHERE "specific_schema" = 'api' AND "parameter_name" IS NULL);