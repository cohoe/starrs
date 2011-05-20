/* API - create_mailserver */
CREATE OR REPLACE FUNCTION "api"."create_mailserver"(input_hostname text, input_domain text, input_preference integer, input_ttl integer) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.create_mailserver');
		
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);
		
		SELECT api.create_log_entry('API','INFO','creating new mailserver (MX)');
		
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl") VALUES
			(input_hostname,input_domain,input_preference,DEFAULT);
		ELSE
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl") VALUES
			(input_hostname,input_domain,input_preference,input_ttl);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_mailserver"() IS 'Create a new mailserver MX record for a zone';

/* API - delete_mailserver */
CREATE OR REPLACE FUNCTION "api"."delete_mailserver"(input_hostname text, input_domain text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.delete_mailserver');
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);

		SELECT api.create_log_entry('API','INFO','deleting mailserver (MX)');
		DELETE FROM "dns"."mx" WHERE "hostname" = input_hostname AND "zone" = input_domain;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."delete_mailserver"() IS 'Delete an existing MX record for a zone';