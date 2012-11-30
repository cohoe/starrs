/* API - modify_system
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_system"(input_old_name text, input_field text, input_new_value text) RETURNS SETOF "systems"."systems" AS $$
	BEGIN
		-- Check privileges
		IF (SELECT "write" FROM api.get_system_permissions(input_old_name)) IS FALSE THEN
			RAISE EXCEPTION 'Permission denied';
		END IF;

		-- Check allowed fields
		IF input_field !~* 'system_name|owner|comment|type|os_name|platform_name|asset|group|datacenter' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record

		EXECUTE 'UPDATE "systems"."systems" SET ' || quote_ident($2) || ' = $3, 
		date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
		WHERE "system_name" = $1' 
		USING input_old_name, input_field, input_new_value;

		-- Done
		PERFORM api.syslog('modify_system:"'||input_old_name||'","'||input_field||'","'||input_new_value||'"');
		IF input_field ~* 'system_name' THEN
			RETURN QUERY (SELECT * FROM "systems"."systems" WHERE "system_name" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "systems"."systems" WHERE "system_name" = input_old_name);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_system"(text,text,text) IS 'Modify an existing system';

/* API - modify_interface
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_interface"(input_old_mac macaddr, input_field text, input_new_value text) RETURNS SETOF "systems"."interfaces" AS $$
	BEGIN

		-- Check privileges
		IF (SELECT "write" FROM api.get_system_permissions((SELECT "system_name" FROM "systems"."interfaces" WHERE "mac" = input_old_mac))) IS FALSE THEN
			RAISE EXCEPTION 'Permission denied';
		END IF;

		-- Check allowed fields
		IF input_field !~* 'mac|comment|system_name|name' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record

		IF input_field ~* 'mac' THEN
			EXECUTE 'UPDATE "systems"."interfaces" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "mac" = $1' 
			H
			USING input_old_mac, input_field, macaddr(input_new_value);
		ELSE
			EXECUTE 'UPDATE "systems"."interfaces" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "mac" = $1' 
			USING input_old_mac, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.syslog('modify_interface:"'||input_old_mac||'","'||input_field||'","'||input_new_value||'"');
		IF input_field ~* 'mac' THEN
			RETURN QUERY (SELECT * FROM "systems"."interfaces" WHERE "mac" = macaddr(input_new_value));
		ELSE
			RETURN QUERY (SELECT * FROM "systems"."interfaces" WHERE "mac" = input_old_mac);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_interface"(macaddr,text,text) IS 'Modify an existing system interface';

/* API - modify_interface_address
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_interface_address"(input_old_address inet, input_field text, input_new_value text) RETURNS SETOF "systems"."interface_addresses" AS $$
	DECLARE
		isprim BOOLEAN;
		primcount INTEGER;
	BEGIN

		-- Check privilegesinput_old_name
		IF (SELECT "write" FROM api.get_system_permissions(api.get_interface_address_system(input_old_address))) IS FALSE THEN
			RAISE EXCEPTION 'Permission denied';
		END IF;

		-- Check allowed fields
		IF input_field !~* 'comment|address|config|isprimary|mac|class|renew_date' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;
		
		-- Check dynamic
		IF api.ip_is_dynamic(input_old_address) IS TRUE THEN
			IF input_field ~* 'config|class' THEN
				RAISE EXCEPTION 'Cannot modify the configuration or class of a dynamic address';
			END IF;
		END IF;

		-- Check for primary
		SELECT "isprimary" INTO isprim FROM "systems"."interface_addresses" WHERE "address" = input_old_address;

		IF input_field ~* 'mac' THEN
			SELECT COUNT(*) INTO primcount FROM "systems"."interface_addresses" WHERE "mac" = input_new_value::macaddr AND "isprimary" IS TRUE;
			IF primcount = 0 THEN
				isprim := TRUE;
			ELSE
				isprim := FALSE;
			END IF;
		END IF;

		IF input_field ~* 'address' THEN
			IF (SELECT "use" FROM "api"."get_ip_ranges"() WHERE "name" = (SELECT "api"."get_address_range"(input_new_value::inet))) ~* 'ROAM' THEN
				RAISE EXCEPTION 'Specified new address (%) is contained within a Dynamic range',input_new_value;
			END IF;
		END IF;

		IF input_field ~* 'renew_date' AND input_new_value IS NULL THEN
			input_new_value := api.get_default_renew_date(api.get_interface_address_system(input_old_address));
		END IF;

		-- Update record

		IF input_field ~* 'mac' THEN
			EXECUTE 'UPDATE "systems"."interface_addresses" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user(), isprimary = $4 
			WHERE "address" = $1' 
			USING input_old_address, input_field, macaddr(input_new_value),isprim;
		ELSIF input_field ~* 'address' THEN
			EXECUTE 'UPDATE "systems"."interface_addresses" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1' 
			USING input_old_address, input_field, inet(input_new_value);
		ELSIF input_field ~* 'isprimary' THEN
			EXECUTE 'UPDATE "systems"."interface_addresses" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1' 
			USING input_old_address, input_field, bool(input_new_value);
		ELSIF input_field ~* 'renew_date' THEN
			EXECUTE 'UPDATE "systems"."interface_addresses" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1' 
			USING input_old_address, input_field, input_new_value::date;
		ELSEIF input_field ~* 'config' THEN
			EXECUTE 'UPDATE "systems"."interface_addresses" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1' 
			USING input_old_address, input_field, input_new_value;
			-- Need to force DNS records to be created
			IF input_new_value ~* 'static' THEN
				UPDATE "dns"."a" SET "address" = input_old_address WHERE "address" = input_old_address;
			END IF;
		ELSE
			EXECUTE 'UPDATE "systems"."interface_addresses" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1' 
			USING input_old_address, input_field, input_new_value;
		END IF;
		
		-- Done
		PERFORM api.syslog('modify_interface_address:"'||input_old_address||'","'||input_field||'","'||input_new_value||'"');
		IF input_field ~* 'address' THEN
			RETURN QUERY (SELECT * FROM "systems"."interface_addresses" WHERE "address" = inet(input_new_value));
		ELSE
			RETURN QUERY (SELECT * FROM "systems"."interface_addresses" WHERE "address" = input_old_address);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_interface_address"(inet,text,text) IS 'Modify an existing interface address';

CREATE OR REPLACE FUNCTION "api"."modify_datacenter"(input_old_name text, input_field text, input_new_value text) RETURNS SETOF "systems"."datacenters" AS $$
	BEGIN

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to edit address % denied. You are not admin';
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'datacenter|comment' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;
		
		-- Update record

		EXECUTE 'UPDATE "systems"."datacenters" SET ' || quote_ident($2) || ' = $3, 
		date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
		WHERE "datacenter" = $1' 
		USING input_old_name, input_field, input_new_value;

		-- Done

		PERFORM api.syslog('modify_datacenter:"'||input_old_name||'","'||input_field||'","'||input_new_value||'"');
		IF input_field ~* 'datacenter' THEN
			RETURN QUERY (SELECT * FROM "systems"."datacenters" WHERE "datacenter" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "systems"."datacenters" WHERE "datacenter" = input_old_name);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_datacenter"(text, text, text) IS 'modify a datacenter';


CREATE OR REPLACE FUNCTION "api"."modify_availability_zone"(input_old_datacenter text, input_old_zone text, input_field text, input_new_value text) RETURNS SETOF "systems"."availability_zones" AS $$
	BEGIN

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to edit availability zone denied. You are not admin';
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'datacenter|zone|comment' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;
		
		-- Update record

		EXECUTE 'UPDATE "systems"."availability_zones" SET ' || quote_ident($3) || ' = $4, 
		date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
		WHERE "datacenter" = $1 AND "zone" = $2' 
		USING input_old_datacenter, input_old_zone, input_field, input_new_value;

		-- Done

		PERFORM api.syslog('modify_availability_zone:"'||input_old_datacenter||'","'||input_old_zone||'","'||input_field||'","'||input_new_value||'"');
		IF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "systems"."availability_zones" WHERE "datacenter" = input_old_datacenter AND "zone" = input_new_value);
		ELSEIF input_field ~* 'datacenter' THEN
			RETURN QUERY (SELECT * FROM "systems"."availability_zones" WHERE "datacenter" = input_new_value AND "zone" = input_old_zone);
		ELSE
			RETURN QUERY (SELECT * FROM "systems"."availability_zones" WHERE "datacenter" = input_old_datacenter AND "zone" = input_old_zone);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_availability_zone"(text, text, text, text) IS 'modify a availability_zone';

CREATE OR REPLACE FUNCTION "api"."modify_platform"(input_old_name text, input_field text, input_new_value TEXT) RETURNS SETOF "systems"."platforms" AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to edit platform denied. You are not admin';
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'platform_name|architecture|disk|cpu|memory' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		IF input_field ~* 'memory' THEN
			EXECUTE 'UPDATE "systems"."platforms" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "platform_name" = $1' 
			USING input_old_name, input_field, input_new_value::integer;
		ELSE
			EXECUTE 'UPDATE "systems"."platforms" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "platform_name" = $1' 
			USING input_old_name, input_field, input_new_value;
		END IF;

		PERFORM api.syslog('modify_platform:"'||input_old_name||'","'||input_field||'","'||input_new_value||'"');
		IF input_field ~* 'platform_name' THEN
			RETURN QUERY (SELECT * FROM "systems"."platforms" WHERE "platform_name" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "systems"."platforms" WHERE "platform_name" = input_old_name);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_platform"(text, text, text) IS 'Modify a hardware platform';
