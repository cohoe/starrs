/*Trigger Function API - create_system*/
CREATE OR REPLACE FUNCTION "api"."create_system"(input_system_name text, input_username text, input_type text, input_os_name text, input_comment text) RETURNS VOID AS $$
	BEGIN
		input_system_name := api.sanitize_general(input_system_name);
		input_username := api.sanitize_general(input_username);
		input_comment := api.sanitize_general(input_comment);

		IF input_username IS NULL THEN
			input_username := api.get_current_user();
		END IF;
		
		SELECT api.create_log_entry('API', 'INFO', 'Creating new system');
		INSERT INTO "systems"."systems"
			("system_name","username","type","os_name","comment","last_modifier") VALUES
			(input_system_name,input_username,input_type,input_os_name,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_system"() IS 'Create a new system';

/*Trigger Function API - delete_system*/
CREATE OR REPLACE FUNCTION "api"."delete_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_system');
		input_system_name := api.sanitize_general(input_system_name);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting system');
		DELETE FROM "systems"."systems" WHERE "system_name" = input_system_name;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."delete_system"() IS 'Delete an existing system';

/*Trigger Function API - create_interface*/
CREATE OR REPLACE FUNCTION "api"."create_interface"(input_system_name text, input_interface_name text, input_mac macaddr, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.create_interface');
		
		input_system_name := api.sanitize_general(input_system_name);
		input_interface_name := api.sanitize_general(input_interface_name);
		input_mac := api.sanitize_general(input_mac);
		input_comment := api.sanitize_general(input_comment);
		
		SELECT api.create_log_entry('API','INFO','creating new interface';
		INSERT INTO "systems"."interfaces"
		("system_name","interface_name","mac","comment","last_modifier") VALUES
		(input_system_name,input_interface_name,input_mac,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface"() IS 'Create a new interface on a system';

/*Trigger Function API - delete_interface*/
CREATE OR REPLACE FUNCTION "api"."delete_interface"(input_mac macaddr) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.delete_interface');
		
		input_mac := api.sanitize_general(input_mac);
		
		SELECT api.create_log_entry('API','INFO','deleting interface';
		DELETE FROM "systems"."interfaces" WHERE "mac" = input_mac;
	END;
$$ LANGUAGE 'plpgqsql';
COMMENT ON FUNCTION "api"."delete_interface"() IS 'delete an interface based on MAC address';

/*Trigger Function API - create_interface_address_manual*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address_manual"(input_mac macaddr, input_address inet, input_config text, input_class text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address_manual');
		input_mac := api.sanitize_general(input_mac);
		input_address := api.sanitize_general(input_address);
		input_config := api.sanitize_general(input_config);
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);
		
		SELECT api.create_log_entry('API', 'INFO', 'Creating new address');
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier") VALUES
		(input_mac,input_address,input_config,input_class,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address_manual"() IS 'create a new address on interface manually';

/*Trigger Function API - create_interface_address_auto*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address_auto"(input_mac macaddr, input_range_name text, input_config text, input_class text, input_comment text) RETURNS VOID AS $$
	DECLARE
		Address	INET;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address_range');
		input_mac := api.sanitize_general(input_mac);
		input_range_name := api.sanitize_general(input_range_name);
		input_config := api.sanitize_general(input_config);
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);

		SELECT api.create_log_entry('API', 'INFO', 'Creating new address registration');
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier") VALUES
		(input_mac,ip.get_address_from_range(input_range_name),input_config,input_class,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address_auto"() IS 'create a new address on interface from a range';

/*Trigger Function API - delete_interface_address*/
CREATE OR REPLACE FUNCTION "api"."delete_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.delete_interface_address');
		
		input_address := api.sanitize_general(input_address);
		
		SELECT api.create_log_entry('API','INFO','deleting interface address';
		DELETE FROM "systems"."interface_addresses" WHERE "address" = input_address;
	END;
$$ LANGUAGE 'plpgqsql';
COMMENT ON FUNCTION "api"."delete_interface_address"() IS 'delete an interface address';