/*Trigger Function API - create_dhcp_class*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class"(input_class text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class');
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);
		SELECT api.create_log_entry('API', 'INFO', 'creating new dhcp class');
		INSERT INTO "dhcp"."classes" ("class","comment","last_modifier") VALUES (input_class,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_class"() IS 'Create a new DHCP class';

/*Trigger Function API - delete_dhcp_class*/
CREATE OR REPLACE FUNCTION "api"."delete_dhcp_class"(input_class text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dhcp_class');
		input_class := api.sanitize_general(input_class);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dhcp class');
		DELETE FROM "dhcp"."classes" WHERE "class" = input_class;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."delete_dhcp_class"() IS 'Delete existing DHCP class';

/*Trigger Function API - create_dhcp_class_option*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class_option');
		input_class := api.sanitize_general(input_class);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'creating new dhcp class option');
		INSERT INTO "dhcp"."class_options" 
		("class","option","value","last_modifier") VALUES
		(input_class,input_option,input_value,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_class_option"() IS 'Create a new DHCP class option';

/*Trigger Function API - delete_dhcp_class_option*/
CREATE OR REPLACE FUNCTION "api"."delete_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dhcp_class_option');
		input_class := api.sanitize_general(input_class);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dhcp class option');
		DELETE FROM "dhcp"."class_options"
		WHERE "class" = input_class AND "option" = input_option AND "value" = input_value;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."delete_dhcp_class_option"() IS 'Delete existing DHCP class option';

/*Trigger Function API - create_dhcp_subnet_option*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_subnet_option');
		input_subnet := api.sanitize_general(input_subnet);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'creating dhcp subnet option');
		INSERT INTO "dhcp"."subnet_options" 
		("subnet","option","value","last_modifier") VALUES
		(input_subnet,input_option,input_value,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dhcp_subnet_option"() IS 'Create DHCP subnet option';

/*Trigger Function API - delete_dhcp_subnet_option*/
CREATE OR REPLACE FUNCTION "api"."delete_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dhcp_subnet_option');
		input_subnet := api.sanitize_general(input_subnet);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dhcp subnet option');
		DELETE FROM "dhcp"."subnet_options"
		WHERE "subnet" = input_subnet AND "option" = input_option AND "value" = input_value;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."delete_dhcp_subnet_option"() IS 'Delete existing DHCP subnet option';