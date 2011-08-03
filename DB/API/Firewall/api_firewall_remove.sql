/* api_firewall_remove.sql
	1) remove_firewall_metahost_member
	2) remove_firewall_metahost
	3) remove_firewall_metahost_rule
	4) remove_firewall_system
	5) remove_firewall_rule
	6) remove_firewall_rule_program
	7) remove_firewall_metahost_rule_program
*/

/* API - remove_firewall_metahost_member
	1) Check privileges
	2) Delete member (Deletion triggers metahost rules to be deleted)
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_metahost_member"(input_address inet) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_firewall_metahost_member');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahost_members" 
			JOIN "firewall"."metahosts" ON "firewall"."metahosts"."name" = "firewall"."metahost_members"."name"
			WHERE "address" = input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on metahost member %. You are not owner.',input_address;
			END IF;
		END IF;

		-- Remove membership
		PERFORM api.create_log_entry('API','INFO','removing member from metahost');
		DELETE FROM "firewall"."metahost_members" WHERE "address" = input_address;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_firewall_metahost_member');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_metahost_member"(inet) IS 'remove a member from a metahost. this deletes all previous rules.';

/* API - remove_firewall_metahost
	1) Check privileges
	2) Remove metahost
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_metahost"(input_metahost_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_firewall_metahost');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_metahost_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on metahost %. You are not owner.',input_metahost_name;
			END IF;
		END IF;

		-- Remove metahost
		PERFORM api.create_log_entry('API','INFO','removing metahost');
		DELETE FROM "firewall"."metahosts" WHERE "name" = input_metahost_name;		

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_firewall_metahost');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_metahost"(text) IS 'remove a firewall metahost';

/* API - remove_firewall_metahost_rule
	1) Check privileges
	2) Remove rule
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_metahost_rule"(input_metahost_name text, input_port integer, input_transport text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin remove_firewall_metahost_rule');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_metahost_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on metahost %. You are not owner.',input_metahost_name;
			END IF;
		END IF;

		-- Remove rule
		PERFORM api.create_log_entry('API','INFO','removing rule');
		DELETE FROM "firewall"."metahost_rules" WHERE "name" = input_metahost_name AND "port" = input_port AND "transport" = input_transport;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish remove_firewall_metahost_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_metahost_rule"(text, integer, text) IS 'Remove a firewall metahost rule';

/* API - remove_firewall_address
	1) Check privileges
	2) Remove system
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_address"(input_subnet cidr, input_isprimary boolean) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin remove_firewall_address');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "ip"."subnets" WHERE "subnet" = input_subnet) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on subnet %. You are not owner.',input_subnet;
			END IF;
		END IF;

		-- Remove system
		PERFORM api.create_log_entry('API','INFO','removing firewall address');
		DELETE FROM "firewall"."addresses" WHERE "subnet" = input_subnet AND "isprimary" = input_isprimary;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish remove_firewall_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_address"(cidr, boolean) IS 'Remove a firewall address';

/* API - remove_firewall_rule
	1) Check privileges
	2) Remove rule
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_rule"(input_address inet, input_port integer, input_transport text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin remove_firewall_rule');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF api.get_interface_address_owner(input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface address %. You are not owner.',input_address;
			END IF;
			IF (SELECT "owner" FROM "firewall"."rules" WHERE "address" = input_address AND "port" = input_port AND "transport" = input_transport) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on rule %,%,%. You are not owner.',input_address,input_port,input_transport;
			END IF;
		END IF;

		-- Remove rule
		PERFORM api.create_log_entry('API','INFO','removing firewall rule');
		DELETE FROM "firewall"."rules" WHERE "address" = input_address AND "port" = input_port AND "transport" = input_transport;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish remove_firewall_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_rule"(inet, integer, text) IS 'Remove a standalone firewall rule';

/* API - remove_firewall_rule_program
	1) Get program information
	2) Check privileges
	3) Remove rule
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_rule_program"(input_address inet, input_program text) RETURNS VOID AS $$
	DECLARE
		PortNum INTEGER;
		ProgramTransport VARCHAR(4);
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin remove_firewall_rule_program');

		-- Get program information
		SELECT "firewall"."programs"."port","firewall"."programs"."transport" INTO PortNum,ProgramTransport
		FROM "firewall"."programs"
		WHERE "name" = input_program;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF api.get_interface_address_owner(input_address) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on interface address %. You are not owner.',input_address;
			END IF;
			IF (SELECT "owner" FROM "firewall"."program_rules" WHERE "firewall"."program_rules"."address" = input_address 
			AND "firewall"."program_rules"."port" = PortNum) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on rule %,%. You are not owner.',input_address,input_program;
			END IF;
		END IF;

		-- Remove rule
		PERFORM api.create_log_entry('API','INFO','removing rule based on program');
		DELETE FROM "firewall"."program_rules"
		WHERE "firewall"."program_rules"."address" = input_address
		AND "firewall"."program_rules"."port" = PortNum;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish remove_firewall_rule_program');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_rule_program"(inet, text) IS 'Remove a firewall rule based on a common program.';

/* API - remove_firewall_metahost_rule_program
	1) Check privileges
	2) Get program information
	3) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_metahost_rule_program"(input_metahost_name text, input_program text) RETURNS VOID AS $$
	DECLARE
		PortNum INTEGER;
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin remove_firewall_metahost_rule_program');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "firewall"."metahosts" WHERE "name" = input_metahost_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on metahost %. You are not owner.',input_metahost_name;
			END IF;
		END IF;

		-- Get program information
		SELECT "firewall"."programs"."port","firewall"."programs"."transport" INTO PortNum
		FROM "firewall"."programs"
		WHERE "name" = input_program;

		-- Remove rule
		PERFORM api.create_log_entry('API','INFO','removing metahost rule from program');
		DELETE FROM "firewall"."metahost_program_rules"
		WHERE "firewall"."metahost_program_rules"."name" = input_metahost_name
		AND "firewall"."metahost_program_rules"."port" = PortNum;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish remove_firewall_metahost_rule_program');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_metahost_rule_program"(text, text) IS 'Remove a firewall rule based on a common program.';

/* API - remove_firewall_rule_queue */
CREATE OR REPLACE FUNCTION "api"."remove_firewall_rule_queue"(input_subnet cidr) RETURNS VOID AS $$
	BEGIN
		DELETE FROM "firewall"."rule_queue" WHERE "address" << input_subnet;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_rule_queue"(cidr) IS 'Flush the rule queue for a subnet';