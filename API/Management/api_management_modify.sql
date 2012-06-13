/* api_management_modify
	1) modify_site_configuration
*/

/* API - modify_site_configuration
	1) Check privileges
	2) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."modify_site_configuration"(input_directive text, input_value text) RETURNS SETOF "management"."configuration" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_site_configuration');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can modify site directives';
		END IF;

		-- Create directive
		PERFORM api.create_log_entry('API','INFO','modifying directive');
		UPDATE "management"."configuration" SET "value" = input_value WHERE "option" = input_directive;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_site_configuration');
		RETURN QUERY (SELECT * FROM "management"."configuration" WHERE "option" = input_directive AND "value" = input_value);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_site_configuration"(text, text) IS 'Modify a site configuration directive';