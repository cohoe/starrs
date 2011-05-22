/* API - create_system
	1) Check privileges
	2) Sanitize input
	3) Fill in username
	4) Insert new system
*/
CREATE OR REPLACE FUNCTION "api"."create_system"(input_system_name text, input_username text, input_type text, input_os_name text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.create_system');
		-- Sanitize input
		input_system_name := api.sanitize_general(input_system_name);
		input_username := api.sanitize_general(input_username);
		input_comment := api.sanitize_general(input_comment);

		-- Fill in username
		IF input_username IS NULL THEN
			input_username := api.get_current_user();
		END IF;
		
		-- Insert new system
		SELECT api.create_log_entry('API', 'INFO', 'Creating new system');
		INSERT INTO "systems"."systems"
			("system_name","username","type","os_name","comment","last_modifier") VALUES
			(input_system_name,input_username,input_type,input_os_name,input_comment,api.get_current_user());
			
		SELECT api.create_log_entry('API','DEBUG','finish api.create_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_system"() IS 'Create a new system';

/* API - remove_system
	1) Check privileges
	2) Sanitize input
	3) Remove system
*/
CREATE OR REPLACE FUNCTION "api"."remove_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.remove_system');
		
		-- Sanitize input
		input_system_name := api.sanitize_general(input_system_name);
		
		-- Remove system
		SELECT api.create_log_entry('API', 'INFO', 'Deleting system');
		DELETE FROM "systems"."systems" WHERE "system_name" = input_system_name;
		
		SELECT api.create_log_entry('API', 'DEBUG', 'finish api.remove_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_system"() IS 'Delete an existing system';

/* API - create_interface
	1) Check privileges
	2) Sanitize input
	3) Create interface
*/
CREATE OR REPLACE FUNCTION "api"."create_interface"(input_system_name text, input_interface_name text, input_mac macaddr, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.create_interface');
		
		-- Sanitize input
		input_system_name := api.sanitize_general(input_system_name);
		input_interface_name := api.sanitize_general(input_interface_name);
		input_mac := api.sanitize_general(input_mac);
		input_comment := api.sanitize_general(input_comment);
		
		-- Create interface
		SELECT api.create_log_entry('API','INFO','creating new interface';
		INSERT INTO "systems"."interfaces"
		("system_name","interface_name","mac","comment","last_modifier") VALUES
		(input_system_name,input_interface_name,input_mac,input_comment,api.get_current_user());
		
		SELECT api.create_log_entry('API','DEBUG','finish api.create_interface');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface"() IS 'Create a new interface on a system';

/* API - remove_interface
	1) Check privileges
	2) Sanitize input
	3) Remove interface
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface"(input_mac macaddr) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.remove_interface');
		
		-- Sanitize input
		input_mac := api.sanitize_general(input_mac);
		
		-- Remove interface
		SELECT api.create_log_entry('API','INFO','deleting interface';
		DELETE FROM "systems"."interfaces" WHERE "mac" = input_mac;
		
		SELECT api.create_log_entry('API','DEBUG','finish api.remove_interface');
	END;
$$ LANGUAGE 'plpgqsql';
COMMENT ON FUNCTION "api"."remove_interface"() IS 'delete an interface based on MAC address';

/* API - create_interface_address_manual
	1) Check privileges
	2) Sanitize input
	3) Create address
*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address_manual"(input_mac macaddr, input_address inet, input_config text, input_class text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address_manual');
		
		-- Sanitize input
		input_mac := api.sanitize_general(input_mac);
		input_address := api.sanitize_general(input_address);
		input_config := api.sanitize_general(input_config);
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);
		
		-- Create address
		SELECT api.create_log_entry('API', 'INFO', 'Creating new address');
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier") VALUES
		(input_mac,input_address,input_config,input_class,input_comment,api.get_current_user());
		
		SELECT api.create_log_entry('API', 'DEBUG', 'finish api.create_interface_address_manual');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address_manual"() IS 'create a new address on interface manually';

/* API - create_interface_address_auto
	1) Check privileges
	2) Sanitize input
	3) Create address
*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address_auto"(input_mac macaddr, input_range_name text, input_config text, input_class text, input_comment text) RETURNS VOID AS $$
	DECLARE
		Address INET;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address_range');
		
		-- Sanitize input
		input_mac := api.sanitize_general(input_mac);
		input_range_name := api.sanitize_general(input_range_name);
		input_config := api.sanitize_general(input_config);
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);

		-- Create address
		SELECT api.create_log_entry('API', 'INFO', 'Creating new address registration');
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier") VALUES
		(input_mac,ip.get_address_from_range(input_range_name),input_config,input_class,input_comment,api.get_current_user());
		
		SELECT api.create_log_entry('API', 'DEBUG', 'finish api.create_interface_address_range');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address_auto"() IS 'create a new address on interface from a range';

/* API - remove_interface_address
	1) Check privileges
	2) Sanitize input
	3) Remove address
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.remove_interface_address');
		
		-- Sanitize input
		input_address := api.sanitize_general(input_address);
		
		-- Remove address
		SELECT api.create_log_entry('API','INFO','deleting interface address';
		DELETE FROM "systems"."interface_addresses" WHERE "address" = input_address;
		
		SELECT api.create_log_entry('API','DEBUG','begin api.remove_interface_address');
	END;
$$ LANGUAGE 'plpgqsql';
COMMENT ON FUNCTION "api"."remove_interface_address"() IS 'delete an interface address';
