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
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;

		-- Remove system
		DELETE FROM "systems"."systems" WHERE "system_name" = input_system_name;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_system"(text) IS 'Delete an existing system';

/* API - remove_interface
	1) Check privileges
	2) Remove interface
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface"(input_mac macaddr) RETURNS VOID AS $$
	BEGIN

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."interfaces" 
			JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
			WHERE "systems"."interfaces"."mac" = input_mac) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface %. You are not owner.',input_mac;
			END IF;
		END IF;

		-- Remove interface
		DELETE FROM "systems"."interfaces" WHERE "mac" = input_mac;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_interface"(macaddr) IS 'delete an interface based on MAC address';

/* API - remove_interface_address
	1) Check privileges
	2) Remove address
*/
CREATE OR REPLACE FUNCTION "api"."remove_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."interface_addresses" 
			JOIN "systems"."interfaces" ON "systems"."interfaces"."mac" = "systems"."interface_addresses"."mac"
			JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
			WHERE "systems"."interface_addresses"."address" = input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface address %. You are not owner.',input_address;
			END IF;
		END IF;

		-- Remove address
		DELETE FROM "systems"."interface_addresses" WHERE "address" = input_address;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_interface_address"(inet) IS 'delete an interface address';

CREATE OR REPLACE FUNCTION "api"."remove_users_systems"(username text) RETURNS VOID AS $$
	BEGIN
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied: Only admins can remove all systems from a user';
		END IF;
		
		-- Perform delete
		DELETE FROM "systems"."systems" WHERE "owner" = username;
		
		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_users_systems"(text) IS 'Remove all systems owned by a user';

CREATE OR REPLACE FUNCTION "api"."remove_datacenter"(input_name text) RETURNS VOID AS $$
	BEGIN
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied: Only admins can remove datacenters';
		END IF;
		
		-- Perform delete
		DELETE FROM "systems"."datacenters" WHERE "datacenter" = input_name;
		
		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_datacenter"(text) IS 'remove a datacenter';

CREATE OR REPLACE FUNCTION "api"."remove_availability_zone"(input_datacenter text, input_zone text) RETURNS VOID AS $$
	BEGIN
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied: Only admins can remove availability_zones';
		END IF;
		
		-- Perform delete
		DELETE FROM "systems"."availability_zones" WHERE "datacenter" = input_datacenter AND "zone" = input_zone;
		
		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_availability_zone"(text, text) IS 'Remove an availability zone';

CREATE OR REPLACE FUNCTION "api"."remove_platform"(input_name text) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied: Only admins can remove platforms'; 
		END IF;

		DELETE FROM "systems"."platforms" WHERE "platform_name" = input_name;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_platform"(text) IS 'Remove a platform';
