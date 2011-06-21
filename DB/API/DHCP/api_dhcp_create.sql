/* api_dhcp_create.sql
	1) create_dhcp_class
	2) create_dhcp_class_option
	3) create_dhcp_subnet_option
	4) create_dhcp_subnet_setting
	5) create_dhcp_range_setting
	6) create_dhcp_global_option
*/

/* API - create_dhcp_class
	1) Check privileges
	2) Validate input
	3) Create new class
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class"(input_class text, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to create dhcp class denied for %. Not admin.',api.get_current_user();
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
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to create dhcp class option denied for %. Not admin.',api.get_current_user();
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
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to create dhcp subnet option denied for %. Not admin.',api.get_current_user();
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

/* API - create_dhcp_subnet_setting
	1) Check privileges
	2) Check subnet DHCP-ness
	3) Create setting
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_subnet_setting"(input_subnet cidr, input_setting text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_dhcp_subnet_setting');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission to create dhcp subnet setting denied for user %. You are not admin.',api.get_current_user();
		END IF;

		-- Check if subnet is marked for DHCP
		IF (SELECT "dhcp_enable" FROM "ip"."subnets" WHERE "subnet" = input_subnet) IS FALSE THEN
			RAISE EXCEPTION 'Subnet % is not marked for DHCP configuration',input_subnet;
		END IF;

		-- Create setting
		PERFORM api.create_log_entry('API','INFO','Creating new DHCP subnet setting');
		INSERT INTO "dhcp"."subnet_settings" ("subnet","setting","value","last_modifier")
		VALUES (input_subnet, input_setting, input_value, api.get_current_user());

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_dhcp_subnet_setting');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_subnet_setting"(cidr, text, text) IS 'Create a DHCP subnet setting';

/* API - create_dhcp_range_setting
	1) Check privileges
	2) Check for range DHCPness
	3) Create setting
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_range_setting"(input_range text, input_setting text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_dhcp_range_setting');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission to create dhcp subnet setting denied for user %. You are not admin.',api.get_current_user();
		END IF;

		-- Check if range is marked for DHCP
		IF (SELECT "use" FROM "ip"."ranges" WHERE "name" = input_range) !~* 'ROAM' THEN
			RAISE EXCEPTION 'Range % is not marked for DHCP configuration',input_range;
		END IF;

		-- Create setting
		PERFORM api.create_log_entry('API','INFO','Creating new DHCP range setting');
		INSERT INTO "dhcp"."range_settings" ("name","setting","value","last_modifier")
		VALUES (input_range, input_setting, input_value, api.get_current_user());

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_dhcp_range_setting');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_range_setting"(text, text, text) IS 'Create a DHCP range setting';

/* API - create_dhcp_global_option
	1) Check privileges
	2) Create class option
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_global_option"(input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_global_option');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to create dhcp class option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Create class option		
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dhcp global option');
		INSERT INTO "dhcp"."global_options" 
		("option","value") VALUES (input_option,input_value);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_global_option');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_global_option"(text, text) IS 'Create a new DHCP global option';