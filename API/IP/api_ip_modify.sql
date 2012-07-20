/* api_ip_modify.sql
	1) modify_ip_range
	2) modify_ip_subnet
*/

/* API - modify_ip_range
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_ip_range"(input_old_name text, input_field text, input_new_value text) RETURNS SETOF "ip"."ranges" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_ip_range');

		-- Check privileges		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission to modify range (%). Not admin.',input_old_name;
		END IF;

		-- Check allowed fields
		IF input_field !~* 'first_ip|last_ip|comment|use|name|subnet|class|zone' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update IP range');

		IF input_field ~* 'first_ip|last_ip' THEN
			EXECUTE 'UPDATE "ip"."ranges" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "name" = $1' 
			USING input_old_name, input_field, inet(input_new_value);	
		ELSIF input_field ~* 'subnet' THEN
			EXECUTE 'UPDATE "ip"."ranges" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "name" = $1' 
			USING input_old_name, input_field, cidr(input_new_value);	
		ELSE
			EXECUTE 'UPDATE "ip"."ranges" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "name" = $1' 
			USING input_old_name, input_field, input_new_value;	
		END IF;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_ip_range');
		IF input_field ~* 'name' THEN
			RETURN QUERY (SELECT * FROM "ip"."ranges" WHERE "name" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "ip"."ranges" WHERE "name" = input_old_name);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_ip_range"(text, text, text) IS 'Modify an IP range';

/* API - modify_ip_subnet
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_ip_subnet"(input_old_subnet cidr, input_field text, input_new_value text) RETURNS SETOF "ip"."subnets" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_ip_subnet');

		-- Check privileges		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "ip"."subnets" WHERE "subnet" = input_old_subnet) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied - not owner');
				RAISE EXCEPTION 'Permission to edit subnet % denied. You are not owner',input_old_subnet;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'subnet|comment|autogen|name|owner|zone|dhcp_enable|datacenter|vlan' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update IP subnet');

		IF input_field ~* 'dhcp_enable|autogen' THEN
			EXECUTE 'UPDATE "ip"."subnets" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "subnet" = $1' 
			USING input_old_subnet, input_field, bool(input_new_value);	
		ELSIF input_field ~* 'subnet' THEN
			EXECUTE 'UPDATE "ip"."subnets" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "subnet" = $1' 
			USING input_old_subnet, input_field, cidr(input_new_value);	
		ELSIF input_field ~* 'vlan' THEN
			EXECUTE 'UPDATE "ip"."subnets" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "subnet" = $1' 
			USING input_old_subnet, input_field, input_new_value::integer;	
		ELSE
			EXECUTE 'UPDATE "ip"."subnets" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "subnet" = $1' 
			USING input_old_subnet, input_field, input_new_value;	
		END IF;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_ip_subnet');
		IF input_field ~* 'subnet' THEN
			RETURN QUERY (SELECT * FROM "ip"."subnets" WHERE "subnet" = cidr(input_new_value));
		ELSE
			RETURN QUERY (SELECT * FROM "ip"."subnets" WHERE "subnet" = input_old_subnet);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_ip_subnet"(cidr, text, text) IS 'Modify an IP subnet';
