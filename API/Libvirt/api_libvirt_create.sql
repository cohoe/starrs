CREATE OR REPLACE FUNCTION "api"."create_libvirt_host"(input_system text, input_uri text, input_password text) RETURNS SETOF "libvirt"."hosts" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Only admins can create VM hosts';
		END IF;
		
		IF (SELECT "type" FROM "systems"."systems" WHERE "system_name" = input_system) != 'VM Host' THEN
			RAISE EXCEPTION 'System type mismatch. You need a VM Host.';
		END IF;
		
		INSERT INTO "libvirt"."hosts" ("system_name","uri","password") 
		VALUES (input_system, input_uri, input_password);
		
		RETURN QUERY (SELECT * FROM "libvirt"."hosts" WHERE "system_name" = input_system);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_libvirt_host"(text, text, text) IS 'Create libvirt connection settings for a system';

CREATE OR REPLACE FUNCTION "api"."add_libvirt_domain"(input_host text, input_domain text) RETURNS SETOF "libvirt"."domains" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "system"."systems" WHERE "system_name" = input_host) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied: Not owner of host!';
			END IF;

			IF (SELECT "owner" FROM "system"."systems" WHERE "system_name" = input_domain) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied: Not owner of domain!';
			END IF;
		END IF;

		IF (SELECT "type" FROM "systems"."systems" WHERE "system_name" = input_host) != 'VM Host' THEN
			RAISE EXCEPTION 'Host type mismatch. You need a VM Host.';
		END IF;

		IF (SELECT "type" FROM "systems"."systems" WHERE "system_name" = input_domain) != 'Virtual Machine' THEN
			RAISE EXCEPTION 'Domain type mismatch. You need a Virtual Machine.';
		END IF;

		INSERT INTO "libvirt"."domains" ("host_name", "domain_name") VALUES (input_host, input_domain);
		
		RETURN QUERY (SELECT * FROM "libvirt"."domains" WHERE "domain_name" = input_domain);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."add_libvirt_domain"(text, text) IS 'Assign a VM to a host';

CREATE OR REPLACE FUNCTION "api"."create_libvirt_platform"(input_name text, input_definition text) RETURNS SETOF "libvirt"."platforms" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied: Not admin!';
		END IF;

		INSERT INTO "libvirt"."platforms" ("platform_name","definition") VALUES (input_name, input_definition);
		
		RETURN QUERY (SELECT * FROM "libvirt"."platforms" WHERE "platform_name" = input_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_libvirt_platform"(text, text) IS 'Store a definition of a libvirt platform';
