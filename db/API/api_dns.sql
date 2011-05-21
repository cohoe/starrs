/* API - create_dns_key
	1) Check privileges
	2) Input sanitization
	3) Create new key
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_key"(input_keyname text, input_key text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_key');

		-- Sanitize input
		input_keyname := api.sanitize_general(input_keyname);
		input_key := api.sanitize_general(input_key);
		input_comment := api.sanitize_general(input_comment);

		-- Create new key
		SELECT api.create_log_entry('API', 'INFO', 'creating new dns key');
		INSERT INTO "dns"."keys"
		("keyname","key","comment","last_modifier") VALUES
		(input_keyname,input_key,input_comment,api.get_current_user());

		SELECT api.create_log_entry('API','DEBUG','Finish api.create_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_key"() IS 'Create new DNS key';

/* API - remove_dns_key
	1) Check privileges
	2) Input sanitization
	3) Remove dns key
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_key"(input_keyname text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_key');

		-- Sanitize input
		input_keyname := api.sanitize_general(input_keyname);

		-- Remove key		
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dns key');
		DELETE FROM "dns"."keys" WHERE "keyname" = input_keyname;

		SELECT api.create_log_entry('API','DEBUG','Finish api.remove_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_key"() IS 'Delete existing DNS key';

/* API - create_dns_zone
	1) Check privileges
	2) Input sanitization
	3) Create zone (domain)
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_zone"(input_zone text, input_keyname text, input_forward boolean,input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_zone');

		-- Sanitize input
		input_zone := api.sanitize_general(input_zone);
		input_keyname := api.sanitize_general(input_keyname);
		input_forward := api.sanitize_general(input_forward);
		input_comment := api.sanitize_general(input_comment);

		-- Create zone
		SELECT api.create_log_entry('API', 'INFO', 'creating new dns zone');
		INSERT INTO "dns"."zones" ("zone","keyname","forward","comment","last_modifier") VALUES
		(input_zone,input_keyname,input_forward,input_comment,api.get_current_user());

		SELECT api.create_log_entry('API','DEBUG','Finish api.create_dns_zone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_zone"() IS 'Create a new DNS zone';

/* API - remove_dns_zone
	1) Check privileges
	2) Input sanitization
	3) Delete zone
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_zone"(input_zone text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_zone');

		-- Sanitize input
		input_zone := api.sanitize_general(input_zone);

		-- Delete zone
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dns zone');
		DELETE FROM "dns"."zones"
		WHERE "zone" = input_zone;

		SELECT api.create_log_entry('API','DEBUG','Finish api.remove_dns_zone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_zone"() IS 'Delete existing DNS zone';

/* API - create_dns_address
	1) Check privileges
	2) Input sanitization
	3) Set owner
	4) Validate hostname
	5) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_address"(input_address inet, input_hostname text, input_zone text, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_dns_address');

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
		SELECT api.validate_hostname(input_hostname || '.' || input_zone);
		
		-- Create record
		SELECT api.create_log_entry('API', 'INFO', 'Creating new address record');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","last_modifier","owner") VALUES 
			(input_hostname,input_zone,input_address,DEFAULT,api.get_current_user(),input_owner);
		ELSE
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","last_modifier","owner") VALUES 
			(input_hostname,input_zone,input_address,input_ttl,api.get_current_user(),input_owner);
		END IF;
		
		SELECT api.create_log_entry('API','DEBUG','Finish api.create_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"() IS 'create a new A or AAAA record';

/* API - remove_dns_address
	1) Check privileges
	2) Input sanitization
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.remove_dns_address');

		-- Sanitize input
		input_address := api.sanitize_general(input_address);

		-- Remove record
		SELECT api.create_log_entry('API', 'INFO', 'deleting address record');
		DELETE FROM "dns"."a" WHERE "address" = input_address;

		SELECT api.create_log_entry('API','DEBUG','Finish api.remove_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"() IS 'delete an A or AAAA record';

/* API - create_mailserver
	1) Check privileges
	2) Input sanitization
	3) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_mailserver"(input_hostname text, input_domain text, input_preference integer, input_ttl integer) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.create_mailserver');
		
		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);
		
		-- Create record
		SELECT api.create_log_entry('API','INFO','creating new mailserver (MX)');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl") VALUES
			(input_hostname,input_domain,input_preference,DEFAULT);
		ELSE
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl") VALUES
			(input_hostname,input_domain,input_preference,input_ttl);
		END IF;

		SELECT api.create_log_entry('API','DEBUG','Finish api.create_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_mailserver"() IS 'Create a new mailserver MX record for a zone';

/* API - remove_mailserver 
	1) Check privileges
	2) Input sanitization
	3) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_mailserver"(input_hostname text, input_domain text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.remove_mailserver');

		-- Sanitize input
		input_hostname := api.sanitize_general(input_hostname);
		input_domain := api.sanitize_general(input_domain);

		-- Remove record
		SELECT api.create_log_entry('API','INFO','deleting mailserver (MX)');
		DELETE FROM "dns"."mx" WHERE "hostname" = input_hostname AND "zone" = input_domain;

		SELECT api.create_log_entry('API','DEBUG','Finish api.remove_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_mailserver"() IS 'Delete an existing MX record for a zone';

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
COMMENT ON FUNCTION "api"."get_reverse_domain"() IS 'Use a convenient Perl module to generate and return the RDNS record for a given address';
