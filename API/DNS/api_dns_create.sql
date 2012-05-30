/* api_dns_create.sql
	1) create_dns_key
	2) create_dns_zone
	3) create_dns_address
	4) create_dns_mailserver
	5) create_dns_nameserver
	6) create_dns_srv
	7) create_dns_cname
	8) create_dns_txt
*/

/* API - create_dns_key
	1) Validate input
	2) Fill in owner
	3) Check privileges
	3) Create new key
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_key"(input_keyname text, input_key text, input_owner text, input_comment text) RETURNS SETOF "dns"."key_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_key');

		-- Validate input
		input_keyname := api.validate_nospecial(input_keyname);

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

		-- Create new key
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns key');
		INSERT INTO "dns"."keys"
		("keyname","key","comment","owner") VALUES
		(input_keyname,input_key,input_comment,input_owner);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_key');
		RETURN QUERY (SELECT "keyname","key","comment","owner","date_created","date_modified","last_modifier"
		FROM "dns"."keys" WHERE "keyname" = input_keyname AND "key" = input_key);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_key"(text, text, text, text) IS 'Create new DNS key';

/* API - create_dns_zone
	1) Validate input
	2) Fill in owner
	3) Create zone (domain)
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_zone"(input_zone text, input_keyname text, input_forward boolean, input_shared boolean, input_owner text, input_comment text) RETURNS SETOF "dns"."zone_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_zone');

		-- Validate input
		IF api.validate_domain(NULL,input_zone) IS FALSE THEN
			RAISE EXCEPTION 'Invalid domain (%)',input_zone;
		END IF;

		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner = api.get_current_user();
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to create zone % denied for user %. Not admin.',input_zone,api.get_current_user();
		END IF;
		
		-- Create zone
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns zone');
		INSERT INTO "dns"."zones" ("zone","keyname","forward","comment","owner","shared") VALUES
		(input_zone,input_keyname,input_forward,input_comment,input_owner,input_shared);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_zone');
		RETURN QUERY (SELECT "zone","keyname","forward","shared","owner","comment","date_created","date_modified","last_modifier"
		FROM "dns"."zones" WHERE "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_zone"(text, text, boolean, boolean, text, text) IS 'Create a new DNS zone';

/* API - create_dns_address
	1) Set owner
	2) Set zone
	3) Set ttl
	4) Check privileges
	5) Validate hostname
	6) Create record
	7) Queue dns
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_address"(input_address inet, input_hostname text, input_zone text, input_ttl integer, input_owner text) RETURNS SETOF "dns"."a_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.create_dns_address');

		-- Set owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Set zone
		IF input_zone IS NULL THEN
			input_zone := api.get_site_configuration('DNS_DEFAULT_ZONE');
		END IF;
		
		-- Fill TTL
		IF input_ttl IS NULL THEN
			input_ttl := api.get_site_configuration('DNS_DEFAULT_TTL');
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "shared" FROM "dns"."zones" WHERE "zone" = input_zone) IS FALSE
			AND (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'DNS zone % is not shared and you are not owner. Permission denied.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Validate hostname
		IF api.validate_domain(input_hostname,input_zone) IS FALSE THEN
			RAISE EXCEPTION 'Invalid hostname (%) and domain (%)',input_hostname,input_zone;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new address record');
		INSERT INTO "dns"."a" ("hostname","zone","address","ttl","owner") VALUES 
		(input_hostname,input_zone,input_address,input_ttl,input_owner);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_address');
		RETURN QUERY (SELECT "hostname","zone","address","type","ttl","owner","date_created","date_modified","last_modifier"
		FROM "dns"."a" WHERE "address" = input_address AND "hostname" = input_hostname AND "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"(inet, text, text, integer, text) IS 'create a new A or AAAA record';

/* API - create_dns_mailserver
	1) Set owner
	2) Set zone
	3) Check privileges
	4) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_mailserver"(input_hostname text, input_zone text, input_preference integer, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_mailserver');

		-- Set owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Set zone
		IF input_zone IS NULL THEN
			input_zone := api.get_site_configuration('DNS_DEFAULT_ZONE');
		END IF;
		
		-- Fill TTL
		IF input_ttl IS NULL THEN
			input_ttl := api.get_site_configuration('DNS_DEFAULT_TTL');
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new mailserver (MX)');
		INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl","owner","type") VALUES
		(input_hostname,input_zone,input_preference,input_ttl,input_owner,'MX');
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_mailserver"(text, text, integer, integer, text) IS 'Create a new mailserver MX record for a zone';

/* API - create_dns_nameserver
	1) Set owner
	2) Set zone
	3) Check privileges
	4) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_nameserver"(input_hostname text, input_zone text, input_isprimary boolean, input_ttl integer, input_owner text) RETURNS SETOF "dns"."ns_data" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_nameserver');

		-- Set owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Set zone
		IF input_zone IS NULL THEN
			input_zone := api.get_site_configuration('DNS_DEFAULT_ZONE');
		END IF;
		
		-- Fill TTL
		IF input_ttl IS NULL THEN
			input_ttl := api.get_site_configuration('DNS_DEFAULT_TTL');
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new NS record');
		INSERT INTO "dns"."ns" ("hostname","zone","isprimary","ttl","owner","type") VALUES
		(input_hostname,input_zone,input_isprimary,input_ttl,input_owner,'NS');
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_nameserver');
		RETURN QUERY (SELECT "hostname","zone","address","type","isprimary","ttl","owner","date_created","date_modified","last_modifier"
		FROM "dns"."ns" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "isprimary" = input_isprimary);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_nameserver"(text, text, boolean, integer, text) IS 'create a new NS record for the zone';

/* API - create_dns_srv
	1) Validate input
	2) Set owner
	3) Set zone
	4) Check privileges
	5) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_srv"(input_alias text, input_target text, input_zone text, input_priority integer, input_weight integer, input_port integer, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_srv');

		-- Validate input
		IF api.validate_srv(input_alias) IS FALSE THEN
			RAISE EXCEPTION 'Invalid alias (%)',input_alias;
		END IF;

		-- Set owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Set zone
		IF input_zone IS NULL THEN
			input_zone := api.get_site_configuration('DNS_DEFAULT_ZONE');
		END IF;
		
		-- Fill TTL
		IF input_ttl IS NULL THEN
			input_ttl := api.get_site_configuration('DNS_DEFAULT_TTL');
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new SRV record');
		INSERT INTO "dns"."pointers" ("alias","hostname","zone","extra","ttl","owner","type") VALUES
		(input_alias, input_target, input_zone, input_priority || ' ' || input_weight || ' ' || input_port, input_ttl,input_owner,'SRV');
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_srv');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_srv"(text, text, text, integer, integer, integer, integer, text) IS 'create a new dns srv record for a zone';

/* API - create_dns_cname
	1) Validate input
	2) Set owner
	3) Set zone
	4) Check privileges
	5) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_cname"(input_alias text, input_target text, input_zone text, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_cname');

		-- Validate input
		IF api.validate_domain(input_alias,NULL) IS FALSE THEN
			RAISE EXCEPTION 'Invalid alias (%)',input_alias;
		END IF;

		-- Set owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Set zone
		IF input_zone IS NULL THEN
			input_zone := api.get_site_configuration('DNS_DEFAULT_ZONE');
		END IF;
		
		-- Fill TTL
		IF input_ttl IS NULL THEN
			input_ttl := api.get_site_configuration('DNS_DEFAULT_TTL');
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new CNAME record');
		INSERT INTO "dns"."pointers" ("alias","hostname","zone","ttl","owner","type") VALUES
		(input_alias, input_target, input_zone, input_ttl,input_owner,'CNAME');
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_cname');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_cname"(text, text, text, integer, text) IS 'create a new dns cname record for a host';

/* API - create_dns_text
	1) Set owner
	2) Set zone
	3) Check privileges
	4) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_text"(input_hostname text, input_zone text, input_text text, input_type text, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_txt');

		-- Set owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;

		-- Set zone
		IF input_zone IS NULL THEN
			input_zone := api.get_site_configuration('DNS_DEFAULT_ZONE');
		END IF;
		
		-- Fill TTL
		IF input_ttl IS NULL THEN
			input_ttl := api.get_site_configuration('DNS_DEFAULT_TTL');
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new TXT record');
		INSERT INTO "dns"."txt" ("alias","hostname","zone","ttl","owner","TYPE") VALUES
		(input_hostname,input_zone,input_text,input_ttl,input_owner,input_type);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_txt');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_text"(text, text, text, text, integer, text) IS 'create a new dns text record for a host';