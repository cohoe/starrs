/* Trigger - switchports_insert
	1) Check for proper system types
*/
CREATE OR REPLACE FUNCTION "network"."switchports_insert"() RETURNS TRIGGER AS $$
	DECLARE
		DeviceType TEXT;
	BEGIN
		-- Check for system types
		SELECT "type" INTO DeviceType
		FROM "systems"."systems"
		WHERE "systems"."systems"."system_name" = NEW."system_name";
		IF DeviceType !~* 'Router|Switch|Hub|Wireless Access Point' THEN
			RAISE EXCEPTION 'Cannot create a switchport on non-network device type (%)',DeviceType;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "network"."switchports_insert"() IS 'verifications for network switchports';

/* Trigger - switchports_update
	1) Check for proper system types
*/
CREATE OR REPLACE FUNCTION "network"."switchports_update"() RETURNS TRIGGER AS $$
	DECLARE
		DeviceType TEXT;
	BEGIN
		-- Check for system types
		IF NEW."system_name" != OLD."system_name" THEN
			SELECT "type" INTO DeviceType
			FROM "systems"."systems"
			WHERE "systems"."systems"."system_name" = NEW."system_name";
			IF DeviceType !~* 'Router|Switch|Hub|Wireless Access Point' THEN
				RAISE EXCEPTION 'Cannot create a switchport on non-network device type %',DeviceType;
			END IF;
		END IF;
		
		IF NEW."description" != OLD."description" THEN
			PERFORM api.modify_network_switchport_description(api.get_system_primary_address(NEW."system_name"),NEW."port_name",(SELECT "snmp_rw_community" FROM "network"."switchview" WHERE "system_name" = NEW."system_name"),NEW."description");
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "network"."switchports_update"() IS 'verifications for network switchports';

CREATE OR REPLACE FUNCTION "network"."switchport_states_update"() RETURNS TRIGGER AS $$
	BEGIN
		IF NEW."admin_state" != OLD."admin_state" THEN
			PERFORM api.modify_network_switchport_admin_state(api.get_system_primary_address(NEW."system_name"),NEW."port_name",(SELECT "snmp_rw_community" FROM "network"."switchview" WHERE "system_name" = NEW."system_name"),NEW."admin_state");
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';