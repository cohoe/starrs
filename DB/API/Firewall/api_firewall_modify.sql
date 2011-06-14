/* api_firewall_modify
	1) modify_firewall_default
	2) modify_firewall_metahost
	3) modify_firewall_rule
	4) modify_firewall_metahost_rule
	5) modify_firewall_system
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
COMMENT ON FUNCTION "api"."modify_firewall_metahost"(text, text, text) IS 'Modify an existing firewall metahost';

/* API - modify_firewall_rule
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_firewall_rule"(input_old_address inet, input_old_port integer, input_old_transport varchar(4), input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_firewall_rule');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."rules" WHERE "address" = input_old_address AND "port" = input_old_port AND "transport" = input_old_transport) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit rule (Port % % on %) denied. You are not owner',input_old_port,input_old_transport,input_old_address;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'deny|port|comment|transport|address|owner' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update metahost');

		IF input_field ~* '^port$' THEN
			EXECUTE 'UPDATE "firewall"."rules" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "address" = $1 AND "port" = $2 AND "transport" = $3'
			USING input_old_address, input_old_port, input_old_transport, input_field, cast(input_new_value as int);
		ELSIF input_field ~* 'deny' THEN
			EXECUTE 'UPDATE "firewall"."rules" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "address" = $1 AND "port" = $2 AND "transport" = $3'
			USING input_old_address, input_old_port, input_old_transport, input_field, bool(input_new_value);
		ELSIF input_field ~* 'address' THEN
			EXECUTE 'UPDATE "firewall"."rules" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "address" = $1 AND "port" = $2 AND "transport" = $3'
			USING input_old_address, input_old_port, input_old_transport, input_field, inet(input_new_value);
		ELSE
			EXECUTE 'UPDATE "firewall"."rules" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "address" = $1 AND "port" = $2 AND "transport" = $3'
			USING input_old_address, input_old_port, input_old_transport, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_firewall_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_firewall_rule"(inet, integer, varchar(4), text, text) IS 'Modify an existing firewall rule';

/* API - modify_firewall_metahost_rule
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_firewall_metahost_rule"(input_old_metahost text, input_old_port integer, input_old_transport varchar(4), input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_firewall_metahost_rule');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_old_metahost) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit rule (Port % % on %) denied. You are not owner',input_old_port,input_old_transport,input_old_metahost;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'deny|port|comment|transport|name' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update metahost rule');

		IF input_field ~* '^port$' THEN
			EXECUTE 'UPDATE "firewall"."metahost_rules" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "name" = $1 AND "port" = $2 AND "transport" = $3'
			USING input_old_metahost, input_old_port, input_old_transport, input_field, cast(input_new_value as int);
		ELSIF input_field ~* 'deny' THEN
			EXECUTE 'UPDATE "firewall"."metahost_rules" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "name" = $1 AND "port" = $2 AND "transport" = $3'
			USING input_old_metahost, input_old_port, input_old_transport, input_field, bool(input_new_value);
		ELSE
			EXECUTE 'UPDATE "firewall"."metahost_rules" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "name" = $1 AND "port" = $2 AND "transport" = $3'
			USING input_old_metahost, input_old_port, input_old_transport, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_firewall_metahost_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_firewall_metahost_rule"(text, integer, varchar(4), text, text) IS 'Modify an existing firewall metahost rule';

/* API - modify_firewall_system
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_firewall_system"(input_old_subnet cidr, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.modify_firewall_system');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = (SELECT "system_name" FROM "firewall"."systems" WHERE "subnet" = input_old_subnet)) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit firewall system on subnet (%) denied. You are not owner',input_old_subnet;
			END IF;
		END IF;

		-- Check allowed fields
		IF input_field !~* 'subnet|software_name|system_name' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update metahost');

		IF input_field ~* 'subnet' THEN
			EXECUTE 'UPDATE "firewall"."systems" SET ' || quote_ident($2) || ' = $3,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "subnet" = $1'
			USING input_old_subnet, input_field, cidr(input_new_value);
		ELSE
			EXECUTE 'UPDATE "firewall"."systems" SET ' || quote_ident($2) || ' = $3,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "subnet" = $1'
			USING input_old_subnet, input_field, input_new_value;
		END IF;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.modify_firewall_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_firewall_system"(cidr, text, text) IS 'modify an existing firewall system';