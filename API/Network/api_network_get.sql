CREATE OR REPLACE FUNCTION "api"."get_switchview_device_cam"(input_system text) RETURNS SETOF "network"."cam" AS $$
	DECLARE
		Vlans RECORD;
		CamData RECORD;
		input_host INET;
		input_community TEXT;
	BEGIN
		SELECT get_system_primary_address::inet INTO input_host FROM api.get_system_primary_address(input_system);
		IF input_host IS NULL THEN
			RAISE EXCEPTION 'Unable to find address for system %',input_system;
		END IF;
		SELECT ro_community INTO input_community FROM api.get_network_snmp(input_system);
		IF input_community IS NULL THEN
			RAISE EXCEPTION 'Unable to find SNMP settings for system %',input_system;
		END IF;

		FOR Vlans IN (SELECT "vlan" FROM "network"."switchports" WHERE "system_name" = input_system AND "vlan" IS NOT NULL GROUP BY "vlan" ORDER BY "vlan") LOOP
			FOR CamData IN (
				SELECT mac,ifname,Vlans.vlan FROM api.get_switchview_cam(input_host,input_community,vlans.vlan) AS "cam"
				JOIN api.get_switchview_bridgeportid(input_host,input_community,vlans.vlan) AS "bridgeportid"
				ON bridgeportid.camportinstanceid = cam.camportinstanceid
				JOIN api.get_switchview_portindex(input_host,input_community,vlans.vlan) AS "portindex"
				ON bridgeportid.bridgeportid = portindex.bridgeportid
				JOIN api.get_switchview_port_names(input_host,input_community) AS "portnames"
				ON portindex.ifindex = portnames.ifindex
			) LOOP
				RETURN NEXT CamData;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_switchview_device_cam"(text) IS 'Get all CAM data from a particular device';

CREATE OR REPLACE FUNCTION "api"."get_network_snmp"(input_system_name text) RETURNS SETOF "network"."snmp" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to get SNMP credentials denied: You are not owner or admin';
			END IF;
		END IF;
		
		-- Return
		RETURN QUERY (SELECT * FROM "network"."snmp" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_snmp"(text) IS 'Get SNMP connection information for a system';

CREATE OR REPLACE FUNCTION "api"."get_system_cam"(input_system_name text) RETURNS SETOF "network"."cam_cache" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to get CAM denied: You are not owner or admin';
			END IF;
		END IF;

		RETURN QUERY (SELECT * FROM "network"."cam_cache" WHERE "system_name" = input_system_name ORDER BY "ifname","vlan","mac");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_cam"(text) IS 'Get the latest CAM data from the cache';

CREATE OR REPLACE FUNCTION "api"."get_interface_switchports"(input_mac macaddr) RETURNS SETOF "network"."cam_cache" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "network"."cam_cache" WHERE "mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_switchports"(macaddr) IS 'Get all the cam cache entries for MAC';

CREATE OR REPLACE FUNCTION "api"."get_switchview_device_switchports"(input_system text) RETURNS SETOF "network"."switchports" AS $$
	DECLARE
		system_address INET;
          system_community TEXT;
	BEGIN
		SELECT get_system_primary_address::inet INTO system_address FROM api.get_system_primary_address(input_system);
          IF system_address IS NULL THEN
               RAISE EXCEPTION 'Unable to find address for system %',input_system;
          END IF;
          SELECT ro_community INTO system_community FROM api.get_network_snmp(input_system);
          IF system_community IS NULL THEN
               RAISE EXCEPTION 'Unable to find SNMP settings for system %',input_system;
          END IF;

		RETURN QUERY (
			SELECT "ifadminstatus","ifoperstatus","ifname","ifdesc","ifalias"
			FROM api.get_switchview_port_names(system_address, system_community) AS "namedata"
			JOIN api.get_switchview_port_adminstatus(system_address, system_community) AS "admindata"
			ON "admindata"."ifindex" = "namedata"."ifindex"
			JOIN api.get_switchview_port_operstatus(system_address, system_community) AS "operdata"
			ON "operdata"."ifindex" = "namedata"."ifindex"
			JOIN api.get_switchview_port_descriptions(system_address, system_community) AS "descdata"
			ON "descdata"."ifindex" = "namedata"."ifindex"
		);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_switchview_device_switchports"(text) IS 'Get data on all switchports on a system';

CREATE OR REPLACE FUNCTION "api"."get_system_switchports"(input_system text) RETURNS SETOF "network"."switchports" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "network"."switchports" WHERE "system_name" = input_system ORDER BY "name");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_switchports"(text) IS 'Get the most recent cached switchport data';

CREATE OR REPLACE FUNCTION "api"."get_vlans"(input_datacenter text) RETURNS SETOF "network"."vlans" AS $$
     BEGIN
          IF input_datacenter IS NULL THEN
               RETURN QUERY (SELECT * FROM "network"."vlans" ORDER BY "datacenter","vlan");
          ELSE
               RETURN QUERY (SELECT * FROM "network"."vlans" WHERE "datacenter" = input_datacenter ORDER BY "vlan");
          END IF;
     END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_vlans"(text) IS 'Get all or a systems vlans';
