CREATE OR REPLACE FUNCTION "api"."create_network_snmp"(input_system text, input_address inet, input_ro text, input_rw text) RETURNS SETOF "network"."snmp" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_network_snmp');
		
		-- Match address against system
		IF(api.get_interface_address_system(input_address) != input_system) THEN
			RAISE EXCEPTION 'Address % is not a part of the system %',input_address,input_system;
		END IF;
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied: you are not owner';
			END IF;
		END IF;
		
		-- Create it
		PERFORM api.create_log_entry('API','INFO','Creating snmp credentials');
		INSERT INTO "network"."snmp" ("system_name","address","ro_community","rw_community") 
		VALUES (input_system, input_address, input_ro, input_rw);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','end api.create_network_snmp');
		RETURN QUERY (SELECT * FROM "network"."snmp" WHERE "system_name" = input_system);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_network_snmp"(text, inet, text, text) IS 'Create a set of credentials for a system';
