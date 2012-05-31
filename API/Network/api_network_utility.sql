/* API - switchview_scan_admin_state */
CREATE OR REPLACE FUNCTION "api"."switchview_scan_admin_state"(input_system_name text) RETURNS VOID AS $$
	DECLARE
		ScanResult RECORD;
	BEGIN
		FOR ScanResult IN (SELECT input_system_name,"port","state" FROM "api"."get_network_switchview_admin_state"(api.get_system_primary_address(input_system_name),(SELECT "snmp_ro_community" FROM "network"."switchview" WHERE "system_name" = input_system_name))
		WHERE "port" IN (SELECT "port_name" FROM "network"."switchports" WHERE "system_name" = input_system_name)) LOOP
			UPDATE "network"."switchport_states" SET "admin_state" = ScanResult.state WHERE "port_name" = ScanResult.port AND "system_name" = input_system_name;
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."switchview_scan_admin_state"(text) IS 'Load the data for a set of ports on a system';

/* API - switchview_scan_port_state */
CREATE OR REPLACE FUNCTION "api"."switchview_scan_port_state"(input_system_name text) RETURNS VOID AS $$
	DECLARE
		ScanResult RECORD;
	BEGIN
		FOR ScanResult IN (SELECT input_system_name,"port","state" FROM "api"."get_network_switchview_active_state"(api.get_system_primary_address(input_system_name),(SELECT "snmp_ro_community" FROM "network"."switchview" WHERE "system_name" = input_system_name))
		WHERE "port" IN (SELECT "port_name" FROM "network"."switchports" WHERE "system_name" = input_system_name)) LOOP
			UPDATE "network"."switchport_states" SET "port_state" = ScanResult.state WHERE "port_name" = ScanResult.port AND "system_name" = input_system_name;
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."switchview_scan_port_state"(text) IS 'Load the data for a set of ports on a system';

/* API - switchview_scan_mac */
CREATE OR REPLACE FUNCTION "api"."switchview_scan_mac"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		INSERT INTO "network"."switchport_history" ("system_name","port_name","mac","time") (SELECT input_system_name,"port_name","mac",current_timestamp FROM "network"."switchport_macs" WHERE "system_name" = input_system_name);
		DELETE FROM "network"."switchport_macs" WHERE "system_name" = input_system_name;
		INSERT INTO "network"."switchport_macs" ("system_name","port_name","mac") (SELECT input_system_name,"port","mac" FROM "api"."get_network_switchport_view"(api.get_system_primary_address(input_system_name),(SELECT "snmp_ro_community" FROM "network"."switchview" WHERE "system_name" = input_system_name))
		WHERE "port" IN (SELECT "port_name" FROM "network"."switchports" WHERE "system_name" = input_system_name));
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."switchview_scan_mac"(text) IS 'Load the MAC address data for a set of ports on a system';

/* API - switchview_scan_description */
CREATE OR REPLACE FUNCTION "api"."switchview_scan_description"(input_system_name text) RETURNS VOID AS $$
	DECLARE
		ScanResult RECORD;
	BEGIN
		FOR ScanResult IN (SELECT "port","description" 
		FROM "api"."get_switchview_descriptions"(api.get_system_primary_address(input_system_name),(SELECT "snmp_ro_community" FROM "network"."switchview" WHERE "system_name" = input_system_name)) 
		WHERE "port" IN (SELECT "port_name" FROM "network"."switchports" WHERE "system_name" = input_system_name)) LOOP
			UPDATE "network"."switchports" SET "description" = ScanResult.description WHERE "system_name" = input_system_name AND "port_name" = ScanResult.port;
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."switchview_scan_description"(text) IS 'Load the description data for a set of ports on a system';

CREATE OR REPLACE FUNCTION "api"."clean_switchport_history"(input_system_name text) RETURNS VOID AS $$
	DECLARE
		TimeCount INTEGER;
	BEGIN
		SELECT COUNT(DISTINCT("time")) INTO TimeCount
		FROM "network"."switchport_history" 
		WHERE "system_name" = input_system_name;

		IF TimeCount > 5 THEN
			DELETE FROM "network"."switchport_history"
			WHERE "system_name" =  input_system_name
			AND "time" IN
			(SELECT "time" FROM "network"."switchport_history" GROUP BY "time" ORDER BY "time" ASC LIMIT (TimeCount - 5));
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."clean_switchport_history"(text) IS 'Keep the record of switchport scans to a sane level';