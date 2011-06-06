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

/* API - remove_dhcp_clas
	1) Check privileges
	2) Validate input
	3) Remove class
s*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_class"(input_class text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dhcp_class');

		-- Check privileges
		IF (api.get_current_user_level() ~* 'USER|PROGRAM') THEN
			RAISE EXCEPTION 'Permission denied for % (%)',api.get_current_user(),api.get_current_user_level();
		END IF;

		-- Validate input
		input_class := api.validate_dhcp_class(input_class);

		-- Remove class
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dhcp class');
		DELETE FROM "dhcp"."classes" WHERE "class" = input_class;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_dhcp_class');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_class"(text) IS 'Delete existing DHCP class';

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

/* API - remove_dhcp_class_option
	1) Check privileges
	2) Remove class option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dhcp_class_option');

		-- Check privileges
		IF (api.get_current_user_level() ~* 'USER|PROGRAM') THEN
			RAISE EXCEPTION 'Permission denied for % (%)',api.get_current_user(),api.get_current_user_level();
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

/* API - remove_dhcp_subnet_option
	1) Check privileges
	2) Remove subnet option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dhcp_subnet_option');

		-- Check privileges
		IF (api.get_current_user_level() ~* 'USER|PROGRAM') THEN
			RAISE EXCEPTION 'Permission denied for % (%)',api.get_current_user(),api.get_current_user_level();
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