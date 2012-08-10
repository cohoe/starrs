CREATE OR REPLACE FUNCTION "api"."get_host_domains"(input_system text) RETURNS SETOF "libvirt"."domains" AS $$
	DECLARE
		HostData RECORD;
	BEGIN
		SELECT * INTO HostData FROM "libvirt"."hosts" WHERE "system_name" = input_system;
		RETURN QUERY (SELECT input_system AS "host_name","domain","state","definition",localtimestamp(0) AS "date_created", localtimestamp(0) AS "date_modified", api.get_current_user() AS "last_modifier" FROM api.get_libvirt_domains(HostData.uri, HostData.password));
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION "api"."get_host_domain"(input_system text, input_domain text) RETURNS SETOF "libvirt"."domains" AS $$
	DECLARE
		HostData RECORD;
	BEGIN
		SELECT * INTO HostData FROM "libvirt"."hosts" WHERE "system_name" = input_system;
		RETURN QUERY (SELECT input_system AS "host_name","domain","state","definition",localtimestamp(0) AS "date_created", localtimestamp(0) AS "date_modified", api.get_current_user() AS "last_modifier" FROM api.get_libvirt_domain(HostData.uri, HostData.password, input_domain));
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION "api"."get_domain_state"(input_system text) RETURNS TEXT AS $$
	DECLARE
		HostData RECORD;
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."system" WHERE "system_name" = input_system) THEN
				RAISE EXCEPTION 'Permission denied: Not VM owner';
			END IF;
		END IF;

		SELECT * INTO HostData FROM "libvirt"."hosts" WHERE "system_name" = (SELECT "host_name" FROM "libvirt"."domains" WHERE "domain_name" = input_system);

		RETURN api.get_libvirt_domain_state(HostData.uri, HostData.password, input_system);
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION "api"."get_hosts"(input_user text) RETURNS SETOF "libvirt"."hosts" AS $$
	BEGIN	
		IF input_user IS NULL THEN
			IF api.get_current_user_level() !~* 'ADMIN' THEN
				RAISE EXCEPTION 'Only admins can view all VM hosts';
			END IF;
			RETURN QUERY (SELECT * FROM "libvirt"."hosts" ORDER BY "system_name");
		ELSE
			IF api.get_current_user_level() !~* 'ADMIN' THEN
				RETURN QUERY (SELECT * FROM "libvirt"."hosts" WHERE api.get_system_owner("system_name") = input_user ORDER BY "system_name");
			ELSE
				RETURN QUERY (SELECT * FROM "libvirt"."hosts" ORDER BY "system_name");
			END IF;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_hosts"(text) IS 'Get all VM hosts';
