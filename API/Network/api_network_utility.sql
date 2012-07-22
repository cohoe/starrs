CREATE OR REPLACE FUNCTION "api"."reload_cam"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF api.get_current_user() != (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) THEN
				RAISE EXCEPTION 'Permission denied: Not owner';
			END IF;
		END IF;

		INSERT INTO "network"."cam_cache" (
			SELECT input_system_name,*,localtimestamp(0)
			FROM api.get_switchview_device_cam(input_system_name)
		);
		DELETE FROM "network"."cam_cache" WHERE "system_name" = input_system_name AND "timestamp" != localtimestamp(0);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."reload_cam"(text) IS 'Reload the cam cache for a system';

CREATE OR REPLACE FUNCTION "api"."reload_network_switchports"(input_system text) RETURNS VOID AS $$
	DECLARE
		IfList RECORD;
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF api.get_current_user() != (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system) THEN
				RAISE EXCEPTION 'Permission denied: Not owner';
			END IF;
		END IF;

		DELETE FROM "network"."switchports" WHERE "system_name" = input_system;
		FOR IfList IN (SELECT * FROM api.get_network_switchports(input_system) ORDER BY get_network_switchports) LOOP
			INSERT INTO "network"."switchports" SELECT * FROM api.get_network_switchport(input_system, IfList.get_network_switchports);
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."reload_network_switchports"(text) IS 'Reload switchport data on a system';
