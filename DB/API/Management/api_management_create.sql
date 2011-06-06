/* API - create_log_entry
 	1) Create log entry
*/
CREATE OR REPLACE FUNCTION "api"."create_log_entry"(input_source text, input_severity text, input_message text) RETURNS VOID AS $$
	BEGIN
		-- Create log entry
		INSERT INTO "management"."log_master"
		("source","user","severity","message") VALUES
		(input_source,api.get_current_user(),input_severity,input_message);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_log_entry"(text, text, text) IS 'Function to insert a log entry';

/* API - create_site_configuration
	1) Check privileges
	2) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."create_site_configuration"(input_directive text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_site_configuration');
		
		-- Create directive
		PERFORM api.create_log_entry('API','INFO','creating directive');
		INSERT INTO "management"."configuration" VALUES (input_directive, input_value);
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_site_configuration');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_site_configuration"(text, text) IS 'Create a new site configuration directive';
