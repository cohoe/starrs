/* API - create_dns_key
	1) Check privileges
	2) Input sanitization
	3) Create new key
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_key"(input_keyname text, input_key text, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_key');

		-- Sanitize input
		input_keyname := api.sanitize_general(input_keyname);
		input_key := api.sanitize_general(input_key);
		input_comment := api.sanitize_general(input_comment);

		-- Create new key
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns key');
		INSERT INTO "dns"."keys"
		("keyname","key","comment","last_modifier") VALUES
		(input_keyname,input_key,input_comment,api.get_current_user());

		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_key"(text, text, text) IS 'Create new DNS key';

/* API - remove_dns_key
	1) Check privileges
	2) Input sanitization
	3) Remove dns key
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_key"(input_keyname text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_key');

		-- Sanitize input
		input_keyname := api.sanitize_general(input_keyname);

		-- Remove key		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dns key');
		DELETE FROM "dns"."keys" WHERE "keyname" = input_keyname;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_key"(text) IS 'Delete existing DNS key';

/* API - create_dns_zone
	1) Check privileges
	2) Input sanitization
	3) Create zone (domain)
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_zone"(input_zone text, input_keyname text, input_forward boolean, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_zone');

		-- Sanitize input
		input_zone := api.sanitize_general(input_zone);
		input_keyname := api.sanitize_general(input_keyname);
		input_comment := api.sanitize_general(input_comment);

		-- Create zone
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns zone');
		INSERT INTO "dns"."zones" ("zone","keyname","forward","comment","last_modifier") VALUES
		(input_zone,input_keyname,input_forward,input_comment,api.get_current_user());

		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_zone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_zone"(text, text, boolean, text) IS 'Create a new DNS zone';

/* API - remove_dns_zone
	1) Check privileges
	2) Input sanitization
	3) Delete zone
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_zone"(input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_zone');

		-- Sanitize input
		input_zone := api.sanitize_general(input_zone);

		-- Delete zone
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dns zone');
		DELETE FROM "dns"."zones"
		WHERE "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_zone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_zone"(text) IS 'Delete existing DNS zone';

/* API - create_dns_address
	1) Check privileges
	2) Input sanitization
	3) Set owner
	4) Validate hostname
	5) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_address"(input_address inet, input_hostname text, input_zone text, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.create_dns_address');

		-- Sanitize input
		input_address := api.sanitize_general(input_address);
		input_hostname := api.sanitize_general(input_hostname);
		input_zone := api.sanitize_general(input_zone);
		input_owner := api.sanitize_general(input_owner);
		
		-- Set owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;
		
		-- Validate hostname
		PERFORM api.validate_hostname(input_hostname || '.' || input_zone);
		
		-- Create record
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new address record');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","last_modifier","owner") VALUES 
			(input_hostname,input_zone,input_address,DEFAULT,api.get_current_user(),input_owner);
		ELSE
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","last_modifier","owner") VALUES 
			(input_hostname,input_zone,input_address,input_ttl,api.get_current_user(),input_owner);
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"(inet, text, text, integer, text) IS 'create a new A or AAAA record';

/* API - remove_dns_address
	1) Check privileges
	2) Input sanitization
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.remove_dns_address');

		-- Sanitize input
		input_address := api.sanitize_general(input_address);

		-- Remove record
		PERFORM api.create_log_entry('API', 'INFO', 'deleting address record');
		DELETE FROM "dns"."a" WHERE "address" = input_address;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_address"(inet) IS 'delete an A or AAAA record';

/* API - create_mailserver
	1) Check privileges
	2) Input sanitization
	3) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_mailserver"(input_hostname text, input_domain text, input_preference integer, input_ttl integer) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_mailserver');
		
		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new mailserver (MX)');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl","owner") VALUES
			(input_hostname,input_domain,input_preference,DEFAULT,api.get_current_user());
		ELSE
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl","owner") VALUES
			(input_hostname,input_domain,input_preference,input_ttl,api.get_current_user());
		END IF;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_mailserver"(text, text, integer, integer) IS 'Create a new mailserver MX record for a zone';

/* API - remove_mailserver 
	1) Check privileges
	2) Input sanitization
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_mailserver"(input_hostname text, input_domain text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_mailserver');

		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','deleting mailserver (MX)');
		DELETE FROM "dns"."mx" WHERE "hostname" = input_hostname AND "zone" = input_domain;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_mailserver"(text, text) IS 'Delete an existing MX record for a zone';

/* API - get_reverse_domain 
	1) Return reverse string
*/
CREATE OR REPLACE FUNCTION "api"."get_reverse_domain"(INET) RETURNS TEXT AS $$
	use strict;
	use warnings;
	use Net::IP;
	use Net::IP qw(:PROC);
	
	# Return the rdns string for nsupdate from the given address. Automagically figures out IPv4 and IPv6.
	return new Net::IP ($_[0])->reverse_ip() or die (Net::IP::Error());
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_reverse_domain"(inet) IS 'Use a convenient Perl module to generate and return the RDNS record for a given address';

/* API - create_nameserver
	1) Sanitize input
	2) Check privileges
	3) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_nameserver"(input_hostname text, input_domain text, input_isprimary boolean, input_ttl integer) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_nameserver');
		
		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new NS record');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."ns" ("hostname","zone","isprimary","ttl","owner") VALUES
			(input_hostname,input_zone,input_isprimary,DEFAULT,api.get_current_user());
		ELSE
			INSERT INTO "dns"."ns" ("hostname","zone","isprimary","ttl","owner") VALUES
			(input_hostname,input_zone,input_isprimary,input_ttl,api.get_current_user());
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_nameserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_nameserver"(text, text, boolean, integer) IS 'create a new NS record for the zone';

/* API - remove_nameserver
	1) Sanitize input
	2) Check privileges
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_nameserver"(input_hostname text, input_domain text, input_record_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_nameserver');
		
		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);
		input_record_zone := api.sanitize_general(input_record_zone);

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove NS record');
		DELETE FROM "dns"."ns" WHERE "hostname" = input_hostname AND "zone" = input_domain AND "record_zone" = input_record_zone;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_nameserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_nameserver"(text, text, text) IS 'remove a NS record from the zone';


/* API - create_dns_srv
	1) Sanitize input
	2) Check privileges
	3) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_srv"(input_alias text, input_target text, input_zone text, input_priority integer, input_weight integer, input_port integer, input_ttl integer) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_srv');

		-- Sanitize input
		input_alias := api.sanitize_general(input_alias);
		input_target := api.sanitize_general(input_target);
		input_zone := api.sanitize_general(input_zone);
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new SRV record');

		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","extra","ttl","username","type") VALUES
			(input_alias || '.' || input_zone, input_target, input_zone, input_priority || ' ' || input_weight || ' ' || input_port, DEFAULT,api.get_current_user(),'SRV');
		ELSE
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","extra","ttl","username","TYPE") VALUES
			(input_alias, input_target, input_zone, input_priority || ' ' || input_weight || ' ' || input_port, input_ttl,api.get_current_user(),'SRV');
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_srv');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_srv"(text, text, text, integer, integer, integer, integer) IS 'create a new dns srv record for a zone';

/* API - remove_dns_srv
	1) Sanitize input
	2) Check privileges
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_srv"(input_alias text, input_target text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_srv');
		
		-- Sanitize input
		input_alias := api.sanitize_general(input_alias);
		input_target := api.sanitize_general(input_target);
		input_zone := api.sanitize_general(input_zone);

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove SRV record');
		DELETE FROM "dns"."pointers" WHERE "alias" = input_alias AND "hostname" = input_target AND "zone" = input_zone AND "type" = 'SRV';
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_srv');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_srv"(text, text, text) IS 'remove a dns srv record';

/* API - create_dns_cname
	1) Sanitize input
	2) Check privileges
	3) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_cname"(input_alias text, input_target text, input_zone text, input_ttl integer) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_cname');

		-- Sanitize input
		input_alias := api.sanitize_general(input_alias);
		input_target := api.sanitize_general(input_target);
		input_zone := api.sanitize_general(input_zone);
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new SRV record');

		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","extra","ttl","username","type") VALUES
			(input_alias || '.' || input_zone, input_target, input_zone, input_priority || ' ' || input_weight || ' ' || input_port, DEFAULT,api.get_current_user(),'CNAME');
		ELSE
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","ttl","username","TYPE") VALUES
			(input_alias, input_target, input_zone, input_ttl,api.get_current_user(),'CNAME');
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_cname');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_cname"(text, text, text, integer) IS 'create a new dns cname record for a host';

/* API - remove_dns_cname
	1) Sanitize input
	2) Check privileges
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_cname"(input_alias text, input_target text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_cname');
		
		-- Sanitize input
		input_alias := api.sanitize_general(input_alias);
		input_target := api.sanitize_general(input_target);
		input_zone := api.sanitize_general(input_zone);

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove CNAME record');
		DELETE FROM "dns"."pointers" WHERE "alias" = input_alias AND "hostname" = input_target AND "zone" = input_zone AND "type" = 'CNAME';
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_cname');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_cname"(text, text, text) IS 'remove a dns cname record for a host';

/* API - create_dns_txt
	1) Sanitize input
	2) Check privileges
	3) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_txt"(input_hostname text, input_zone text, input_text text, input_type text, input_ttl integer) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_txt');

		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_zone := api.sanitize_general(input_zone);
		input_type := api.sanitize_general(input_type);
		input_text := api.sanitize_general(input_text);
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new TXT record');

		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."txt" ("hostname","zone","text","ttl","username","type") VALUES
			(input_hostname,input_zone,input_text,DEFAULT,api.get_current_user(),input_type);
		ELSE
			INSERT INTO "dns"."txt" ("alias","hostname","zone","ttl","username","TYPE") VALUES
			(input_hostname,input_zone,input_text,input_ttl,api.get_current_user(),input_type);	
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_txt');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_txt"(text, text, text, text, integer) IS 'create a new dns txt record for a host';

/* API - remove_dns_txt
	1) Sanitize input
	2) Check privileges
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_txt"(input_hostname text, input_zone text, input_type text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_txt');
		
		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_zone := api.sanitize_general(input_zone);
		input_type := api.sanitize_general(input_type);

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove TXT record');
		DELETE FROM "dns"."txt" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "type" = input_type;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_txt');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_txt"(text, text, text) IS 'remove a dns txt record for a host';
