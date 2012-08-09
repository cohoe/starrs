CREATE OR REPLACE FUNCTION "api"."modify_domain_state"(input_host text, input_domain text, input_action text) RETURNS TEXT AS $$
	DECLARE
		HostData RECORD;
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."system" WHERE "system_name" = input_domain) THEN
				RAISE EXCEPTION 'Permission denied: Not VM owner';
			END IF;
		END IF;

		SELECT * INTO HostData FROM "libvirt"."hosts" WHERE "system_name" = input_host;

		RETURN api.control_libvirt_domain(HostData.uri,HostData.password,input_domain,input_action);
	END;
$$ LANGUAGE 'plpgsql';
