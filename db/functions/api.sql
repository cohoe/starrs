/* API - create_dns_address */
CREATE OR REPLACE FUNCTION "api"."create_dns_address"(input_address inet, input_hostname text, input_zone text, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_dns_address');

		input_address := api.sanitize_general(input_address);
		input_hostname := api.sanitize_general(input_hostname);
		input_zone := api.sanitize_general(input_zone);
		input_owner := api.sanitize_general(input_owner);
		
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;
		
		SELECT api.validate_hostname(input_hostname || '.' || input_zone);
		
		SELECT api.create_log_entry('API', 'INFO', 'Creating new address record');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","last_modifier","owner") VALUES 
			(input_hostname,input_zone,input_address,DEFAULT,api.get_current_user(),input_owner);
		ELSE
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","last_modifier","owner") VALUES 
			(input_hostname,input_zone,input_address,input_ttl,api.get_current_user(),input_owner);
		END IF;
		
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"() IS 'create a new A or AAAA record';

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