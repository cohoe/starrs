/* API - create_subnet
	1) Check privileges
	2) Sanitize input
	3) Create RDNS zone (since for this purpose you are authoritative for that zone)
	4) Create new subnet
*/
CREATE OR REPLACE FUNCTION "api"."create_subnet"(input_subnet cidr, input_name text, input_comment text, input_autogen boolean, input_dhcp boolean) RETURNS VOID AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_subnet');

		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		input_comment := api.sanitize_general(input_comment);

		-- Create new subnet
		PERFORM api.create_log_entry('API', 'INFO', 'creating new subnet');
		INSERT INTO "ip"."subnets" 
			("subnet","name","comment","autogen","owner","dhcp_enable") VALUES
			(input_subnet,input_name,input_comment,input_autogen,api.get_current_user(),input_dhcp);

		-- Create RDNS zone
		PERFORM api.create_log_entry('API','INFO','creating reverse zone for subnet');
		PERFORM api.create_dns_zone(api.get_reverse_domain(input_subnet),api.get_default_dns_key(),FALSE,'Reverse zone for subnet '||text(input_subnet));

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.create_subnet');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_subnet"(cidr, text, text, boolean, boolean) IS 'Create/activate a new subnet';

/* API - remove_subnet
	1) Check privileges
	2) Sanitize input
	3) Delete RDNS zone
	4) Delete subnet record
*/
CREATE OR REPLACE FUNCTION "api"."remove_subnet"(input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount INTEGER;
		WasAuto BOOLEAN;
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_subnet');

		-- Sanitize input
		input_subnet := api.sanitize_general(input_subnet);

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
	2) Sanitize input
	3) Create new range (triggers checking to make sure the range is valid
*/
CREATE OR REPLACE FUNCTION "api"."create_ip_range"(input_name text, input_first_ip inet, input_last_ip inet, input_subnet cidr, input_use varchar(4), input_comment text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.create_ip_range');

		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		input_use := api.sanitize_general(input_use);
		input_comment := api.sanitize_general(input_comment);
		
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
	2) Sanitize input
	3) Delete range
*/
CREATE OR REPLACE FUNCTION "api"."remove_ip_range"(input_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_ip_range');
	
		-- Sanitize input
		input_name := api.sanitize_general(input_name);
		
		-- Delete range		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting range');
		DELETE FROM "ip"."ranges" WHERE "name" = input_name;

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_ip_range');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_ip_range"(text) IS 'Delete an existing IP range';

/* API - get_address_from_range
	1) Sanitize input
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
		-- Sanitize input
		input_range_name := api.sanitize_general(input_range_name);
	
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
