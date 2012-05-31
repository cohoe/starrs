/* api_firewall_create.sql
	1) create_firewall_metahost_member
	2) create_firewall_metahost
	3) create_firewall_metahost_rule
	4) create_firewall_system
	5) create_firewall_rule
	6) create_firewall_rule_program
	7) create_firewall_metahost_rule_program
*/

/* API - create_firewall_metahost_member
	1) Check privileges
	2) Check for dynamic
	3) Create member (Insertion triggers new rules to be applied)
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_member"(input_address inet, input_metahost text) RETURNS SETOF "firewall"."metahost_member_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_firewall_metahost_member');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_metahost) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on metahost %. You are not owner.',input_metahost;
			END IF;
		END IF;

		-- Check for dynamic
		IF input_address << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET'))) THEN
			RAISE EXCEPTION 'Dynamic hosts cannot be a member of a metahost';
		END IF;

		-- Create new member
		PERFORM api.create_log_entry('API','INFO','adding new member to metahost');
		INSERT INTO "firewall"."metahost_members" ("address","name") VALUES (input_address,input_metahost);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_firewall_metahost_member');
		RETURN QUERY (SELECT "name","address","date_created","date_modified","last_modifier" FROM "firewall"."metahost_members" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost_member"(inet, text) IS 'add a member to a metahost. this deletes all previous rules.';

/* API - create_firewall_metahost
	1) Check privileges
	2) Validate input
	3) Fill in owner
	4) Create metahost
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost"(input_name text, input_owner text, input_comment text) RETURNS SETOF "firewall"."metahost_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_firewall_metahost');

		-- Validate input
		input_name := api.validate_name(input_name);

		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create metahost
		PERFORM api.create_log_entry('API','INFO','creating new metahost');
		INSERT INTO "firewall"."metahosts" ("name","comment","owner") VALUES 
		(input_name, input_comment, input_owner);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_firewall_metahost');
		RETURN QUERY (SELECT "name","comment","owner","date_created","date_modified","last_modifier" FROM "firewall"."metahosts" WHERE "name" = input_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost"(text, text, text) IS 'create a firewall metahost';

/* API - create_firewall_metahost_rule
	1) Check privileges
	2) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_rule"(input_name text, input_port integer, input_transport varchar(4), input_deny boolean, input_comment text) RETURNS SETOF "firewall"."metahost_standalone_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_metahost_rule');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on metahost %. You are not owner.',input_name;
			END IF;
		END IF;

		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating new rule');
		INSERT INTO "firewall"."metahost_rules" ("name","port","transport","deny","comment")
		VALUES (input_name, input_port, input_transport, input_deny, input_comment);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_metahost_rule');
		RETURN QUERY (SELECT "firewall"."metahost_rules"."name","port","transport","deny","firewall"."metahost_rules"."comment","owner","firewall"."metahost_rules"."date_created","firewall"."metahost_rules"."date_modified","firewall"."metahost_rules"."last_modifier"
		FROM "firewall"."metahost_rules" JOIN "firewall"."metahosts" ON "firewall"."metahost_rules"."name" = "firewall"."metahosts"."name"
		WHERE "firewall"."metahost_rules"."name" = input_name AND "port" = input_port AND "transport" = input_transport);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost_rule"(text, integer, varchar(4), boolean, text) IS 'Create a firewall metahost rule';

/* API - create_firewall_address
	1) Check privileges
	2) Create address
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_address"(input_subnet cidr, input_address inet, input_isprimary boolean) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_address');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "ip"."subnets" WHERE "subnet" = input_subnet) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on subnet %. You are not owner.',input_subnet;
			END IF;
			IF api.get_interface_address_owner(input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on address %. You are not owner.',input_address;
			END IF;
		END IF;

		-- Create system
		PERFORM api.create_log_entry('API','INFO','creating new firewall address');
		INSERT INTO "firewall"."addresses" ("subnet","address","isprimary") VALUES (input_subnet, input_address, input_isprimary);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_address"(cidr, inet, boolean) IS 'The primary/secondary firewall IPs for a subnet';

/* API - create_firewall_rule
	1) Fill in owner
	2) Check for dynamic
	3) Check privileges
	4) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_rule"(input_address inet, input_port integer, input_transport varchar(4), input_deny boolean, input_owner text, input_comment text) RETURNS SETOF "firewall"."standalone_rule_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_rule');

		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Check for dynamic
		IF input_address << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET'))) THEN
			RAISE EXCEPTION 'Dynamic hosts cannot have firewall rules';
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF api.get_interface_address_owner(input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface address %. You are not owner.',input_address;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating firewall rule');
		INSERT INTO "firewall"."rules" ("address","port","transport","deny","comment","owner","source")
		VALUES (input_address, input_port, input_transport, input_deny, input_comment, input_owner, 'standalone-standalone');

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_rule');
		RETURN QUERY(SELECT "address","port","transport","deny","comment","owner","date_created","date_modified","last_modifier"
		FROM "firewall"."rules" WHERE "address" = input_address AND "port" = input_port AND "transport" = input_transport AND "deny" = input_deny);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_rule"(inet, integer, varchar(4), boolean, text, text) IS 'Create a standalone firewall rule';

/* API - create_firewall_rule_program
	1) Fill in owner
	2) Check for dynamic
	3) Check privileges
	4) Get program information
	5) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_rule_program"(input_address inet, input_program text, input_deny boolean, input_owner text) RETURNS SETOF "firewall"."standalone_program_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_rule_program');

		-- Check for dynamic
		IF input_address << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET'))) THEN
			RAISE EXCEPTION 'Dynamic hosts cannot be a member of a metahost';
		END IF;

		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF api.get_interface_address_owner(input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface address %. You are not owner.',input_address;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating new rule from program');
		INSERT INTO "firewall"."program_rules" ("address","port","deny","owner")
		VALUES (input_address, (SELECT "port" FROM "firewall"."programs" WHERE "name" = input_program), input_deny, input_owner);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_rule_program');
		RETURN QUERY (SELECT "address","name","firewall"."rules"."port","firewall"."rules"."transport","deny","comment","owner","firewall"."rules"."date_created","firewall"."rules"."date_modified","firewall"."rules"."last_modifier"
		FROM "firewall"."rules" JOIN "firewall"."programs" ON "firewall"."rules"."port" = "firewall"."programs"."port"
		WHERE "firewall"."rules"."address" = input_address AND "firewall"."programs"."name" = input_program AND "firewall"."rules"."deny" = input_deny);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_rule_program"(inet, text, boolean, text) IS 'Create a firewall rule based on a common program.';

/* API - create_firewall_metahost_rule_program
	1) Check privileges
	2) Get program information
	3) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_rule_program"(input_name text, input_program text, input_deny boolean) RETURNS SETOF "firewall"."metahost_program_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_metahost_rule_program');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on metahost %. You are not owner.',input_name;
			END IF;
		END IF;

		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating new metahost rule from program');
		INSERT INTO "firewall"."metahost_program_rules" ("name","port","deny")
		VALUES (input_name, (SELECT "port" FROM "firewall"."programs" WHERE "name" = input_program), input_deny);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_metahost_rule_program');
		RETURN QUERY (SELECT "firewall"."metahost_program_rules"."name","firewall"."programs"."name","firewall"."metahost_program_rules"."port","transport","deny","firewall"."metahost_program_rules"."comment","firewall"."metahosts"."owner","firewall"."metahost_program_rules"."date_created","firewall"."metahost_program_rules"."date_modified","firewall"."metahost_program_rules"."last_modifier"
		FROM "firewall"."metahost_program_rules" 
		JOIN "firewall"."programs" ON "firewall"."metahost_program_rules"."port" = "firewall"."programs"."port"
		JOIN "firewall"."metahosts" ON "firewall"."metahost_program_rules"."name" = "firewall"."metahosts"."name"
		WHERE "firewall"."metahost_program_rules"."name" = input_name AND "firewall"."programs"."name" = input_program AND "firewall"."metahost_program_rules"."deny" = input_deny);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost_rule_program"(text, text, boolean) IS 'Create a firewall rule based on a common program.';