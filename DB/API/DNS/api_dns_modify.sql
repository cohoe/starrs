/* API - modify_dns_key
	1) Check privileges
	2) Check allowed fields
	3) Validate input
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_key"(input_old_keyname text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_key');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."keys" WHERE "keyname" = input_old_keyname) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit key % denied. You are not owner',input_old_keyname;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'keyname|key|comment|owner' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Validate input
		IF input_field ~* 'keyname' THEN 
			input_new_value := api.validate_nospecial(input_new_value);
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');
		EXECUTE 'UPDATE "dns"."keys" SET ' || quote_ident($2) || ' = $3, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
		WHERE "keyname" = $1' 
		USING input_old_keyname, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_key"(text,text,text) IS 'Modify an existing DNS key';