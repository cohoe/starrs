/* API - modify_site_configuration
	1) Check privileges
	2) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."modify_site_configuration"(input_directive text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_site_configuration');
		
		-- Create directive
		PERFORM api.create_log_entry('API','INFO','modifying directive');
		UPDATE "management"."configuration" SET "value" = input_value WHERE "option" = input_directive;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_site_configuration');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_site_configuration"(text, text) IS 'Modify a site configuration directive';
