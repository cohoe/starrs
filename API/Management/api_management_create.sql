/* api_management_create.sql
	1) create_log_entry
	2) create_site_configuration
*/

/* API - create_log_entry
 	1) Create log entry
*/
CREATE OR REPLACE FUNCTION "api"."create_log_entry"(input_source text, input_severity text, input_message text) RETURNS SETOF "management"."log_master" AS $$
	BEGIN
		-- Create log entry
		INSERT INTO "management"."log_master"
		("source","user","severity","message") VALUES
		(input_source,api.get_current_user(),input_severity,input_message);
		
		-- Done
		RETURN QUERY(SELECT localtimestamp(0),api.get_current_user(),input_message,input_source,input_severity);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_log_entry"(text, text, text) IS 'Function to insert a log entry';

/* API - create_site_configuration
	1) Check privileges
	2) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."create_site_configuration"(input_directive text, input_value text) RETURNS SETOF "management"."configuration" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_site_configuration');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission denied. Only admins can create site directives';
		END IF;

		-- Create directive
		PERFORM api.create_log_entry('API','INFO','creating directive');
		INSERT INTO "management"."configuration" VALUES (input_directive, input_value);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_site_configuration');
		RETURN QUERY (SELECT * FROM "management"."configuration" WHERE "option" = input_directive AND "value" = input_value);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_site_configuration"(text, text) IS 'Create a new site configuration directive';

CREATE OR REPLACE FUNCTION "api"."create_group"(input_group text, input_privilege text, input_comment text, input_interval interval) RETURNS SETOF "management"."groups" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can create groups.';
		END IF;

		IF input_interval IS NULL THEN
			input_interval := api.get_site_configuration('DEFAULT_RENEW_INTERVAL');
		END IF;

		INSERT INTO "management"."groups" ("group","privilege","comment","renew_interval") 
		VALUES (input_group, input_privilege, input_comment, input_interval);

		RETURN QUERY (SELECT * FROM "management"."groups" WHERE "group" = input_group);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_group"(text, text, text, interval) IS 'Create a user group';

CREATE OR REPLACE FUNCTION "api"."create_group_member"(input_group text, input_user text, input_privilege text) RETURNS SETOF "management"."group_members" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF api.get_current_user() NOT IN (SELECT * FROM api.get_group_admins(input_group)) THEN
				RAISE EXCEPTION 'Permission denied. Only admins can create groups.';
			END IF;
		END IF;

		INSERT INTO "management"."group_members" ("group","user","privilege") 
		VALUES (input_group, input_user, input_privilege);
	
		RETURN QUERY (SELECT * FROM "management"."group_members" WHERE "group" = input_group AND "user" = input_user);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_group_member"(text, text, text) IS 'Assign a user to a group';
