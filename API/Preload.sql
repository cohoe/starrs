CREATE OR REPLACE FUNCTION "api"."get_current_user"() RETURNS TEXT AS $$
        BEGIN
                RETURN (SELECT "username"
                FROM "user_privileges"
                WHERE "privilege" = 'USERNAME');
        END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_current_user"() IS 'Get the username of the current session';

CREATE OR REPLACE FUNCTION "api"."get_site_configuration"(input_directive text) RETURNS TEXT AS $$
        BEGIN
                RETURN (SELECT "value" FROM "management"."configuration" WHERE "option" = input_directive);
        END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_site_configuration"(text) IS 'Get a site configuration directive';