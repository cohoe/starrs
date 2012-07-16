/* api_dns_create.sql
	1) create_dns_key
	2) create_dns_zone
	3) create_dns_address
	4) create_dns_mailserver
	5) create_dns_nameserver
	6) create_dns_srv
	7) create_dns_cname
	8) create_dns_txt
	9) create_dns_soa
*/

/* API - create_dns_key
	1) Validate input
	2) Fill in owner
	3) Check privileges
	3) Create new key
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_key"(input_keyname text, input_key text, input_owner text, input_comment text) RETURNS SETOF "dns"."keys" AS $$
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
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
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
		RETURN QUERY (SELECT * FROM "dns"."keys" WHERE "keyname" = input_keyname AND "key" = input_key);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_key"(text, text, text, text) IS 'Create new DNS key';

/* API - create_dns_zone
	1) Validate input
	2) Fill in owner
	3) Create zone (domain)
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_zone"(input_zone text, input_keyname text, input_forward boolean, input_shared boolean, input_owner text, input_comment text, input_ddns boolean) RETURNS SETOF "dns"."zones" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_zone');

		-- Validate input
		IF api.validate_domain(NULL,input_zone) IS FALSE THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid domain');
			RAISE EXCEPTION 'Invalid domain (%)',input_zone;
		END IF;

		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner = api.get_current_user();
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			PERFORM api.create_log_entry('API','ERROR','Permission denied');
			RAISE EXCEPTION 'Permission to create zone % denied for user %. Not admin.',input_zone,api.get_current_user();
		END IF;
		
		-- Create zone
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns zone');
		INSERT INTO "dns"."zones" ("zone","keyname","forward","comment","owner","shared","ddns") VALUES
		(input_zone,input_keyname,input_forward,input_comment,input_owner,input_shared,input_ddns);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_zone');
		RETURN QUERY (SELECT * FROM "dns"."zones" WHERE "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_zone"(text, text, boolean, boolean, text, text, boolean) IS 'Create a new DNS zone';

/* API - create_dns_address
	1) Set owner
	2) Set zone
	3) Set ttl
	4) Check privileges
	5) Validate hostname
	6) Create record
	7) Queue dns
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_address"(input_address inet, input_hostname text, input_zone text, input_ttl integer, input_type text, input_reverse boolean, input_owner text) RETURNS SETOF "dns"."a" AS $$
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

		-- Autofill Type
		IF input_type IS NULL THEN
			IF family(input_address) = 4 THEN
				input_type := 'A';
			ELSEIF family(input_address) = 6 THEN
				input_type := 'AAAA';
			END IF;
		END IF;

		-- Check type
		IF input_type !~* '^A|AAAA$' THEN
			RAISE EXCEPTION 'Bad type % given',input_type;
		END IF;

		-- Validate type
		IF family(input_address) = 4 AND input_type !~* '^A$' THEN
			RAISE EXCEPTION 'IPv4 Address/Type mismatch';
		ELSEIF family(input_address) = 6 AND input_type !~* '^AAAA$' THEN
			RAISE EXCEPTION 'IPv6 Address/Type mismatch';
		END IF;
		
		-- User can only specify TTL if address is static
		IF (SELECT "config" FROM "systems"."interface_addresses" WHERE "address" = input_address) !~* 'static' AND input_ttl != (SELECT "value"::integer/2 AS "ttl" FROM "dhcp"."subnet_options" WHERE "option"='default-lease-time' AND "subnet" >> input_address) THEN
			RAISE EXCEPTION 'You can only specify a TTL other than the default if your address is configured statically';
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "shared" FROM "dns"."zones" WHERE "zone" = input_zone) IS FALSE
			AND (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-shared zone');
				RAISE EXCEPTION 'DNS zone % is not shared and you are not owner. Permission denied.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Validate hostname
		IF api.validate_domain(input_hostname,input_zone) IS FALSE THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid hostname');
			RAISE EXCEPTION 'Invalid hostname (%) and domain (%)',input_hostname,input_zone;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new address record');
		INSERT INTO "dns"."a" ("hostname","zone","address","ttl","type","owner","reverse") VALUES 
		(input_hostname,input_zone,input_address,input_ttl,input_type,input_owner,input_reverse);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_address');
		RETURN QUERY (SELECT * FROM "dns"."a" WHERE "address" = input_address AND "hostname" = input_hostname AND "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"(inet, text, text, integer, text, boolean, text) IS 'create a new A or AAAA record';

/* API - create_dns_mailserver
	1) Set owner
	2) Set zone
	3) Check privileges
	4) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_mailserver"(input_hostname text, input_zone text, input_preference integer, input_ttl integer, input_owner text) RETURNS SETOF "dns"."mx" AS $$
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
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone');
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new mailserver (MX)');
		INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl","owner","type") VALUES
		(input_hostname,input_zone,input_preference,input_ttl,input_owner,'MX');
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_mailserver');
		RETURN QUERY (SELECT * FROM "dns"."mx" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "preference" = input_preference);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_mailserver"(text, text, integer, integer, text) IS 'Create a new mailserver MX record for a zone';

/* API - create_dns_nameserver
	1) Set owner
	2) Set zone
	3) Check privileges
	4) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_ns"(input_zone text, input_nameserver text, input_address inet, input_ttl integer) RETURNS SETOF "dns"."ns" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_ns');

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
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone.');
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new NS record');
		INSERT INTO "dns"."ns" ("zone","ttl","nameserver","address") VALUES
		(input_zone,input_ttl,input_nameserver,input_address);
		
		-- Update TTLs of other zone records since they all need to be the same
		UPDATE "dns"."ns" SET "ttl" = input_ttl WHERE "zone" = input_zone;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_ns');
		RETURN QUERY (SELECT * FROM "dns"."ns" WHERE "zone" = input_zone AND "nameserver" = input_nameserver);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_ns"(text, text, inet, integer) IS 'create a new NS record for a zone';

/* API - create_dns_srv
	1) Validate input
	2) Set owner
	3) Set zone
	4) Check privileges
	5) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_srv"(input_alias text, input_target text, input_zone text, input_priority integer, input_weight integer, input_port integer, input_ttl integer, input_owner text) RETURNS SETOF "dns"."srv" AS $$
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
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone');
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new SRV record');
		INSERT INTO "dns"."srv" ("alias","hostname","zone","priority","weight","port","ttl","owner") VALUES
		(input_alias, input_target, input_zone, input_priority, input_weight, input_port, input_ttl, input_owner);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_srv');
		RETURN QUERY (SELECT * FROM "dns"."srv" WHERE "alias" = input_alias AND "hostname" = input_target AND "zone" = input_zone AND "priority" = input_priority AND "weight" = input_weight AND "port" = input_port);
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
CREATE OR REPLACE FUNCTION "api"."create_dns_cname"(input_alias text, input_target text, input_zone text, input_ttl integer, input_owner text) RETURNS SETOF "dns"."cname" AS $$
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
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone.');
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new CNAME record');
		INSERT INTO "dns"."cname" ("alias","hostname","zone","ttl","owner") VALUES
		(input_alias, input_target, input_zone, input_ttl, input_owner);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_cname');
		RETURN QUERY (SELECT * FROM "dns"."cname" WHERE "alias" = input_alias AND "hostname" = input_target AND "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_cname"(text, text, text, integer, text) IS 'create a new dns cname record for a host';

/* API - create_dns_text
	1) Set owner
	2) Set zone
	3) Check privileges
	4) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_txt"(input_hostname text, input_zone text, input_text text, input_ttl integer, input_owner text) RETURNS SETOF "dns"."txt" AS $$
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
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone');
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
			IF input_owner != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_owner;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new TXT record');
		INSERT INTO "dns"."txt" ("hostname","zone","text","ttl","owner") VALUES
		(input_hostname,input_zone,input_text,input_ttl,input_owner);
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_txt');
		RETURN QUERY (SELECT * FROM "dns"."txt" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "text" = input_text);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_txt"(text, text, text, integer, text) IS 'create a new dns TXT record for a host';

/* API - create_dns_soa
	1) Validate input
	2) Check privileges
	3) Create SOA
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_soa"(input_zone text, input_ttl integer, input_nameserver text, input_contact text, input_serial text, input_refresh integer, input_retry integer, input_expire integer, input_minimum integer) RETURNS SETOF "dns"."soa" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_soa');

		-- Validate input
		IF api.validate_soa_contact(input_contact) IS FALSE THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid SOA contact given');
			RAISE EXCEPTION 'Invalid SOA contact given (%)',input_contact;
		END IF;

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission to create SOA % denied for user %. Not admin.',input_zone,api.get_current_user();
			END IF;
		END IF;
		
		-- Create soa
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns SOA');
		INSERT INTO "dns"."soa" ("zone","ttl","nameserver","contact","serial","refresh","retry","expire","minimum") VALUES
		(input_zone,input_ttl,input_nameserver,input_contact,input_serial,input_refresh,input_retry,input_expire,input_minimum);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_soa');
		RETURN QUERY (SELECT * FROM "dns"."soa" WHERE "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_soa"(text, integer, text, text, text, integer, integer, integer, integer) IS 'Create a new DNS soa';

CREATE OR REPLACE FUNCTION "api"."create_dns_zone_txt"(input_hostname text, input_zone text, input_text text, input_ttl integer) RETURNS SETOF "dns"."zone_txt" AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_zone_txt');

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
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone');
				RAISE EXCEPTION 'Permission denied on zone %. You are not owner.',input_zone;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new zone_txt record');
		INSERT INTO "dns"."zone_txt" ("hostname","zone","text","ttl") VALUES
		(input_hostname,input_zone,input_text,input_ttl);
		
		-- Update TTLs for other null hostname records since they all need to be the same.
		IF input_hostname IS NULL THEN
			UPDATE "dns"."zone_txt" SET "ttl" = input_ttl WHERE "hostname" IS NULL AND "zone" = input_zone;
		END IF;
		
		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_zone_txt');
		IF input_hostname IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" IS NULL AND "zone" = input_zone AND "text" = input_text);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "text" = input_text);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_zone_txt"(text, text, text, integer) IS 'create a new dns zone_txt record for a host';

CREATE OR REPLACE FUNCTION "api"."create_dns_zone_a"(input_zone text, input_address inet, input_ttl integer) RETURNS SETOF "dns"."zone_a" AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.create_dns_zone_a');

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
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone');
				RAISE EXCEPTION 'DNS zone % is not shared and you are not owner. Permission denied.',input_zone;
			END IF;
		END IF;

		-- Create record
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new zone address record');
		INSERT INTO "dns"."zone_a" ("zone","address","ttl") VALUES 
		(input_zone,input_address,input_ttl);

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_zone_a');
		RETURN QUERY (SELECT * FROM "dns"."zone_a" WHERE "zone" = input_zone AND "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_zone_a"(text, inet, integer) IS 'create a new zone A or AAAA record';
