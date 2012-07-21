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
CREATE OR REPLACE FUNCTION "api"."create_system"(input_system_name text, input_owner text, input_type text, input_os_name text, input_comment text, input_group text, input_platform text, input_asset text, input_datacenter text) RETURNS SETOF "systems"."systems" AS $$
	BEGIN
		-- Validate input
		input_system_name := api.validate_name(input_system_name);

		-- Fill in username
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Insert new system
		INSERT INTO "systems"."systems"
			("system_name","owner","type","os_name","comment","last_modifier","group","platform_name","asset","datacenter") VALUES
			(input_system_name,input_owner,input_type,input_os_name,input_comment,api.get_current_user(),input_group,input_platform,input_asset,input_datacenter);

		-- Done
		RETURN QUERY (SELECT * FROM "systems"."systems" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_system"(text, text, text, text, text, text, text, text, text) IS 'Create a new system';

/* API - create_interface
	1) Check privileges
	2) Create interface
*/
CREATE OR REPLACE FUNCTION "api"."create_interface"(input_system_name text, input_mac macaddr, input_name text, input_comment text) RETURNS SETOF "systems"."interfaces" AS $$
	BEGIN

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;
		
		-- Validate input
		input_name := api.validate_name(input_name);

		-- Create interface
		INSERT INTO "systems"."interfaces"
		("system_name","mac","comment","last_modifier","name") VALUES
		(input_system_name,input_mac,input_comment,api.get_current_user(),input_name);

		-- Done
		RETURN QUERY (SELECT * FROM "systems"."interfaces" WHERE "mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface"(text, macaddr, text, text) IS 'Create a new interface on a system';

/* API - create_interface_address
	1) Check privileges
	2) Fill in class
	3) Create address
*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address"(input_mac macaddr, input_address inet, input_config text, input_class text, input_isprimary boolean, input_comment text, input_renew_date date) RETURNS SETOF "systems"."interface_addresses" AS $$
	BEGIN
		-- Renew
		IF input_renew_date IS NULL THEN
			input_renew_date := api.get_default_renew_date();
		END IF;

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."interfaces" 
			JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
			WHERE "systems"."interfaces"."mac" = input_mac) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface %. You are not owner.',input_mac;
			END IF;

			IF input_renew_date != api.get_default_renew_date() THEN
				RAISE EXCEPTION 'Only administrators can specify a different renew date';
			END IF;
		END IF;

		-- Fill in class
		IF input_class IS NULL THEN
			input_class = api.get_site_configuration('DHCPD_DEFAULT_CLASS');
		END IF;

		IF input_address << cidr(api.get_site_configuration('DYNAMIC_SUBNET')) AND input_config !~* 'dhcp' THEN
			RAISE EXCEPTION 'Specifified address (%) is only for dynamic DHCP addresses',input_address;
		END IF;

		IF (SELECT "use" FROM "api"."get_ip_ranges"() WHERE "name" = (SELECT "api"."get_address_range"(input_address))) ~* 'ROAM' THEN
			RAISE EXCEPTION 'Specified address (%) is contained within a Dynamic range',input_address;
		END IF;

		-- Create address
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier","isprimary","renew_date") VALUES
		(input_mac,input_address,input_config,input_class,input_comment,api.get_current_user(),input_isprimary,input_renew_date);

		-- Done
		RETURN QUERY (SELECT * FROM "systems"."interface_addresses" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address"(macaddr, inet, text, text, boolean, text, date) IS 'create a new address on interface from a specified address';

CREATE OR REPLACE FUNCTION "api"."create_system_quick"(input_system_name text, input_owner text, input_group text, input_mac macaddr, input_address inet, input_zone text, input_config text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_system(
			input_system_name,
			input_owner,
			api.get_site_configuration('DEFAULT_SYSTEM_TYPE'),
			'Other',
			null,
			input_group,
			api.get_site_configuration('DEFAULT_SYSTEM_PLATFORM'),
			null,
			api.get_site_configuration('DEFAULT_DATACENTER')
		);
		PERFORM api.create_interface(
			input_system_name,
			input_mac,
			api.get_site_configuration('DEFAULT_INTERFACE_NAME'),
			null
		);
		PERFORM api.create_interface_address(
			input_mac,
			input_address,
			input_config,
			api.get_site_configuration('DHCPD_DEFAULT_CLASS'),
			TRUE,
			null,
			null
		);
		PERFORM api.create_dns_address(
			input_address,
			input_system_name,
			input_zone,
			null,
			null,
			TRUE,
			input_owner
		);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_system_quick"(text, text, text, macaddr, inet, text, text) IS 'Create a full system in one call';

CREATE OR REPLACE FUNCTION "api"."create_datacenter"(input_name text, input_comment text) RETURNS SETOF "systems"."datacenters" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied to create datacenter: not admin';
		END IF;
		
		-- Create datacenter
		INSERT INTO "systems"."datacenters" ("datacenter","comment") VALUES (input_name,input_comment);

		-- Done
		RETURN QUERY (SELECT * FROM "systems"."datacenters" WHERE "datacenter" = input_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_datacenter"(text, text) IS 'Create a new datacenter';

CREATE OR REPLACE FUNCTION "api"."create_availability_zone"(input_datacenter text, input_zone text, input_comment text) RETURNS SETOF "systems"."availability_zones" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied to create availability zone: not admin';
		END IF;
		
		-- Create availability_zones
		INSERT INTO "systems"."availability_zones" ("datacenter","zone","comment") VALUES (input_datacenter, input_zone, input_comment);

		-- Done
		RETURN QUERY (SELECT * FROM "systems"."availability_zones" WHERE "datacenter" = input_datacenter AND "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_availability_zone"(text, text, text) IS 'Create a new availability zone';

CREATE OR REPLACE FUNCTION "api"."create_platform"(input_name text, input_architecture text, input_disk text, input_cpu text, input_memory integer) RETURNS SETOF "systems"."platforms" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied to create platform: not admin';
		END IF;

		INSERT INTO "systems"."platforms" ("platform_name","architecture","disk","cpu","memory")
		VALUES (input_name, input_architecture, input_disk, input_cpu, input_memory);

		RETURN QUERY (SELECT * FROM "systems"."platforms" WHERE "platform_name" = input_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_platform"(text, text, text, text, integer) IS 'Create a new hardware platform';
