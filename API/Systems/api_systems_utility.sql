/* API - get_interface_address_owner */
CREATE OR REPLACE FUNCTION "api"."get_interface_address_owner"(input_address inet) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "owner" FROM systems.interface_addresses
			JOIN systems.interfaces on systems.interface_addresses.mac = systems.interfaces.mac
			JOIN systems.systems on systems.interfaces.system_name = systems.systems.system_name
			WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_address_owner"(inet) IS 'Get the owner of an interface address';

CREATE OR REPLACE FUNCTION "api"."renew_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		UPDATE "systems"."interface_addresses"
		SET "renew_date" = date("renew_date" + (SELECT api.get_site_configuration('DEFAULT_RENEW_INTERVAL')::interval))
		WHERE "address" = input_address;

	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."renew_interface_address"(inet) IS 'renew an interface address registration for another interval';


CREATE OR REPLACE FUNCTION "api"."notify_expiring_systems"() RETURNS VOID AS $$
	DECLARE
		SystemData RECORD;
	BEGIN
		FOR SystemData IN (SELECT "owner","system_name" FROM "systems"."systems" WHERE "systems"."systems"."renew_date" <= current_date + interval '7 days') LOOP
			PERFORM "api"."send_renewal_email"(SystemData.owner, SystemData.system_name, (SELECT "api"."get_site_configuration"('DNS_DEFAULT_ZONE')));
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."notify_expiring_systems"() IS 'Notify users of soon-to-expire systems';

CREATE OR REPLACE FUNCTION "api"."clear_expired_systems"() RETURNS VOID AS $$
	DECLARE
		SystemData RECORD;
	BEGIN
		--FOR SystemData IN (SELECT "system_name" FROM "systems"."systems" WHERE "systems"."systems"."renew_date" = current_date) LOOP
		--	PERFORM "api"."remove_system"(SystemData.system_name);
		--END LOOP;
		FOR SystemData IN (SELECT "address" FROM "systems"."interface_addresses" WHERE "address" IN (SELECT "address" FROM "systems"."interface_addresses" WHERE "renew_date" = current_date)) LOOP
			PERFORM "api"."remove_interface_address"(SystemData.address);
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."clear_expired_systems"() IS 'Remove all systems that expire today.';

CREATE OR REPLACE FUNCTION "api"."get_default_renew_date"(input_system TEXT) RETURNS DATE AS $$
	BEGIN
		IF input_system IS NULL THEN
			RETURN date((('now'::text)::date + (api.get_site_configuration('DEFAULT_RENEW_INTERVAL'::text))::interval));
		ELSE
			RETURN date(('now'::text)::date + (SELECT "renew_interval" FROM "management"."groups"
			JOIN "systems"."systems" ON "systems"."systems"."group" = "management"."groups"."group"
			WHERE "system_name" = input_system));
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_default_renew_date"(text) IS 'Get the default renew date based on the configuration';
