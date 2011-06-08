/* api_dhcp_remove.sql
	1) remove_dhcp_class
	2) remove_dhcp_class_option
	3) remove_dhcp_subnet_option
	4) remove_dhcp_subnet_setting
	5) remove_dhcp_range_setting
*/

/* API - remove_dhcp_class
	1) Check privileges
	2) Remove class
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_class"(input_class text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dhcp_class');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp class denied for % (%)',api.get_current_user(),api.get_current_user_level();
		END IF;

		-- Remove class
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dhcp class');
		DELETE FROM "dhcp"."classes" WHERE "class" = input_class;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_dhcp_class');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_class"(text) IS 'Delete existing DHCP class';

/* API - remove_dhcp_class_option
	1) Check privileges
	2) Remove class option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dhcp_class_option');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp class option denied for % (%)',api.get_current_user(),api.get_current_user_level();
		END IF;

		-- Remove class option		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dhcp class option');
		DELETE FROM "dhcp"."class_options"
		WHERE "class" = input_class AND "option" = input_option AND "value" = input_value;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_dhcp_class_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_class_option"(text, text, text) IS 'Delete existing DHCP class option';

/* API - remove_dhcp_subnet_option
	1) Check privileges
	2) Remove subnet option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dhcp_subnet_option');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp subnet option denied for % (%)',api.get_current_user(),api.get_current_user_level();
		END IF;

		-- Delete subnet option		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dhcp subnet option');
		DELETE FROM "dhcp"."subnet_options"
		WHERE "subnet" = input_subnet AND "option" = input_option AND "value" = input_value;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_dhcp_subnet_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_subnet_option"(cidr, text, text) IS 'Delete existing DHCP subnet option';

/* API - remove_dhcp_subnet_setting
	1) Check privileges
	2) Remove setting
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_subnet_setting"(input_subnet cidr, input_setting text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin remove_dhcp_subnet_setting');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission to remove dhcp subnet setting denied for user %. You are not admin.',api.get_current_user();
		END IF;

		-- Remove setting
		PERFORM api.create_log_entry('API','INFO','Removing DHCP subnet setting');
		DELETE FROM "dhcp"."subnet_settings" WHERE "subnet" = input_subnet AND "setting" = input_setting;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish remove_dhcp_subnet_setting');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_subnet_setting"(cidr, text) IS 'Remove a DHCP subnet setting';

/* API - remove_dhcp_range_setting
	1) Check privileges
	2) Remove setting
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_range_setting"(input_range text, input_setting text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin remove_dhcp_range_setting');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission to remove dhcp range setting denied for user %. You are not admin.',api.get_current_user();
		END IF;

		-- Remove setting
		PERFORM api.create_log_entry('API','INFO','Removing DHCP range setting');
		DELETE FROM "dhcp"."range_settings" WHERE "name" = input_range AND "setting" = input_setting;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish remove_dhcp_range_setting');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_range_setting"(text, text) IS 'Remove a DHCP subnet setting';