/* API - create_firewall_metahost_member
	1) Check privileges
	2) Check for dynamic
	3) Create member (Insertion triggers new rules to be applied and old rules to be deleted)
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_member"(input_address inet, input_metahost text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_firewall_metahost_member');
		
		-- Check for dynamic
		IF input_address << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET'))) THEN
			RAISE EXCEPTION 'Dynamic hosts cannot be a member of a metahost';
		END IF;

		-- Create new member
		PERFORM api.create_log_entry('API','INFO','adding new member to metahost');
		INSERT INTO "firewall"."metahost_members" ("address","name") VALUES (input_address,input_metahost);

		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_firewall_metahost_member');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost_member"(inet, text) IS 'add a member to a metahost. this deletes all previous rules.';

/* API - create_firewall_metahost
	1) Check privileges
	2) Validate input
	3) Fill in owner
	4) Create metahost
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost"(input_name text, input_owner text, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_firewall_metahost');

		-- Validate input
		input_name := api.validate_name(input_name);
		
		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;
		
		-- Create metahost
		PERFORM api.create_log_entry('API','INFO','creating new metahost');
		INSERT INTO "firewall"."metahosts" ("name","comment","owner") VALUES 
		(input_name, input_comment, input_owner);
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_firewall_metahost');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost"(text, text, text) IS 'create a firewall metahost';

/* API - create_firewall_metahost_rule
	1) Check privileges
	2) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_rule"(input_name text, input_port integer, input_transport varchar(4), input_deny boolean, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_metahost_rule');
		
		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating new rule');
		INSERT INTO "firewall"."metahost_rules" ("name","port","transport","deny","comment")
		VALUES (input_name, input_port, input_transport, input_deny, input_comment);
		
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_metahost_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost_rule"(text, integer, varchar(4), boolean, text) IS 'Create a firewall metahost rule';

/* API - create_firewall_system
	1) Check privileges
	2) Create system
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_system"(input_name text, input_subnet cidr, input_software text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_system');
		
		-- Create system
		PERFORM api.create_log_entry('API','INFO','creating new firewall system');
		INSERT INTO "firewall"."systems" ("system_name","subnet","software_name") VALUES (input_name, input_subnet, input_software);
		
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_system"(text, cidr, text) IS 'Firewall systems are the devices that receive rules for a subnet';

/* API - create_firewall_rule
	1) Check privileges
	2) Fill in owner
	3) Check for dynamic
	4) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_rule"(input_address inet, input_port integer, input_transport varchar(4), input_deny boolean, input_owner text, input_comment text) RETURNS VOID AS $$
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
		
		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating firewall rule');
		INSERT INTO "firewall"."rules" ("address","port","transport","deny","comment","owner")
		VALUES (input_address, input_port, input_transport, input_deny, input_comment, input_owner);
		
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_rule');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_rule"(inet, integer, varchar(4), boolean, text, text) IS 'Create a standalone firewall rule';

/* API - create_firewall_rule_program
	1) Fill in owner
	2) Check privileges
	3) Check for dynamic
	4) Get program information
	5) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_rule_program"(input_address inet, input_program text, input_deny boolean, input_owner text) RETURNS VOID AS $$
	DECLARE
		Port INTEGER;
		Transport VARCHAR(4);
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_rule_program');
		
		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;
		
		-- Check for dynamic
		IF input_address << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET'))) THEN
			RAISE EXCEPTION 'Dynamic hosts cannot be a member of a metahost';
		END IF;

		-- Get program information
		SELECT "firewall"."programs"."port","firewall"."programs"."transport" INTO Port,Transport
		FROM "firewall"."programs"
		WHERE "name" = input_program;

		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating new rule from program');
		INSERT INTO "firewall"."rules"
		("address","port","transport","deny","owner","comment") VALUES
		(input_address,Port,Transport,input_deny,input_owner,'Program on port '||Port||' '||Transport);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_rule_program');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_rule_program"(inet, text, boolean, text) IS 'Create a firewall rule based on a common program.';

/* API - create_firewall_metahost_rule_program
	1) Check privileges
	2) Get program information
	3) Create rule
*/
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_rule_program"(input_name text, input_program text, input_deny boolean) RETURNS VOID AS $$
	DECLARE
		Port INTEGER;
		Transport VARCHAR(4);
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin create_firewall_metahost_rule_program');

		-- Get program information
		SELECT "firewall"."programs"."port","firewall"."programs"."transport" INTO Port,Transport
		FROM "firewall"."programs"
		WHERE "name" = input_program;

		-- Create rule
		PERFORM api.create_log_entry('API','INFO','creating new metahost rule from program');
		INSERT INTO "firewall"."metahost_rules"
		("name","port","transport","deny","comment") VALUES
		(input_name,Port,Transport,input_deny,'Program on port '||Port||' '||Transport);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish create_firewall_metahost_rule_program');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_firewall_metahost_rule_program"(text, text, boolean) IS 'Create a firewall rule based on a common program.';
