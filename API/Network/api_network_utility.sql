CREATE OR REPLACE FUNCTION "api"."reload_cam"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF api.get_current_user() != (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) THEN
				RAISE EXCEPTION 'Permission denied: Not owner';
			END IF;
		END IF;

		INSERT INTO "network"."cam_cache" ("system_name","mac","vlan","date_created","date_modified","last_modifier","ifindex") (
			SELECT input_system_name,mac,vlan,localtimestamp(0),localtimestamp(0),api.get_current_user(),ifindex
			FROM api.get_switchview_device_cam(input_system_name)
		);
		DELETE FROM "network"."cam_cache" WHERE "system_name" = input_system_name AND "date_created" != localtimestamp(0);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."reload_cam"(text) IS 'Reload the cam cache for a system';
