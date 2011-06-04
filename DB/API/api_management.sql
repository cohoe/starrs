/* API - create_log_entry
 	1) Sanitize input
 	2) Create log entry
*/
CREATE OR REPLACE FUNCTION "api"."create_log_entry"(input_source text, input_severity text, input_message text) RETURNS VOID AS $$
	BEGIN
		-- Sanitize input
		input_source := api.sanitize_general(input_source);
		input_severity := api.sanitize_general(input_severity);
		input_message := api.sanitize_general(input_message);

		-- Create log entry
		INSERT INTO "management"."log_master"
		("source","user","severity","message") VALUES
		(input_source,api.get_current_user(),input_severity,input_message);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_log_entry"(text, text, text) IS 'Function to insert a log entry';

/* API - sanitize_general */
CREATE OR REPLACE FUNCTION "api"."sanitize_general"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\_\,\.\:\/ \(\)]*\-*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."sanitize_general"(text) IS 'Allow only certain characters for most common objects';

/* API - sanitize_dhcp*/
CREATE OR REPLACE FUNCTION "api"."sanitize_dhcp"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap	TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\_\.\=\"\,\(\)\/\; ]*\-*', '', 'gi');
		IF BadCrap != '' THEN
			--RAISE EXCEPTION 'Invalid characters detected in string "%"',BadCrap;
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."sanitize_dhcp"(text) IS 'Only allow certain characters in DHCP options';

/* API - get_current_user */
CREATE OR REPLACE FUNCTION "api"."get_current_user"() RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "username"
		FROM user_privileges
		WHERE "privilege" = 'USERNAME');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_current_user"() IS 'Get the username of the current session';

/* API - renew_system (DOCUMENT)*/
CREATE OR REPLACE FUNCTION "api"."renew_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.renew_system');
		input_system_name := api.sanitize_general(input_system_name);
		
		PERFORM api.create_log_entry('API','INFO','renewing system');
		UPDATE "systems"."systems" SET "renew_date" = date(current_date + interval '1 year');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."renew_system"(text) IS 'Renew a registered system for the next year';

/* API - create_site_configuration
	1) Sanitize input
	2) Check privileges
	3) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."create_site_configuration"(input_directive text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_site_configuration');
		
		-- Sanitize input
		input_directive := api.sanitize_general(input_directive);
		input_value := api.sanitize_general(input_value);
		
		-- Create directive
		PERFORM api.create_log_entry('API','INFO','creating directive');
		INSERT INTO "management"."configuration" VALUES (input_directive, input_value);
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_site_configuration');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_site_configuration"(text, text) IS 'Create a new site configuration directive';

/* API - remove_site_configuration
	1) Sanitize input
	2) Check privileges
	3) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."remove_site_configuration"(input_directive text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_site_configuration');
		
		-- Sanitize input
		input_directive := api.sanitize_general(input_directive);
		
		-- Create directive
		PERFORM api.create_log_entry('API','INFO','creating directive');
		DELETE FROM "management"."configuration" WHERE "option" = input_directive;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_site_configuration');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_site_configuration"(text) IS 'Remove a site configuration directive';

/* API - modify_site_configuration
	1) Sanitize input
	2) Check privileges
	3) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."modify_site_configuration"(input_directive text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_site_configuration');
		
		-- Sanitize input
		input_directive := api.sanitize_general(input_directive);
		input_value := api.sanitize_general(input_value);
		
		-- Create directive
		PERFORM api.create_log_entry('API','INFO','modifying directive');
		UPDATE "management"."configuration" SET "value" = input_value WHERE "option" = input_directive;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_site_configuration');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_site_configuration"(text, text) IS 'Modify a site configuration directive';

/* API - get_site_configuration
	1) Sanitize input
*/
CREATE OR REPLACE FUNCTION "api"."get_site_configuration"(input_directive text) RETURNS TEXT AS $$
	BEGIN		
		-- Sanitize input
		input_directive := api.sanitize_general(input_directive);
		
		RETURN (SELECT "value" FROM "management"."configuration" WHERE "option" = input_directive);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_site_configuration"(text) IS 'Get a site configuration directive';

/* API - lock_process
	1) Sanitize input
	2) Check privileges
	3) Get current status
	4) Update status
*/
CREATE OR REPLACE FUNCTION "api"."lock_process"(input_process text) RETURNS VOID AS $$
	DECLARE
		Status BOOLEAN;
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.lock_process');
	
		-- Sanitize input
		input_process := api.sanitize_general(input_process);

		-- Get current status
		SELECT "locked" INTO Status
		FROM "management"."processes"
		WHERE "management"."processes"."process" = input_process;
		IF Status IS TRUE THEN
			RAISE EXCEPTION 'Process is locked';
		END IF;
		
		-- Update status
		PERFORM api.create_log_entry('API','INFO','locking process '||input_process);
		UPDATE "management"."processes" SET "locked" = TRUE WHERE "management"."processes"."process" = input_process;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.lock_process');

	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."lock_process"(text) IS 'Lock a process for a job';

/* API - unlock_process
	1) Sanitize input
	2) Check privileges
	3) Update status
*/
CREATE OR REPLACE FUNCTION "api"."unlock_process"(input_process text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.unlock_process');
		
		-- Sanitize input
		input_process := api.sanitize_general(input_process);
		
		-- Update status
		PERFORM api.create_log_entry('API','INFO','unlocking process '||input_process);
		UPDATE "management"."processes" SET "locked" = FALSE WHERE "management"."processes"."process" = input_process;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.unlock_process');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."unlock_process"(text) IS 'Unlock a process for a job';

/* API - initialize
	1) Sanitize input
	2) Create privilege table
	3) Populate privileges
*/
CREATE OR REPLACE FUNCTION "api"."initialize"(input_username text) RETURNS VOID AS $$
	BEGIN
		-- Sanitize input
		input_username := api.sanitize_general(input_username);
		
		-- Create privilege table
		CREATE TEMPORARY TABLE user_privileges
		(username text NOT NULL,privilege text NOT NULL,
		allow boolean NOT NULL DEFAULT false);

		-- Populate privileges
		INSERT INTO user_privileges VALUES (input_username,'USERNAME',TRUE);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."initialize"(text) IS 'Setup user access to the database';