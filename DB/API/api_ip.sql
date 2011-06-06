/* API - create_subnet
	1) Check privileges
	2) Validate input
	3) Create RDNS zone (since for this purpose you are authoritative for that zone)
	4) Create new subnet
*/
CREATE OR REPLACE FUNCTION "api"."create_subnet"(input_subnet cidr, input_name text, input_comment text, input_autogen boolean, input_dhcp boolean, input_zone text, input_owner text) RETURNS VOID AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_subnet');

		-- Validate input
		input_name := api.validate_name(input_name);
		
		-- Fill in owner
		IF input_owner IS NULL THEN
			input_owner := api.get_current_user();
		END IF;
		
		-- Fill in zone
		IF input_zone IS NULL THEN
			input_zone := api.get_site_configuration('DNS_DEFAULT_ZONE');
		END IF;
		
		-- Create new subnet
		PERFORM api.create_log_entry('API', 'INFO', 'creating new subnet');
		INSERT INTO "ip"."subnets" 
			("subnet","name","comment","autogen","owner","dhcp_enable","zone") VALUES
			(input_subnet,input_name,input_comment,input_autogen,input_owner,input_dhcp,input_zone);

		-- Create RDNS zone
		PERFORM api.create_log_entry('API','INFO','creating reverse zone for subnet');
		PERFORM api.create_dns_zone(api.get_reverse_domain(input_subnet),api.get_site_configuration('DNS_DEFAULT_KEY'),FALSE,'Reverse zone for subnet '||text(input_subnet));

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_subnet');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_subnet"(cidr, text, text, boolean, boolean, text, text) IS 'Create/activate a new subnet';

/* API - remove_subnet
	1) Check privileges
	2) Delete RDNS zone
	3) Delete subnet record
*/
CREATE OR REPLACE FUNCTION "api"."remove_subnet"(input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount INTEGER;
		WasAuto BOOLEAN;
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_subnet');

		-- Delete RDNS zone
		PERFORM api.create_log_entry('API', 'INFO', 'removing rdns zone for subnet');
		PERFORM api.remove_dns_zone(api.get_reverse_domain(input_subnet));

		-- Delete subnet
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting subnet');
		DELETE FROM "ip"."subnets" WHERE "subnet" = input_subnet;

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_subnet');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_subnet"(cidr) IS 'Delete/deactivate an existing subnet';

/* API - create_ip_range
	1) Check privileges
	2) Validate input
	3) Create new range (triggers checking to make sure the range is valid
*/
CREATE OR REPLACE FUNCTION "api"."create_ip_range"(input_name text, input_first_ip inet, input_last_ip inet, input_subnet cidr, input_use varchar(4), input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_ip_range');

		-- Validate input
		input_name := api.validate_name(input_name);
		
		-- Create new IP range		
		PERFORM api.create_log_entry('API', 'INFO', 'creating new range');
		INSERT INTO "ip"."ranges" ("name", "first_ip", "last_ip", "subnet", "use", "comment") VALUES 
		(input_name,input_first_ip,input_last_ip,input_subnet,input_use,input_comment);

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_ip_range');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_ip_range"(text, inet, inet, cidr, varchar(4), text) IS 'Create a new range of IP addresses';

/* API - remove_ip_range
	1) Check privileges
	2) Delete range
*/
CREATE OR REPLACE FUNCTION "api"."remove_ip_range"(input_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_ip_range');
		
		-- Delete range		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting range');
		DELETE FROM "ip"."ranges" WHERE "name" = input_name;

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_ip_range');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_ip_range"(text) IS 'Delete an existing IP range';

/* API - get_address_from_range
	1) Dynamic addressing for ipv4
	2) Get range bounds
	3) Get address from range
	4) Check if range was full
*/
CREATE OR REPLACE FUNCTION "api"."get_address_from_range"(input_range_name text) RETURNS INET AS $$
	DECLARE
		LowerBound INET;
		UpperBound INET;
		AddressToUse INET;
	BEGIN
		-- Dynamic Addressing for ipv4
		IF (SELECT "use" FROM "ip"."ranges" WHERE "name" = input_range_name) = 'ROAM' 
		AND (SELECT family("subnet") FROM "ip"."ranges" WHERE "name" = input_range_name) = 4 THEN
			SELECT "address" INTO AddressToUse FROM "ip"."addresses" 
			WHERE "address" << cidr(api.get_site_configuration('DYNAMIC_SUBNET'))
			AND "address" NOT IN (SELECT "address" FROM "systems"."interface_addresses") ORDER BY "address" ASC LIMIT 1;
			RETURN AddressToUse;
		END IF;
	
		-- Get range bounds
		SELECT "first_ip","last_ip" INTO LowerBound,UpperBound
		FROM "ip"."ranges"
		WHERE "ip"."ranges"."name" = input_range_name;
		
		-- Get address from range
		SELECT "address" FROM "ip"."addresses" INTO AddressToUse
		WHERE "address" <= UpperBound AND "address" >= LowerBound
		AND "address" NOT IN (SELECT "address" FROM "systems"."interface_addresses") ORDER BY "address" ASC LIMIT 1;
		
		-- Check if range was full (AddressToUse will be NULL)
		IF AddressToUse IS NULL THEN
			PERFORM api.create_log_entry('IP', 'ERROR', 'range full');
			RAISE EXCEPTION 'All addresses in range % are in use',input_range_name;
		END IF;
		
		RETURN AddressToUse;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_address_from_range"(text) IS 'get the first available address in a range';

/* API - get_subnet_addresses
	1) Define basic network
	2) Create range
	3) Loop through range
*/
CREATE OR REPLACE FUNCTION "api"."get_subnet_addresses"(CIDR) RETURNS SETOF INET AS $$
	use strict;
	use warnings;
	use Net::IP;
	use Net::IP qw(:PROC);
	use feature 'switch';

	# Define some basic information about the network.
	my $subnet = new Net::IP ($_[0]) or die (Net::IP::Error());
	my $broadcast_address = $subnet->last_ip();
	my $network_address = $subnet->ip();
	my $version = ip_get_version($network_address);

	# Create an object of the range between the network address and the broadcast address.
	my $range = new Net::IP ("$network_address - $broadcast_address");
	my @addresses;

	# Given/When is the new Switch. Perform different operations for IPv4 and IPv6. 
	given ($version) {
		when (/4/) { 
			while (++$range) {
				# While they technically work, .255 and .0 addresses in multi-range wide networks
				# can cause confusion and possibly device problems. Well just avoid them alltogether.
				if($range->ip() !~ m/\.0$|\.255$/) {
					push(@addresses, $range->ip());
				}
			}
		}
		when (/6/) { 
			while (++$range) {
				push(@addresses, ip_compress_address($range->ip(), 6));
			}
		}
		default { die "Unable to generate\n"; }
	}

	# Spit them all back out
	return \@addresses;
$$ LANGUAGE plperlu;
COMMENT ON FUNCTION "api"."get_subnet_addresses"(cidr) IS 'Given a subnet, return an array of all acceptable addresses within that subnet.';

/* API - get_range_addresses
	1) Define range
	2) Loop through range
*/
CREATE OR REPLACE FUNCTION "api"."get_range_addresses"(INET, INET) RETURNS SETOF INET AS $$
	use strict;
	use warnings;
	use Net::IP;
	use Net::IP qw(:PROC);
	use feature 'switch';

	# Define range
	my $range = new Net::IP ("$_[0] - $_[1]");
	my @addresses;

	# Loop through range
	while ($range) 
	{
		push(@addresses, ip_compress_address($range->ip(), 6));
		$range++;
	}

	return \@addresses;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_range_addresses"(inet,inet) IS 'return a list of all addresses within a given range';

/* API - create_address_range
	1) Check if subnet exists
	2) Check if addresses are within subnet
	3) Check if the subnet was autogenerated
	4) Get the owner of the subnet
	5) Create addresses
*/
CREATE OR REPLACE FUNCTION "api"."create_address_range"(input_first_ip inet, input_last_ip inet, input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount INTEGER;
		Owner TEXT;
		RangeAddresses RECORD;
	BEGIN
		-- Check if subnet exists
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."subnets"
		WHERE "ip"."subnets"."subnet" = input_subnet;
		IF (RowCount < 1) THEN
			RAISE EXCEPTION 'Subnet (%) does not exist.',input_subnet;
		END IF;
		
		-- Check if addresses are within subnet
		IF NOT input_first_ip << input_subnet THEN
			RAISE EXCEPTION 'First address (%) not within subnet (%)',input_first_ip,input_subnet;
		END IF;

		IF NOT input_last_ip << input_subnet THEN
			RAISE EXCEPTION 'Last address (%) not within subnet (%)',input_last_ip,input_subnet;
		END IF;

		-- Check if autogen'd
		IF (SELECT "autogen" FROM "ip"."subnets" WHERE "ip"."subnets"."subnet" = input_subnet LIMIT 1) IS TRUE THEN
			RAISE EXCEPTION 'Subnet (%) addresses were autogenerated. Cannot create new addresses.',input_subnet;
		END IF;

		-- Get owner
		SELECT "ip"."subnets"."owner" INTO Owner 
		FROM "ip"."subnets"
		WHERE "ip"."subnets"."subnet" = input_subnet;

		-- Create addresses
		FOR RangeAddresses IN SELECT api.get_range_addresses(input_first_ip,input_last_ip) LOOP
			--RAISE INFO '% %',RangeAddresses.get_range_addresses,Owner;
			INSERT INTO "ip"."addresses" ("address","owner") VALUES (RangeAddresses.get_range_addresses,Owner);
			INSERT INTO "firewall"."defaults" ("address", "deny") VALUES (RangeAddresses.get_range_addresses, DEFAULT);
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_address_range"(inet, inet, cidr) IS 'Create a range of addresses from a non-autogened subnet (intended for DHCPv6)';