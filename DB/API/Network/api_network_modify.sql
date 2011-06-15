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