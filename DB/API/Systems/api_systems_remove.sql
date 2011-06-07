/* api_systems_remove.sql
	1) remove_system
	2) remove_interface
	3) remove_interface_address
*/

/* API - remove_system
	1) Check privileges
	2) Remove system
*/
CREATE OR REPLACE FUNCTION "api"."remove_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_system');
		
		-- Check privileges
		IF api.get_current_user_level() ~* 'USER|PROGRAM' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;
		
		-- Remove system
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting system');
		DELETE FROM "systems"."systems" WHERE "system_name" = input_system_name;
		
		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.remove_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_system"(text) IS 'Delete an existing system';

/* API - remove_interface
	1) Check privileges
	2) Remove interface
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface"(input_mac macaddr) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_interface');
		
		-- Check privileges
		IF api.get_current_user_level() ~* 'USER|PROGRAM' THEN
			IF (SELECT "owner" FROM "systems"."interfaces" 
			JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
			WHERE "system_name" = input_mac) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface %. You are not owner.',input_mac;
			END IF;
		END IF;
		
		-- Remove interface
		PERFORM api.create_log_entry('API','INFO','deleting interface');
		DELETE FROM "systems"."interfaces" WHERE "mac" = input_mac;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_interface');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_interface"(macaddr) IS 'delete an interface based on MAC address';

/* API - remove_interface_address
	1) Check privileges
	2) Remove address
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_interface_address');
		
		-- Check privileges
		IF api.get_current_user_level() ~* 'USER|PROGRAM' THEN
			IF (SELECT "owner" FROM "systems"."interfaces" 
			JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
			WHERE "system_name" = input_mac) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface address %. You are not owner.',input_address;
			END IF;
		END IF;
		
		-- Remove address
		PERFORM api.create_log_entry('API','INFO','deleting interface address');
		DELETE FROM "systems"."interface_addresses" WHERE "address" = input_address;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_interface_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_interface_address"(inet) IS 'delete an interface address';