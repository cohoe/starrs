CREATE OR REPLACE FUNCTION "api"."remove_network_snmp"(input_system text) RETURNS VOID AS $$
	BEGIN
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied: you are not owner';
			END IF;
		END IF;
		
		-- Create it
		DELETE FROM "network"."snmp" WHERE "system_name" = input_system;
		
		-- Done
		PERFORM api.syslog('remove_network_snmp:"'||input_system||'"');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_network_snmp"(text) IS 'Remove credentials for a system';

CREATE OR REPLACE FUNCTION "api"."remove_vlan"(input_datacenter text, input_vlan integer) RETURNS VOID AS $$
     BEGIN
          IF api.get_current_user_level() !~* 'ADMIN' THEN
               RAISE EXCEPTION 'Only admins can remove VLANs';
          END IF;

          DELETE FROM "network"."vlans" WHERE "datacenter" = input_datacenter AND "vlan" = input_vlan;
		PERFORM api.syslog('remove_vlan:"'||input_datacenter||'","'||input_vlan||'"');
     END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_vlan"(text, integer) IS 'Remove a VLAN';
