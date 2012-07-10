/* api_systems_create
	1) create_system
	2) create_interface
	3) create_interface_address
*/

/* API - create_system
	1) Check privileges
	2) Validate input
	3) Fill in username
	4) Check privileges
	5) Insert new system
*/
CREATE OR REPLACE FUNCTION "api"."create_system"(input_system_name text, input_owner text, input_type text, input_os_name text, input_comment text, input_group text, input_platform text, input_asset text) RETURNS SETOF "systems"."systems" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_system');

		-- Validate input
		input_system_name := api.validate_name(input_system_name);

		-- Fill in username
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF input_owner != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Insert new system
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new system');
		INSERT INTO "systems"."systems"
			("system_name","owner","type","os_name","comment","last_modifier","group","platform_name","asset") VALUES
			(input_system_name,input_owner,input_type,input_os_name,input_comment,api.get_current_user(),input_group,input_platform,input_asset);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_system');
		RETURN QUERY (SELECT * FROM "systems"."systems" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_system"(text, text, text, text, text, text, text, text) IS 'Create a new system';

/* API - create_interface
	1) Check privileges
	2) Create interface
*/
CREATE OR REPLACE FUNCTION "api"."create_interface"(input_system_name text, input_mac macaddr, input_name text, input_comment text) RETURNS SETOF "systems"."interfaces" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_interface');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;
		
		-- Validate input
		input_name := api.validate_name(input_name);

		-- Create interface
		PERFORM api.create_log_entry('API','INFO','creating new interface');
		INSERT INTO "systems"."interfaces"
		("system_name","mac","comment","last_modifier","name") VALUES
		(input_system_name,input_mac,input_comment,api.get_current_user(),input_name);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_interface');
		RETURN QUERY (SELECT * FROM "systems"."interfaces" WHERE "mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface"(text, macaddr, text, text) IS 'Create a new interface on a system';

/* API - create_interface_address
	1) Check privileges
	2) Fill in class
	3) Create address
*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address"(input_mac macaddr, input_address inet, input_config text, input_class text, input_isprimary boolean, input_comment text) RETURNS SETOF "systems"."interface_addresses" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."interfaces" 
			JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
			WHERE "systems"."interfaces"."mac" = input_mac) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied on interface %. You are not owner.',input_mac;
			END IF;
		END IF;

		-- Fill in class
		IF input_class IS NULL THEN
			input_class = api.get_site_configuration('DHCPD_DEFAULT_CLASS');
		END IF;

		IF input_address << cidr(api.get_site_configuration('DYNAMIC_SUBNET')) AND input_config !~* 'dhcp' THEN
			PERFORM api.create_log_entry('API','ERROR','Specified address is only for dynamic addressing');
			RAISE EXCEPTION 'Specifified address (%) is only for dynamic DHCP addresses',input_address;
		END IF;

		IF (SELECT "use" FROM "api"."get_ip_range"((SELECT "api"."get_address_range"(input_address)))) ~* 'ROAM' THEN
			PERFORM api.create_log_entry('API','ERROR','Specified address is contained within Dynamic range');
			RAISE EXCEPTION 'Specified address (%) is contained within a Dynamic range',input_address;
		END IF;

		-- Create address
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new address');
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier","isprimary") VALUES
		(input_mac,input_address,input_config,input_class,input_comment,api.get_current_user(),input_isprimary);

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.create_interface_address');
		RETURN QUERY (SELECT * FROM "systems"."interface_addresses" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address"(macaddr, inet, text, text, boolean, text) IS 'create a new address on interface from a specified address';

CREATE OR REPLACE FUNCTION "api"."create_system_quick"(input_system_name text, input_os_name text, input_mac macaddr, input_address inet, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_system(input_system_name, input_owner, 'Desktop', input_os_name, null);
		PERFORM api.create_interface(input_system_name, input_mac, 'Main Interface', null);
		PERFORM api.create_interface_address(input_mac, input_address, 'dhcp', null, true, null);
		PERFORM api.create_dns_address(input_address, lower(regexp_replace(input_system_name,' ','-')), null, null, input_owner);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_system_quick"(text, text, macaddr, inet, text) IS 'Create a barebones system';
