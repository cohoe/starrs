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
COMMENT ON FUNCTION "api"."add_firewall_metahost_member"() IS 'add a member to a metahost. this deletes all previous rules.';

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
COMMENT ON FUNCTION "api"."remove_firewall_metahost_member"() IS 'remove a member from a metahost. this deletes all previous rules.';

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
COMMENT ON FUNCTION "api"."modify_firewall_default"() IS 'modify an addresses default firewall action';
