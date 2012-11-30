CREATE OR REPLACE FUNCTION "api"."modify_network_snmp"(input_old_system text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_old_system) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied: you are not owner';
			END IF;
		END IF;
		
		-- Check fields
		IF input_field !~* 'ro_community|rw_community|system_name|address' THEN
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
		PERFORM api.syslog('modify_network_snmp:"'||input_old_system||'","'||input_field||'","'||input_new_value||'"');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_network_snmp"(text, text, text) IS 'Modify credentials for a system';

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

		PERFORM api.syslog('modify_vlan:"'||input_old_datacenter||'","'||input_old_vlan||'","'||input_field||'","'||input_new_value||'"');
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
