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

CREATE OR REPLACE FUNCTION "api"."renew_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.renew_system');

		PERFORM api.create_log_entry('API','INFO','updating system'||input_system_name);
		UPDATE "systems"."systems"
		SET "renew_date" = date(current_date + interval '1 year')
		WHERE "system_name" = input_system_name;

		PERFORM api.create_log_entry('API','DEBUG','finish api.renew_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."renew_system"(text) IS 'renew a system registration for another year';