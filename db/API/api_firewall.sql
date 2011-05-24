/* API - create_firewall_metahost_member
	1) Check privileges
	2) Sanitize Input
	3) Create member (Insertion triggers new rules to be applied and old rules to be deleted)
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_member"(input_address inet, input_metahost text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.add_firewall_metahost_member');

		-- Sanitize Input
		input_metahost := api.sanitize_general(input_metahost);

		-- Create new member
		SELECT api.create_log_entry('API','INFO','adding new member to metahost');
		INSERT INTO "firewall"."metahost_members" ("address","metahost_name") VALUES (input_address,input_metahost);

		SELECT api.create_log_entry('API','DEBUG','Finish api.add_firewall_metahost_member');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."add_firewall_metahost_member"(inet, text) IS 'add a member to a metahost. this deletes all previous rules.';

/* API - remove_firewall_metahost_member
	1) Check privileges
	2) Sanitize input
	3) Delete member (Deletion triggers metahost rules to be deleted)
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_metahost_member"(input_address inet, input_metahost text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.remove_firewall_metahost_member');

		-- Sanitize Input
		input_metahost := api.sanitize_general(input_metahost);

		-- Remove membership
		SELECT api.create_log_entry('API','INFO','removing member from metahost');
		DELETE FROM "firewall"."metahost_members" WHERE "address" = input_address AND "metahost_name" = input_metahost);

		SELECT api.create_log_entry('API','DEBUG','Finish api.remove_firewall_metahost_member');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_metahost_member"(inet, text) IS 'remove a member from a metahost. this deletes all previous rules.';

/* API - modify_firewall_default
	1) Check privileges
	2) Alter default action
*/
CREATE OR REPLACE FUNCTION "api"."modify_firewall_default"(input_address inet, input_action boolean) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.modify_firewall_default');

		-- Alter default action
		SELECT api.create_log_entry('API','INFO','altering default action';
		UPDATE "firewall"."defaults" SET "deny" = input_action WHERE "address" = input_address;

		SELECT api.create_log_entry('API','DEBUG','finish api.modify_firewall_default');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_firewall_default"(inet, boolean) IS 'modify an addresses default firewall action';

/* API - create_metahost
	1) Check privileges
	2) Sanitize input
	3) Create metahost
*/
CREATE OR REPLACE FUNCTION "api"."create_metahost"(input_name text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.create_metahost');

		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		input_comment := api.sanitize_general(input_comment);
		
		-- Create metahost
		SELECT api.create_log_entry('API','INFO','creating new metahost');
		INSERT INTO "firewall"."metahosts" ("name","comment","owner") VALUES 
		(input_name, input_comment, api.get_current_user());
		
		SELECT api.create_log_entry('API','DEBUG','finish api.create_metahost');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_metahost"(text, text) IS 'create a firewall metahost';

/* API - remove_metahost
	1) Check privileges
	2) Sanitize input
	3) Remove metahost
*/
CREATE OR REPLACE FUNCTION "api"."remove_metahost"(input_name text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.remove_metahost');

		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		
		-- Create metahost
		SELECT api.create_log_entry('API','INFO','removing metahost');
		DELETE FROM "firewall"."metahosts" WHERE "name" = input_name;		
		SELECT api.create_log_entry('API','DEBUG','finish api.remove_metahost');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_metahost"(text) IS 'remove a firewall metahost';

/* API - create_metahost_rule
	1) Check privileges
	2) Sanitize input
	3) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_metahost_rule"(input_name text, input_port integer, input_transport text, input_deny boolean, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin create_metahost_rule');
		
		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		input_transport := api.sanitize_general(input_transport);
		input_comment := api.sanitize_general(input_comment);
		
		-- Create rule
		INSERT INTO "firewall"."metahost_rules" ("name","port","transport","deny","comment")
		VALUES (input_name, input_port, input_transport, input_deny, input_comment);
		
		SELECT api.create_log_entry('API','DEBUG','finish create_metahost_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_metahost_rule"(text, integer, text, boolean, text) IS 'Create a firewall metahost rule';

/* API - remove_metahost_rule
	1) Check privileges
	2) Sanitize input
	3) Remove rule
*/
CREATE OR REPLACE FUNCTION "api"."remove_metahost_rule"(input_name text, input_port integer, input_transport text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin remove_metahost_rule');
		
		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		input_transport := api.sanitize_general(input_transport);
		
		-- Remove rule
		DELETE FROM "firewall"."metahost_rules" WHERE "name" = input_name AND "port" = input_port AND "transport" = input_transport;
		
		SELECT api.create_log_entry('API','DEBUG','finish remove_metahost_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "remove_metahost_rule"(text, integer, text) IS 'Remove a firewall metahost rule';

/* API - create_firewall_system
	1) Check privileges
	2) Sanitize input
	3) Create system
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_system"(input_name text, input_subnet cidr, input_software text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin create_firewall_system');
		
		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		input_software := api.sanitize_general(input_software);
		
		-- Create system
		INSERT INTO "firewall"."systems" ("name","subnet","software") VALUES (input_name, input_subnet, input_software);
		
		SELECT api.create_log_entry('API','DEBUG','finish create_firewall_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_system"(text, cidr, text) IS 'Firewall systems are the devices that receive rules for a subnet';

/* API - remove_firewall_system
	1) Check privileges
	2) Sanitize input
	3) Remove system
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_system"(input_name text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin remove_firewall_system');
		
		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		
		-- Remove system
		DELETE FROM "firewall"."systems" WHERE "name" = input_name;
		
		SELECT api.create_log_entry('API','DEBUG','finish remove_firewall_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_system"(text) IS 'Remove a firewall system';

/* API - create_firewall_rule
	1) Check privileges
	2) Sanitize input
	3) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_rule"(input_address inet, input_port integer, input_transport text, input_deny boolean, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin create_firewall_rule');
		
		-- Sanitize input
		input_transport := api.sanitize_general(input_transport);
		input_comment := api.sanitize_general(input_comment);
		
		-- Create rule
		INSERT INTO "firewall"."rules" ("address","port","transport","deny","comment","owner")
		VALUES (input_address, input_port, input_transport, input_deny, input_comment, api.get_current_user);
		
		SELECT api.create_log_entry('API','DEBUG','finish create_firewall_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_rule"(inet, integer, text, boolean, text) IS 'Create a standalone firewall rule';

/* API - remove_firewall_rule
	1) Check privileges
	2) Sanitize input
	3) Remove rule
*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_rule"(input_address inet, input_port integer, input_transport text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin remove_firewall_rule');
		
		-- Sanitize input
		input_transport := api.sanitize_general(input_transport);
		
		-- Remove rule
		DELETE FROM "firewall"."rules" WHERE "address" = input_address AND "port" = input_port AND "transport" = input_transport;
		
		SELECT api.create_log_entry('API','DEBUG','finish remove_firewall_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_rule"(inet, integer, text) IS 'Remove a standalone firewall rule';