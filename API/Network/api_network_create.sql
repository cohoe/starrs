CREATE OR REPLACE FUNCTION "api"."create_network_snmp"(input_system text, input_address inet, input_ro text, input_rw text) RETURNS SETOF "network"."snmp" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_network_snmp');

		-- Address
		IF input_address IS NULL THEN
			input_address := api.get_system_primary_address(input_system);
		END IF;
		
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

CREATE OR REPLACE FUNCTION "api"."create_vlan"(input_datacenter text, input_vlan integer, input_name text, input_comment text) RETURNS SETOF "network"."vlans" AS $$
     BEGIN
          IF api.get_current_user_level() !~* 'ADMIN' THEN
               RAISE EXCEPTION 'Only admins can create VLANs';
          END IF;

          INSERT INTO "network"."vlans" ("datacenter","vlan","name","comment")
          VALUES (input_datacenter, input_vlan, input_name, input_comment);

          RETURN QUERY (SELECT * FROM "network"."vlans" WHERE "datacenter" = input_datacenter AND "vlan" = input_vlan);
     END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_vlan"(text, integer, text, text) IS 'Create a VLAN';
