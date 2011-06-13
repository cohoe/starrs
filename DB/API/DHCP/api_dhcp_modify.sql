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
			RAISE EXCEPTION 'Permission to modify dhcp class denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Check allowed fields
		IF input_field !~* 'class|comment' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Validate class name
		IF input_field !~* 'class' THEN
			input_new_value := api.validate_nospecial(input_new_value);
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		EXECUTE 'UPDATE "dhcp"."classes" SET ' || quote_ident($2) || ' = $3, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
		WHERE "class" = $1' 
		USING input_old_class, input_field, input_new_value;	

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
			RAISE EXCEPTION 'Permission to modify dhcp class option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Check allowed fields
		IF input_field !~* 'class|option|value' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		EXECUTE 'UPDATE "dhcp"."class_options" SET ' || quote_ident($4) || ' = $5, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
		WHERE "class" = $1 AND "option" = $2 AND "value" = $3' 
		USING input_old_class, input_old_option, input_old_value, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_dhcp_class_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dhcp_class_option"(text, text, text, text, text) IS 'Modify a field of a DHCP class option';

/* API - modify_dhcp_subnet_option
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dhcp_subnet_option"(input_old_subnet cidr, input_old_option text, input_old_value text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_dhcp_subnet_option');

		-- Check privileges		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to modify dhcp subnet option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Check allowed fields
		IF input_field !~* 'subnet|option|value' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		EXECUTE 'UPDATE "dhcp"."subnet_options" SET ' || quote_ident($4) || ' = $5, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
		WHERE "subnet" = $1 AND "option" = $2 AND "value" = $3' 
		USING input_old_subnet, input_old_option, input_old_value, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_dhcp_subnet_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dhcp_subnet_option"(cidr, text, text, text, text) IS 'Modify a field of a DHCP subnet option';

/* API - modify_dhcp_subnet_setting
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dhcp_subnet_setting"(input_old_subnet cidr, input_old_setting text, input_old_value text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_dhcp_subnet_setting');

		-- Check privileges		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to modify dhcp subnet setting denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Check allowed fields
		IF input_field !~* 'subnet|setting|value' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		EXECUTE 'UPDATE "dhcp"."subnet_settings" SET ' || quote_ident($4) || ' = $5, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
		WHERE "subnet" = $1 AND "setting" = $2 AND "value" = $3' 
		USING input_old_subnet, input_old_setting, input_old_value, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_dhcp_subnet_setting');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dhcp_subnet_setting"(cidr, text, text, text, text) IS 'Modify a field of a DHCP subnet setting';

/* API - modify_dhcp_range_setting
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dhcp_range_setting"(input_old_range text, input_old_setting text, input_old_value text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_dhcp_range_setting');

		-- Check privileges		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to modify dhcp range setting denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Check allowed fields
		IF input_field !~* 'name|setting|value' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		EXECUTE 'UPDATE "dhcp"."range_settings" SET ' || quote_ident($4) || ' = $5, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
		WHERE "name" = $1 AND "setting" = $2 AND "value" = $3' 
		USING input_old_range, input_old_setting, input_old_value, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_dhcp_range_setting');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dhcp_range_setting"(text, text, text, text, text) IS 'Modify a field of a DHCP range setting';