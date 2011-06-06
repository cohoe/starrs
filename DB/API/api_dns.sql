/* API - create_dns_key
	1) Check privileges
	2) Validate input
	3) Create new key
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_key"(input_keyname text, input_key text, input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_key');

		-- Validate input
		input_keyname := api.validate_nospecial(input_keyname);

		-- Create new key
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns key');
		INSERT INTO "dns"."keys"
		("keyname","key","comment") VALUES
		(input_keyname,input_key,input_comment);

		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_key"(text, text, text) IS 'Create new DNS key';

/* API - remove_dns_key
	1) Check privileges
	2) Remove dns key
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_key"(input_keyname text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_key');

		-- Remove key		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dns key');
		DELETE FROM "dns"."keys" WHERE "keyname" = input_keyname;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_key"(text) IS 'Delete existing DNS key';

/* API - create_dns_zone
	1) Check privileges
	2) Validate input
	3) Fill in owner
	3) Create zone (domain)
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_zone"(input_zone text, input_keyname text, input_forward boolean, input_comment text, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_zone');

		-- Validatae input
		IF api.validate_domain(NULL,input_zone) IS FALSE THEN
			RAISE EXCEPTION 'Invalid domain (%)',input_zone;
		END IF;
		
		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner = api.get_current_user();
		END IF;

		-- Create zone
		PERFORM api.create_log_entry('API', 'INFO', 'creating new dns zone');
		INSERT INTO "dns"."zones" ("zone","keyname","forward","comment","owner") VALUES
		(input_zone,input_keyname,input_forward,input_comment,input_owner);

		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_zone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_zone"(text, text, boolean, text, text) IS 'Create a new DNS zone';

/* API - remove_dns_zone
	1) Check privileges
	2) Delete zone
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_zone"(input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_zone');

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
	2) Set owner
	3) Set zone
	4) Validate hostname
	5) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_address"(input_address inet, input_hostname text, input_zone text, input_ttl integer, input_owner text) RETURNS VOID AS $$
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
		
		-- Validate hostname
		IF api.validate_domain(input_hostname,input_zone) IS FALSE THEN
			RAISE EXCEPTION 'Invalid hostname (%) and domain (%)',input_hostname,input_zone;
		END IF;
		
		-- Create record
		PERFORM api.create_log_entry('API', 'INFO', 'Creating new address record');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","owner") VALUES 
			(input_hostname,input_zone,input_address,DEFAULT,input_owner);
		ELSE
			INSERT INTO "dns"."a" ("hostname","zone","address","ttl","owner") VALUES 
			(input_hostname,input_zone,input_address,input_ttl,input_owner);
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"(inet, text, text, integer, text) IS 'create a new A or AAAA record';

/* API - remove_dns_address
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.remove_dns_address');

		-- Remove record
		PERFORM api.create_log_entry('API', 'INFO', 'deleting address record');
		DELETE FROM "dns"."a" WHERE "address" = input_address;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_address"(inet) IS 'delete an A or AAAA record';

/* API - create_dns_mailserver
	1) Check privileges
	2) Set owner
	3) Set zone
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
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new mailserver (MX)');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl","owner") VALUES
			(input_hostname,input_zone,input_preference,DEFAULT,input_owner);
		ELSE
			INSERT INTO "dns"."mx" ("hostname","zone","preference","ttl","owner") VALUES
			(input_hostname,input_zone,input_preference,input_ttl,input_owner);
		END IF;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.create_dns_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_mailserver"(text, text, integer, integer, text) IS 'Create a new mailserver MX record for a zone';

/* API - remove_dns_mailserver 
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_mailserver"(input_hostname text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_mailserver');

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','deleting mailserver (MX)');
		DELETE FROM "dns"."mx" WHERE "hostname" = input_hostname AND "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_mailserver"(text, text) IS 'Delete an existing MX record for a zone';

/* API - get_reverse_domain 
	1) Return reverse string
*/
CREATE OR REPLACE FUNCTION "api"."get_reverse_domain"(INET) RETURNS TEXT AS $$
	use strict;
	use warnings;
	use Net::IP;
	use Net::IP qw(:PROC);
	
	# Return the rdns string for nsupdate from the given address. Automagically figures out IPv4 and IPv6.
	my $reverse_domain = new Net::IP ($_[0])->reverse_ip() or die (Net::IP::Error());
	$reverse_domain =~ s/\.$//;
	return $reverse_domain;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_reverse_domain"(inet) IS 'Use a convenient Perl module to generate and return the RDNS record for a given address';

/* API - create_dns_nameserver
	2) Check privileges
	3) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_nameserver"(input_hostname text, input_zone text, input_isprimary boolean, input_ttl integer, input_owner text) RETURNS VOID AS $$
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
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','creating new NS record');
		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."ns" ("hostname","zone","isprimary","ttl","owner") VALUES
			(input_hostname,input_zone,input_isprimary,DEFAULT,input_owner);
		ELSE
			INSERT INTO "dns"."ns" ("hostname","zone","isprimary","ttl","owner") VALUES
			(input_hostname,input_zone,input_isprimary,input_ttl,input_owner);
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_nameserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_nameserver"(text, text, boolean, integer, text) IS 'create a new NS record for the zone';

/* API - remove_dns_nameserver
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_nameserver"(input_hostname text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_nameserver');

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove NS record');
		DELETE FROM "dns"."ns" WHERE "hostname" = input_hostname AND "zone" = input_zone;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_nameserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_nameserver"(text, text) IS 'remove a NS record from the zone';


/* API - create_dns_srv
	1) Validate input
	2) Check privileges
	3) Set owner
	4) Set zone
	5) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_srv"(input_alias text, input_target text, input_zone text, input_priority integer, input_weight integer, input_port integer, input_ttl integer, input_owner text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_dns_srv');

		-- Validate input
		IF api.validate_srv(input_alias,NULL) IS FALSE THEN
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
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new SRV record');

		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","extra","ttl","owner","type") VALUES
			(input_alias, input_target, input_zone, input_priority || ' ' || input_weight || ' ' || input_port, DEFAULT,input_owner,'SRV');
		ELSE
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","extra","ttl","owner","TYPE") VALUES
			(input_alias, input_target, input_zone, input_priority || ' ' || input_weight || ' ' || input_port, input_ttl,input_owner,'SRV');
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_srv');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_srv"(text, text, text, integer, integer, integer, integer, text) IS 'create a new dns srv record for a zone';

/* API - remove_dns_srv
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_srv"(input_alias text, input_target text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_srv');

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove SRV record');
		DELETE FROM "dns"."pointers" WHERE "alias" = input_alias AND "hostname" = input_target AND "zone" = input_zone AND "type" = 'SRV';
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_srv');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_srv"(text, text, text) IS 'remove a dns srv record';

/* API - create_dns_cname
	1) Validate input
	2) Check privileges
	3) Create record
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
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new SRV record');

		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","ttl","owner","type") VALUES
			(input_alias, input_target, input_zone, DEFAULT,input_owner,'CNAME');
		ELSE
			INSERT INTO "dns"."pointers" ("alias","hostname","zone","ttl","owner","TYPE") VALUES
			(input_alias, input_target, input_zone, input_ttl,input_owner,'CNAME');
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_cname');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_cname"(text, text, text, integer, text) IS 'create a new dns cname record for a host';

/* API - remove_dns_cname
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_cname"(input_alias text, input_target text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_cname');

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove CNAME record');
		DELETE FROM "dns"."pointers" WHERE "alias" = input_alias AND "hostname" = input_target AND "zone" = input_zone AND "type" = 'CNAME';
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_cname');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_cname"(text, text, text) IS 'remove a dns cname record for a host';

/* API - create_dns_txt
	1) Check privileges
	2) Create record
*/
CREATE OR REPLACE FUNCTION "api"."create_dns_txt"(input_hostname text, input_zone text, input_text text, input_type text, input_ttl integer, input_owner text) RETURNS VOID AS $$
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
		
		-- Create record
		PERFORM api.create_log_entry('API','INFO','create new TXT record');

		IF input_ttl IS NULL THEN
			INSERT INTO "dns"."txt" ("hostname","zone","text","ttl","owner","type") VALUES
			(input_hostname,input_zone,input_text,DEFAULT,input_owner,input_type);
		ELSE
			INSERT INTO "dns"."txt" ("alias","hostname","zone","ttl","owner","TYPE") VALUES
			(input_hostname,input_zone,input_text,input_ttl,input_owner,input_type);	
		END IF;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_dns_txt');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_txt"(text, text, text, text, integer, text) IS 'create a new dns txt record for a host';

/* API - remove_dns_txt
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_txt"(input_hostname text, input_zone text, input_type text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_txt');

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove TXT record');
		DELETE FROM "dns"."txt" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "type" = input_type;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_txt');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_txt"(text, text, text) IS 'remove a dns txt record for a host';

/* API - validate_domain */
CREATE OR REPLACE FUNCTION "api"."validate_domain"(hostname text, domain text) RETURNS BOOLEAN AS $$
	use strict;
	use warnings;
	use Data::Validate::Domain qw(is_domain);

	# Usage: PERFORM api.validate_domain([hostname OR NULL],[domain OR NULL]);

	# Declare the string to check later on
	my $domain;

	# This script can deal with just domain validation rather than host-domain. Note that the
	# module this depends on requires a valid TLD, so one is picked for this purpose.
	if (!$_[0])
	{
		# We are checking a domain name only
		$domain = $_[1];
	}
	elsif (!$_[1])
	{
		# We are checking a hostname only
		$domain = "$_[0].me";
	}
	else
	{
		# We have enough for a FQDN
		$domain = "$_[0].$_[1]";
	}

	# Return a boolean value of whether the input forms a valid domain
	if (is_domain($domain))
	{
		return 'TRUE';
	}
	else
	{
		return 'FALSE';
	}
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."validate_domain"(text, text) IS 'Validate hostname, domain, FQDN based on known rules. Requires Perl module';
