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
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
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

CREATE OR REPLACE FUNCTION "api"."remove_group"(input_group text) RETURNS VOID AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can remove groups.';
		END IF;

		DELETE FROM "management"."groups" WHERE "group" = input_group;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_group"(text) IS 'Remove a group';

CREATE OR REPLACE FUNCTION "api"."remove_group_member"(input_group text, input_user text) RETURNS VOID AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF api.get_current_user() NOT IN (SELECT * FROM api.get_group_admins(input_group)) THEN
				RAISE EXCEPTION 'Permission denied. Only admins can remove groups members';
			END IF;
		END IF;

		DELETE FROM "management"."group_members" WHERE "group" = input_group AND "user" = input_user;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_group_member"(text, text) IS 'Remove a group member';
