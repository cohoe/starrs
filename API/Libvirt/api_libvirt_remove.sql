CREATE OR REPLACE FUNCTION "api"."remove_libvirt_host"(input_system text) RETURNS VOID AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Only admins can remove VM hosts';
		END IF;
		
		DELETE FROM "libvirt"."hosts" WHERE "system_name" = input_system;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_libvirt_host"(text) IS 'Remove libvirt connection credentials for a system';

CREATE OR REPLACE FUNCTION "api"."remove_libvirt_domain"(input_host text, input_domain text) RETURNS VOID AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "system"."systems" WHERE "system_name" = input_host) != api.get_current_user() THEN
				RAISE EXCEPTION 'Only admins can remove VM hosts';
			END IF;
			IF (SELECT "owner" FROM "system"."systems" WHERE "system_name" = input_domain) != api.get_current_user() THEN
				RAISE EXCEPTION 'Only admins can remove VM hosts';
			END IF;
		END IF;

		DELETE FROM "libvirt"."domains" WHERE "domain_name" = input_domain AND "host_name" = input_host;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_libvirt_domain"(text, text) IS 'Remove a libvirt domain';
