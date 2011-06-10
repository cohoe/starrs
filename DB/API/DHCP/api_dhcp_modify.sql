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
		UPDATE "dhcp"."classes" SET input_field = input_new_value WHERE "class" = input_old_class;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_dhcp_class');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dhcp_class"(text, text) IS 'Modify a field of a DHCP setting';


