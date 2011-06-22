/* Document.sql */

INSERT INTO "documentation"."functions" ("specific_name","returns","name","definition","comment") (
SELECT "specific_name","data_type","routine_name",regexp_replace(pg_get_functiondef(('api.'||"routine_name")::regproc::oid),E'^(CREATE OR REPLACE FUNCTION )(.*)\n RETURNS(.*)',E'\\2') AS "definition", obj_description(pg_proc.oid) AS "comment" 
FROM information_schema.routines 
JOIN pg_proc ON information_schema.routines.routine_name = pg_proc.proname 
WHERE specific_schema = 'api');

INSERT INTO "documentation"."arguments" ("specific_name","argument","type","position") (
SELECT "specific_name","parameter_name","udt_name","ordinal_position"
FROM "information_schema"."parameters"
WHERE "specific_schema" = 'api' AND "parameter_name" IS NOT NULL);

INSERT INTO "documentation"."arguments" ("specific_name","argument","type","position") (
SELECT "specific_name",'$'||"ordinal_position","udt_name","ordinal_position"
FROM "information_schema"."parameters"
WHERE "specific_schema" = 'api' AND "parameter_name" IS NULL);