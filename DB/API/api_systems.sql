/* API - create_system
	1) Check privileges
	2) Sanitize input
	3) Fill in username
	4) Insert new system
*/
CREATE OR REPLACE FUNCTION "api"."create_system"(input_system_name text, input_owner text, input_type text, input_os_name text, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_system');
		-- Sanitize input
		input_system_name := api.sanitize_general(input_system_name);
		input_owner := api.sanitize_general(input_owner);
		input_comment := api.sanitize_general(input_comment);

		-- Fill in username
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;
		
		-- Insert new system
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new system');
		INSERT INTO "systems"."systems"
			("system_name","owner","type","os_name","comment","last_modifier") VALUES
			(input_system_name,input_owner,input_type,input_os_name,input_comment,api.get_current_user());
			
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_system"(text, text, text, text, text) IS 'Create a new system';

/* API - remove_system
	1) Check privileges
	2) Sanitize input
	3) Remove system
*/
CREATE OR REPLACE FUNCTION "api"."remove_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_system');
		
		-- Sanitize input
		input_system_name := api.sanitize_general(input_system_name);
		
		-- Remove system
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting system');
		DELETE FROM "systems"."systems" WHERE "system_name" = input_system_name;
		
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.remove_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_system"(text) IS 'Delete an existing system';

/* API - create_interface
	1) Check privileges
	2) Sanitize input
	3) Create interface
*/
CREATE OR REPLACE FUNCTION "api"."create_interface"(input_system_name text, input_mac macaddr, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_interface');
		
		-- Sanitize input
		input_system_name := api.sanitize_general(input_system_name);
		input_comment := api.sanitize_general(input_comment);
		
		-- Create interface
		PERFORM api.create_log_entry('API','INFO','creating new interface');
		INSERT INTO "systems"."interfaces"
		("system_name","mac","comment","last_modifier") VALUES
		(input_system_name,input_mac,input_comment,api.get_current_user());
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_interface');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface"(text, macaddr, text) IS 'Create a new interface on a system';

/* API - remove_interface
	1) Check privileges
	2) Remove interface
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface"(input_mac macaddr) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_interface');
		
		-- Remove interface
		PERFORM api.create_log_entry('API','INFO','deleting interface');
		DELETE FROM "systems"."interfaces" WHERE "mac" = input_mac;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_interface');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_interface"(macaddr) IS 'delete an interface based on MAC address';

/* API - create_interface_address_manual
	1) Check privileges
	2) Sanitize input
	3) Fill in class
	4) Create address
*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address"(input_mac macaddr, input_name text, input_address inet, input_config text, input_class text, input_isprimary boolean, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address_manual');
		
		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		input_config := api.sanitize_general(input_config);
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);
		
		-- Fill in class
		IF input_class IS NULL THEN
			input_class = api.get_dhcp_site_default_class();
		END IF;
		
		IF input_address << cidr(api.get_site_configuration('DYNAMIC_SUBNET')) AND input_config !~* 'dhcp' THEN
			RAISE EXCEPTION 'Specifified address (%) is only for dynamic DHCP addresses',input_address;
		END IF;
		
		-- Create address
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new address');
		INSERT INTO "systems"."interface_addresses" ("mac","name","address","config","class","comment","last_modifier","isprimary") VALUES
		(input_mac,input_name,input_address,input_config,input_class,input_comment,api.get_current_user(),input_isprimary);
		
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.create_interface_address_manual');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address"(macaddr, text, inet, text, text, boolean, text) IS 'create a new address on interface from a specified address';

/* API - remove_interface_address
	1) Check privileges
	2) Remove address
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_interface_address');
		
		-- Remove address
		PERFORM api.create_log_entry('API','INFO','deleting interface address');
		DELETE FROM "systems"."interface_addresses" WHERE "address" = input_address;
		
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_interface_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_interface_address"(inet) IS 'delete an interface address';
