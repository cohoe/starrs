/* api_dhcp_create.sql
	1) create_dhcp_class
	2) create_dhcp_class_option
	3) create_dhcp_subnet_option
	5) create_dhcp_range_option
	6) create_dhcp_global_option
*/

/* API - create_dhcp_class
	1) Check privileges
	2) Validate input
	3) Create new class
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class"(input_class text, input_comment text) RETURNS SETOF "dhcp"."classes" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission to create dhcp class denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Validate input
		input_class := api.validate_nospecial(input_class);

		-- Create new class		
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dhcp class');
		INSERT INTO "dhcp"."classes" ("class","comment") VALUES (input_class,input_comment);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_class');
		RETURN QUERY (SELECT * FROM "dhcp"."classes" WHERE "class" = input_class);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_class"(text, text) IS 'Create a new DHCP class';


/* API - create_dhcp_class_option
	1) Check privileges
	2) Create class option
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS SETOF "dhcp"."class_options" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class_option');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission to create dhcp class option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Create class option		
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dhcp class option');
		INSERT INTO "dhcp"."class_options" 
		("class","option","value") VALUES
		(input_class,input_option,input_value);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_class_option');
		RETURN QUERY (SELECT * FROM "dhcp"."class_options" WHERE "class" = input_class AND "option" = input_option AND "value" = input_value);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_class_option"(text, text, text) IS 'Create a new DHCP class option';

/* API - create_dhcp_subnet_option
	1) Check privileges
	2) Create subnet option
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS SETOF "dhcp"."subnet_options" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_subnet_option');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission to create dhcp subnet option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Create subnet option		
		PERFORM api.create_log_entry('API', 'INFO', 'creating dhcp subnet option');
		INSERT INTO "dhcp"."subnet_options" 
		("subnet","option","value") VALUES
		(input_subnet,input_option,input_value);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_subnet_option');
		RETURN QUERY (SELECT * FROM "dhcp"."subnet_options" WHERE "subnet" = input_subnet AND "option" = input_option AND "value" = input_value);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_subnet_option"(cidr, text, text) IS 'Create DHCP subnet option';

/* API - create_dhcp_range_option
	1) Check privileges
	2) Check for range DHCPness
	3) Create option
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_range_option"(input_range text, input_option text, input_value text) RETURNS SETOF "dhcp"."range_options" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_dhcp_range_option');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission to create dhcp range option denied for user %. You are not admin.',api.get_current_user();
		END IF;

		-- Check if range is marked for DHCP
		IF (SELECT "use" FROM "ip"."ranges" WHERE "name" = input_range) !~* 'ROAM' THEN
			PERFORM api.create_log_entry('API','ERROR','Range is not marked for DHCP configuration');
			RAISE EXCEPTION 'Range % is not marked for DHCP configuration',input_range;
		END IF;

		-- Create option
		PERFORM api.create_log_entry('API','INFO','Creating new DHCP range option');
		INSERT INTO "dhcp"."range_options" ("name","option","value","last_modifier")
		VALUES (input_range, input_option, input_value, api.get_current_user());

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_dhcp_range_option');
		RETURN QUERY (SELECT * FROM "dhcp"."range_options" WHERE "name" = input_range AND "option" = input_option AND "value" = input_value);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_range_option"(text, text, text) IS 'Create a DHCP range option';

/* API - create_dhcp_global_option
	1) Check privileges
	2) Create class option
*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_global_option"(input_option text, input_value text) RETURNS SETOF "dhcp"."global_options" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_global_option');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission to create dhcp class option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Create class option		
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dhcp global option');
		INSERT INTO "dhcp"."global_options" 
		("option","value") VALUES (input_option,input_value);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_dhcp_global_option');
		RETURN QUERY (SELECT * FROM "dhcp"."global_options" WHERE "option" = input_option AND "value" = input_value);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_global_option"(text, text) IS 'Create a new DHCP global option';
