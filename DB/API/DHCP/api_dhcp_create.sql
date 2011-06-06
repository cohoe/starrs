/* API - create_dhcp_class
	1) Check privileges
	2) Validate input
	3) Create new class
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class"(input_class text, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class');

		-- Check privileges
		IF (api.get_current_user_level() ~* 'USER|PROGRAM') THEN
			RAISE EXCEPTION 'Permission denied for % (%)',api.get_current_user(),api.get_current_user_level();
		END IF;

		-- Validate input
		input_class := api.validate_nospecial(input_class);

		-- Create new class		
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dhcp class');
		INSERT INTO "dhcp"."classes" ("class","comment") VALUES (input_class,input_comment);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_class');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_class"(text, text) IS 'Create a new DHCP class';

/* API - create_dhcp_class_option
	1) Check privileges
	2) Create class option
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class_option');

		-- Check privileges
		IF (api.get_current_user_level() ~* 'USER|PROGRAM') THEN
			RAISE EXCEPTION 'Permission denied for % (%)',api.get_current_user(),api.get_current_user_level();
		END IF;

		-- Create class option		
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dhcp class option');
		INSERT INTO "dhcp"."class_options" 
		("class","option","value") VALUES
		(input_class,input_option,input_value);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_class_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_class_option"(text, text, text) IS 'Create a new DHCP class option';

/* API - create_dhcp_subnet_option
	1) Check privileges
	2) Create subnet option
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_subnet_option');

		-- Check privileges
		IF (api.get_current_user_level() ~* 'USER|PROGRAM') THEN
			RAISE EXCEPTION 'Permission denied for % (%)',api.get_current_user(),api.get_current_user_level();
		END IF;

		-- Create subnet option		
		PERFORM api.create_log_entry('API', 'INFO', 'creating dhcp subnet option');
		INSERT INTO "dhcp"."subnet_options" 
		("subnet","option","value") VALUES
		(input_subnet,input_option,input_value);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_subnet_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_subnet_option"(cidr, text, text) IS 'Create DHCP subnet option';

