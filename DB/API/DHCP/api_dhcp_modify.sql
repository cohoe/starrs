/* api_dhcp_modify.sql
	1) modify_dhcp_class
	2) modify_dhcp_class_option
	3) modify_dhcp_subnet_option
	4) modify_dhcp_subnet_setting
	5) modify_dhcp_range_setting
*/

/* API - modify_dhcp_class
	1) Check privileges
	2) Check allowed fields
	3) Validate class name
	4) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dhcp_class"(input_old_class text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_dhcp_class');

		-- Check privileges		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to create dhcp class denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Check allowed fields
		IF input_field !~* 'class|comment' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Validate class name
		IF input_field !* 'class' THEN
			input_new_value := api.validate_nospecial(input_new_value);
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');
		UPDATE "dhcp"."classes" SET input_field,date_modified,last_modifier = input_new_value,current_timestamp,api.get_current_user() WHERE "class" = input_old_class;
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_dhcp_class');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dhcp_class"(text, text, text) IS 'Modify a field of a DHCP setting';

/* API - modify_dhcp_class_option
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dhcp_class_option"(input_old_class text, input_old_option text, input_old_value text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_dhcp_class_option');
		
		-- Check privileges		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to create dhcp class denied for %. Not admin.',api.get_current_user();
		END IF;
		
		-- Check allowed fields
		IF input_field !~* 'class|option|value' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;
		
		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');
		UPDATE "dhcp"."class_options" SET input_field,date_modified,last_modifier = input_new_value,current_timestamp,api.get_current_user() WHERE "class" = input_old_class AND "option" = input_old_option AND "value" = input_old_value;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_dhcp_class_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dhcp_class_option"(text, text, text, text, text) IS 'Modify a field of a DHCP class option';
