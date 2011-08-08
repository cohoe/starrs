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
				RAISE EXCEPTION 'Permission to edit port % on system % denied. You are not owner',input_old_system, input_old_port;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'port_name|description|type' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update switchport');

		EXECUTE 'UPDATE "network"."switchports" SET ' || quote_ident($3) || ' = $4, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
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
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;
		
		-- Check allowed fields
		IF input_field !~* 'enable|snmp_ro_community|snmp_rw_community' THEN
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