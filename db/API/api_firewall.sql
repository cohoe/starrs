/* API - create_firewall_metahost_member */
CREATE OR REPLACE FUNCTION "api"."create_firewall_metahost_member"(input_address inet, input_metahost text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.add_firewall_metahost_member');
		input_metahost := api.sanitize_general(input_metahost);
		
		DELETE FROM "firewall"."rules" WHERE "address" = input_address;

		SELECT api.create_log_entry('API','INFO','adding new member to metahost');
		INSERT INTO "firewall"."metahost_members" ("address","metahost_name") VALUES (input_address,input_metahost);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."add_firewall_metahost_member"() IS 'add a member to a metahost. this deletes all previous rules.';

/* API - remove_firewall_metahost_member*/
CREATE OR REPLACE FUNCTION "api"."remove_firewall_metahost_member"(input_address inet, input_metahost text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.remove_firewall_metahost_member');
		input_metahost := api.sanitize_general(input_metahost);
		
		DELETE FROM "firewall"."rules" WHERE "address" = input_address;

		SELECT api.create_log_entry('API','INFO','removing member from metahost');
		DELETE FROM "firewall"."metahost_members" WHERE "address" = input_address AND "metahost_name" = input_metahost);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_firewall_metahost_member"() IS 'remove a member from a metahost. this deletes all previous rules.';