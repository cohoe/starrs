/* api_firewall_modify
	1) modify_firewall_default
*/

/* API - modify_firewall_default
	1) Check privileges
	2) Alter default action
*/
CREATE OR REPLACE FUNCTION "api"."modify_firewall_default"(input_address inet, input_action boolean) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_firewall_default');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF api.get_interface_address_owner(input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface address %. You are not owner.',input_address;
			END IF;
		END IF;

		-- Alter default action
		PERFORM api.create_log_entry('API','INFO','altering default action');
		UPDATE "firewall"."defaults" SET "deny" = input_action, "date_modified" = current_timestamp, "last_modifier" = api.get_current_user() WHERE "address" = input_address;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_firewall_default');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_firewall_default"(inet, boolean) IS 'modify an addresses default firewall action';