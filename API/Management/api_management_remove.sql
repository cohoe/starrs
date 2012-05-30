/* api_management_remove.sql
	1) remove_site_configuration
*/

/* API - remove_site_configuration
	1) Check privileges
	2) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."remove_site_configuration"(input_directive text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_site_configuration');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can remove site directives';
		END IF;

		-- Create directive
		PERFORM api.create_log_entry('API','INFO','creating directive');
		DELETE FROM "management"."configuration" WHERE "option" = input_directive;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_site_configuration');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_site_configuration"(text) IS 'Remove a site configuration directive';