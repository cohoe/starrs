/*Trigger Function API - create_system*/
CREATE OR REPLACE FUNCTION "api"."create_system"(input_system_name text, input_username text, input_type text, input_os_name text, input_comment text) RETURNS VOID AS $$
	BEGIN
		input_system_name := api.sanitize_general(input_system_name);
		input_username := api.sanitize_general(input_username);
		input_comment := api.sanitize_general(input_comment);

		IF input_username IS NULL THEN
			input_username := api.get_current_user();
		END IF;
		
		SELECT api.create_log_entry('API', 'INFO', 'Creating new system');
		INSERT INTO "systems"."systems"
			("system_name","username","type","os_name","comment","last_modifier") VALUES
			(input_system_name,input_username,input_type,input_os_name,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_system"() IS 'Create a new system';

/*Trigger Function API - delete_system*/
CREATE OR REPLACE FUNCTION "api"."delete_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_system');
		input_system_name := api.sanitize_general(input_system_name);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting system');
		DELETE FROM "systems"."systems" WHERE "system_name" = input_system_name;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_system"() IS 'Delete an existing system';

/*Trigger Function API - create_subnet*/
CREATE OR REPLACE FUNCTION "api"."create_subnet"(input_subnet cidr, input_name text, input_comment text, input_autogen boolean) RETURNS VOID AS $$
	DECLARE
		RowCount	INTEGER;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_subnet');
		input_subnet := api.sanitize_general(input_subnet);
		input_name := api.sanitize_general(input_name);
		input_comment := api.sanitize_general(input_comment);
		input_autogen  := api.sanitize_general(input_autogen);

		SELECT api.create_log_entry('API', 'INFO', 'creating new subnet');
		INSERT INTO "ip"."subnets" 
			("subnet","name","comment","autogen","last_modifier") VALUES
			(input_subnet,input_name,input_comment,input_autogen,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_subnet"() IS 'Create/activate a new subnet';

/*Trigger Function API - delete_subnet*/
CREATE OR REPLACE FUNCTION "api"."delete_subnet"(input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount	INTEGER;
		WasAuto		BOOLEAN;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_subnet');
		input_subnet := api.sanitize_general(input_subnet);

		SELECT api.create_log_entry('API', 'INFO', 'Deleting subnet');
		DELETE FROM "ip"."subnets" WHERE "subnet" = input_subnet;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_subnet"() IS 'Delete/deactivate an existing subnet';

/*Trigger Function API - create_ip_range*/
CREATE OR REPLACE FUNCTION "api"."create_ip_range"(input_first_ip inet, input_last_ip inet, input_subnet cidr, input_use varchar(4), input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_ip_range');
		input_first_ip := api.sanitize_general(input_first_ip);
		input_last_ip := api.sanitize_general(input_last_ip);
		input_subnet := api.sanitize_general(input_subnet);
		input_use := api.sanitize_general(input_use);
		input_comment := api.sanitize_general(input_comment);
		
		SELECT api.create_log_entry('API', 'INFO', 'creating new range');
		INSERT INTO "ip"."ranges" 
		("first_ip", "last_ip", "subnet", "use", "comment", "last_modifier")
		VALUES (input_first_ip,input_last_ip,input_subnet,input_use,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_ip_range"() IS 'Create a new range of IP addresses';

/*Trigger Function API - delete_ip_range*/
CREATE OR REPLACE FUNCTION "api"."delete_ip_range"(input_first_ip inet, input_last_ip inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_ip_range');
		input_first_ip := api.sanitize_general(input_first_ip);
		input_last_ip := api.sanitize_general(input_last_ip);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting range');
		DELETE FROM "ip"."ranges" WHERE "first_ip" = input_first_ip AND "last_ip" = input_last_ip;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_ip_range"() IS 'Delete an existing IP range';

/*Trigger Function API - create_dhcp_class*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class"(input_class text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class');
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);
		SELECT api.create_log_entry('API', 'INFO', 'creating new dhcp class');
		INSERT INTO "dhcp"."classes" ("class","comment","last_modifier") VALUES (input_class,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_dhcp_class"() IS 'Create a new DHCP class';

/*Trigger Function API - delete_dhcp_class*/
CREATE OR REPLACE FUNCTION "api"."delete_dhcp_class"(input_class text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dhcp_class');
		input_class := api.sanitize_general(input_class);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dhcp class');
		DELETE FROM "dhcp"."classes" WHERE "class" = input_class;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_dhcp_class"() IS 'Delete existing DHCP class';

/*Trigger Function API - create_dhcp_class_option*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_class_option');
		input_class := api.sanitize_general(input_class);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'creating new dhcp class option');
		INSERT INTO "dhcp"."class_options" 
		("class","option","value","last_modifier") VALUES
		(input_class,input_option,input_value,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_dhcp_class_option"() IS 'Create a new DHCP class option';

/*Trigger Function API - delete_dhcp_class_option*/
CREATE OR REPLACE FUNCTION "api"."delete_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dhcp_class_option');
		input_class := api.sanitize_general(input_class);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dhcp class option');
		DELETE FROM "dhcp"."class_options"
		WHERE "class" = input_class AND "option" = input_option AND "value" = input_value;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_dhcp_class_option"() IS 'Delete existing DHCP class option';

/*Trigger Function API - create_dhcp_subnet_option*/
CREATE OR REPLACE FUNCTION "api"."create_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dhcp_subnet_option');
		input_subnet := api.sanitize_general(input_subnet);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'creating dhcp subnet option');
		INSERT INTO "dhcp"."subnet_options" 
		("subnet","option","value","last_modifier") VALUES
		(input_subnet,input_option,input_value,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_dhcp_subnet_option"() IS 'Create DHCP subnet option';

/*Trigger Function API - delete_dhcp_subnet_option*/
CREATE OR REPLACE FUNCTION "api"."delete_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dhcp_subnet_option');
		input_subnet := api.sanitize_general(input_subnet);
		input_option := api.sanitize_dhcp(input_option);
		input_value := api.sanitize_dhcp(input_value);
		
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dhcp subnet option');
		DELETE FROM "dhcp"."subnet_options"
		WHERE "subnet" = input_subnet AND "option" = input_option AND "value" = input_value;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_dhcp_subnet_option"() IS 'Delete existing DHCP subnet option';

/*Trigger Function API - create_dns_key*/
CREATE OR REPLACE FUNCTION "api"."create_dns_key"(input_keyname text, input_key text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_key');
		input_keyname := api.sanitize_general(input_keyname);
		input_key := api.sanitize_general(input_key);
		input_comment := api.sanitize_general(input_comment);

		SELECT api.create_log_entry('API', 'INFO', 'creating new dns key');
		INSERT INTO "dns"."keys"
		("keyname","key","comment","last_modifier") VALUES
		(input_keyname,input_key,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_dns_key"() IS 'Create new DNS key';

/*Trigger Function API - delete_dns_key*/
CREATE OR REPLACE FUNCTION "api"."delete_dns_key"(input_keyname text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dns_key');
		input_keyname := api.sanitize_general(input_keyname);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting dns key');
		DELETE FROM "dns"."keys" WHERE "keyname" = input_keyname;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_dns_key"() IS 'Delete existing DNS key';

/*Trigger Function API - create_dns_zone*/
CREATE OR REPLACE FUNCTION "api"."create_dns_zone"(input_zone text, input_keyname text, input_forward boolean,input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_dns_zone');
		input_zone := api.sanitize_general(input_zone);
		input_keyname := api.sanitize_general(input_keyname);
		input_forward := api.sanitize_general(input_forward);
		input_comment := api.sanitize_general(input_comment);

		SELECT api.create_log_entry('API', 'INFO', 'creating new dns zone');
		INSERT INTO "dns"."zones" 
		("zone","keyname","forward","comment","last_modifier")
		VALUES
		(input_zone,input_keyname,input_forward,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_dns_zone"() IS 'Create a new DNS zone';

/*Trigger Function API - delete_dns_zone*/
CREATE OR REPLACE FUNCTION "api"."delete_dns_zone"(input_zone text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_dns_zone');
		input_zone := api.sanitize_general(input_zone);

		SELECT api.create_log_entry('API', 'INFO', 'Deleting dns zone');
		DELETE FROM "dns"."zones"
		WHERE "zone" = input_zone;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."delete_dns_zone"() IS 'Delete existing DNS zone';

/*Trigger Function API - create_log_entry*/
CREATE OR REPLACE FUNCTION "api"."create_log_entry"(input_source text, input_severity text, input_message text) RETURNS VOID AS $$
	BEGIN
		input_source := api.sanitize_general(input_source);
		input_severity := api.sanitize_general(input_severity);
		input_message := api.sanitize_general(input_message);
		
		INSERT INTO "management"."log_master"
		("source","user","severity","message") VALUES
		(input_source,api.get_current_user(),input_severity,input_message);
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_log_entry"() IS 'Function to insert a log entry';

/*Trigger Function API - sanitize_general*/
CREATE OR REPLACE FUNCTION "api"."sanitize_general"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap	TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\_\.\-\:]*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."sanitize_general"() IS 'Allow only certain characters for most common objects';

/*Trigger Function API - sanitize_dhcp*/
CREATE OR REPLACE FUNCTION "api"."sanitize_dhcp"(input text) RETURNS VOID AS $$
	DECLARE
		BadCrap	TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\_\.\=\"\,\(\)\/\; ]*\-*', '', 'gi');
		IF BadCrap != '' THEN
			--RAISE EXCEPTION 'Invalid characters detected in string "%"',BadCrap;
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."sanitize_dhcp"() IS 'Only allow certain characters in DHCP options';

/*Trigger Function API - get_current_user*/
CREATE OR REPLACE FUNCTION "api"."get_current_user" RETURNS TEXT AS $$
	DECLARE
		Username	TEXT;
	BEGIN
		-- Do stuff to check the table
		Username := 'cohoe_debug';
		RETURN Username;
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."get_current_user"() IS 'Get the username of the current session';

/*Trigger Function API - create_interface*/
CREATE OR REPLACE FUNCTION "api"."create_interface"(input_system_name text, input_interface_name text, input_mac macaddr, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.create_interface');
		
		input_system_name := api.sanitize_general(input_system_name);
		input_interface_name := api.sanitize_general(input_interface_name);
		input_mac := api.sanitize_general(input_mac);
		input_comment := api.sanitize_general(input_comment);
		
		SELECT api.create_log_entry('API','INFO','creating new interface';
		INSERT INTO "systems"."interfaces"
		("system_name","interface_name","mac","comment","last_modifier") VALUES
		(input_system_name,input_interface_name,input_mac,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."create_interface"() IS 'Create a new interface on a system';

/*Trigger Function API - delete_interface*/
CREATE OR REPLACE FUNCTION "api"."delete_interface"(input_mac macaddr) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.delete_interface');
		
		input_mac := api.sanitize_general(input_mac);
		
		SELECT api.create_log_entry('API','INFO','deleting interface';
		DELETE FROM "systems"."interfaces" WHERE "mac" = input_mac;
	END;
$$ LANGUAGE 'plpgqsql';

COMMENT ON FUNCTION "api"."delete_interface"() IS 'delete an interface based on MAC address';

/*Trigger Function API - create_interface_address_manual*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address_manual"(input_mac macaddr, input_address inet, input_config text, input_class text, input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address_manual');
		input_mac := api.sanitize_general(input_mac);
		input_address := api.sanitize_general(input_address);
		input_config := api.sanitize_general(input_config);
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);
		
		SELECT api.create_log_entry('API', 'INFO', 'Creating new address');
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier") VALUES
		(input_mac,input_address,input_config,input_class,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address_manual"() IS 'create a new address on interface manually';

/*Trigger Function IP - Get address from range*/
CREATE OR REPLACE FUNCTION "ip"."get_address_from_range"(input_range_name text) RETURNS INET AS $$
	DECLARE
		LowerBound		INET;
		UpperBound		INET;
		AddressToUse	INET;
	BEGIN
		input_range_name := api.sanitize_general(input_range_name);
	
		SELECT "first_ip","last_ip" INTO LowerBound,UpperBound
		FROM "ip"."ranges"
		WHERE "ip"."ranges"."name" = input_range_name;
		
		SELECT "address" FROM "ip"."addresses" INTO AddressToUse
		WHERE "address" <= UpperBound AND "address" >= LowerBound
		AND "address" NOT IN (SELECT "address" FROM "systems"."interface_addresses") ORDER BY "address" ASC LIMIT 1;
		
		IF AddressToUse IS NULL THEN
			SELECT api.create_log_entry('IP', 'ERROR', 'range full');
			RAISE EXCEPTION 'All addresses in range % are in use',input_range_name;
		END IF;
		
		RETURN AddressToUse;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "ip"."get_address_from_range"() IS 'get the first available address in a range';

/*Trigger Function API - create_interface_address_auto*/
CREATE OR REPLACE FUNCTION "api"."create_interface_address_auto"(input_mac macaddr, input_range_name text, input_config text, input_class text, input_comment text) RETURNS VOID AS $$
	DECLARE
		Address	INET;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.create_interface_address_range');
		input_mac := api.sanitize_general(input_mac);
		input_range_name := api.sanitize_general(input_range_name);
		input_config := api.sanitize_general(input_config);
		input_class := api.sanitize_general(input_class);
		input_comment := api.sanitize_general(input_comment);

		SELECT api.create_log_entry('API', 'INFO', 'Creating new address registration');
		INSERT INTO "systems"."interface_addresses" ("mac","address","config","class","comment","last_modifier") VALUES
		(input_mac,ip.get_address_from_range(input_range_name),input_config,input_class,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_interface_address_auto"() IS 'create a new address on interface from a range';

/*Trigger Function API - delete_interface_address*/
CREATE OR REPLACE FUNCTION "api"."delete_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.delete_interface_address');
		
		input_address := api.sanitize_general(input_address);
		
		SELECT api.create_log_entry('API','INFO','deleting interface address';
		DELETE FROM "systems"."interface_addresses" WHERE "address" = input_address;
	END;
$$ LANGUAGE 'plpgqsql';

COMMENT ON FUNCTION "api"."delete_interface_address"() IS 'delete an interface address';

/*Trigger Function API - create_dns_address*/
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

/*Trigger Function API - delete_dns_address*/
CREATE OR REPLACE FUNCTION "api"."delete_dns_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'begin api.delete_dns_address');

		input_address := api.sanitize_general(input_address);
		
		SELECT api.create_log_entry('API', 'INFO', 'deleting address record');
		DELETE FROM "dns"."a" WHERE "address" = input_address;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_dns_address"() IS 'delete an A or AAAA record';

/*Trigger Function API - validate_domain (DOCUMENT)*/
CREATE OR REPLACE FUNCTION "api"."validate_domain"(hostname text, domain text) RETURNS BOOLEAN AS $$
	use strict;
	use warnings;
	use Data::Validate::Domain qw(is_domain);

	# Usage: SELECT api.validate_domain([hostname OR NULL],[domain OR NULL]);

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

COMMENT ON FUNCTION "api"."validate_domain"() IS 'Validate hostname, domain, FQDN based on known rules. Requires Perl module';

/*Trigger Function API - renew_system (DOCUMENT)*/
CREATE OR REPLACE FUNCTION "api"."renew_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.renew_system');
		input_system_name := api.sanitize_general(input_system_name);
		
		SELECT api.create_log_entry('API','INFO','renewing system');
		UPDATE "systems"."systems" SET "renew_date" = date(current_date + interval '1 year');
	END;
$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION "api"."renew_system"() IS 'Renew a registered system for the next year';

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

/* API - add_firewall_metahost_member */
CREATE OR REPLACE FUNCTION "api"."add_firewall_metahost_member"(input_address inet, input_metahost text) RETURNS VOID AS $$
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