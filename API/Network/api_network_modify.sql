CREATE OR REPLACE FUNCTION "api"."modify_network_snmp"(input_old_system text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_network_snmp');
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_old_system) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied: you are not owner';
			END IF;
		END IF;
		
		-- Check fields
		IF input_field !~* 'ro_community|rw_community|system_name|address' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;
		
		IF input_field ~* 'address' THEN
			IF(api.get_interface_address_system(input_new_value::inet) != input_old_system) THEN
				RAISE EXCEPTION 'Address % is not a part of the system %',input_new_value,input_old_system;
			END IF;

	   		IF input_new_value::inet << api.get_site_configuration('DYNAMIC_SUBNET')::cidr THEN
				RAISE EXCEPTION 'System address cannot be dynamic';
	          END IF;
		END IF;
		
		-- Mod it
		PERFORM api.create_log_entry('API','INFO','Modifying snmp credentials');
		IF input_field  ~* 'address' THEN
			EXECUTE 'UPDATE "network"."snmp" SET ' || quote_ident($2) || ' = $3
			WHERE "system_name" = $1'
			USING input_old_system, input_field, input_new_value::inet;
		ELSE
			EXECUTE 'UPDATE "network"."snmp" SET ' || quote_ident($2) || ' = $3
			WHERE "system_name" = $1'
			USING input_old_system, input_field, input_new_value;
		END IF;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','end api.modify_network_snmp');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_network_snmp"(text, text, text) IS 'Modify credentials for a system';

/* API - modify_network_switchport
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_network_switchport"(input_old_system text, input_old_port text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_network_switchport');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_old_system) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission to edit port % on system % denied. You are not owner',input_old_system, input_old_port;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'port_name|description|type' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update switchport');

		EXECUTE 'UPDATE "network"."switchports" SET ' || quote_ident($3) || ' = $4, 
		date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
		WHERE "system_name" = $1 AND "port_name" = $2' 
		USING input_old_system, input_old_port, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_network_switchport');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_network_switchport"(text, text, text, text) IS 'Modify an existing network switchport';

/* API - modify_system_switchview
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_system_switchview"(input_system_name text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_system_switchview');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;
		
		-- Check allowed fields
		IF input_field !~* 'enable|snmp_ro_community|snmp_rw_community' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Create settings
		IF input_field  ~* 'community' THEN
			EXECUTE 'UPDATE "network"."switchview" SET ' || quote_ident($2) || ' = $3
			WHERE "system_name" = $1'
			USING input_system_name, input_field, input_new_value;
		ELSE
			EXECUTE 'UPDATE "network"."switchview" SET ' || quote_ident($2) || ' = $3
			WHERE "system_name" = $1'
			USING input_system_name, input_field, bool(input_new_value);
		END IF;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_system_switchview');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_system_switchview"(text, text, text) IS 'Modify switchview on a system';

/* API - modify_switchport_admin_state
	1) Check privileges
	2) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_switchport_admin_state"(input_system_name text, input_port_name text, input_state boolean) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_switchport_admin_state');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission to edit port % on system % denied. You are not owner',input_port_name, input_system_name;
			END IF;
 		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update switchport');
		UPDATE "network"."switchports" SET "date_modified"=localtimestamp(0), "last_modifier"=api.get_current_user()
		WHERE "system_name" = input_system_name AND "port_name" = input_port_name;
		UPDATE "network"."switchport_states" SET "admin_state" = input_state WHERE "system_name" = input_system_name AND "port_name" = input_port_name;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_network_switchport');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_switchport_admin_state"(text, text, boolean) IS 'Set the administrative state of a switchport';




CREATE OR REPLACE FUNCTION "api"."modify_vlan"(input_old_datacenter text, input_old_vlan integer, input_field text, input_new_value text) RETURNS SETOF "network"."vlans" AS $$
     BEGIN
          IF api.get_current_user_level() !~* 'ADMIN' THEN
               RAISE EXCEPTION 'Only admins can create VLANs';
          END IF;

          IF input_field !~* 'datacenter|vlan|name|comment' THEN
               RAISE EXCEPTION 'Invalid field %',input_field;
          END IF;

          IF input_field ~* 'vlan' THEN
               EXECUTE 'UPDATE "network"."vlans" SET ' || quote_ident($3) || ' = $4,
               date_modified = localtimestamp(0), last_modifier = api.get_current_user()
               WHERE "datacenter" = $1 AND "vlan" = $2'
               USING input_old_datacenter, input_old_vlan, input_field, input_new_value::integer;
          ELSE
               EXECUTE 'UPDATE "network"."vlans" SET ' || quote_ident($3) || ' = $4,
               date_modified = localtimestamp(0), last_modifier = api.get_current_user()
               WHERE "datacenter" = $1 AND "vlan" = $2'
               USING input_old_datacenter, input_old_vlan, input_field, input_new_value;
          END IF;

          IF input_field ~* 'datacenter' THEN
               RETURN QUERY (SELECT * FROM "network"."vlans" WHERE "datacenter" = input_new_value AND "vlan" = input_old_vlan);
          ELSEIF input_field ~* 'vlan' THEN
               RETURN QUERY (SELECT * FROM "network"."vlans" WHERE "datacenter" = input_old_datacenter AND "vlan" = input_new_value::integer);
          ELSE
               RETURN QUERY (SELECT * FROM "network"."vlans" WHERE "datacenter" = input_old_datacenter AND "vlan" = input_old_vlan);
          END IF;
     END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_vlan"(text, integer, text, text) IS 'Modify a VLAN';
