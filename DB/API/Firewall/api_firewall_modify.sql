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

/* API - modify_firewall_metahost
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_firewall_metahost"(input_old_name text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_firewall_metahost');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_old_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit metahost (%) denied. You are not owner',input_old_name;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'name|comment|owner' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update metahost');

		EXECUTE 'UPDATE "firewall"."metahosts" SET ' || quote_ident($2) || ' = $3,
		date_modified = current_timestamp, last_modifier = api.get_current_user()
		WHERE "name" = $1'
		USING input_old_name, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_firewall_metahost');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_firewall_metahost"(text, text, text) IS 'Modify an existing DNS TXT or SPF record';