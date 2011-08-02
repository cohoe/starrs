/* api_ip_get.sql
	1) get_address_from_range
	2) get_subnet_addresses
	3) get_range_addresses
*/

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

		-- Done
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

	# Done
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

	# Done
	return \@addresses;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_range_addresses"(inet,inet) IS 'return a list of all addresses within a given range';

/* API - get_subnet_utilization */
CREATE OR REPLACE FUNCTION "api"."get_subnet_utilization"(input_subnet cidr) RETURNS NUMERIC AS $$
	BEGIN
	RETURN (TRUNC(((SELECT COUNT("address") FROM "systems"."interface_addresses" WHERE "address" << input_subnet)::numeric /
	(SELECT COUNT("address") FROM "ip"."addresses" WHERE "address" << input_subnet)::numeric) * 100,1));
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_subnet_utilization"(cidr) IS 'Get the percent usage of a subnet';

/* API - get_address_range */
CREATE OR REPLACE FUNCTION "api"."get_address_range"(input_address inet) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "name" FROM "ip"."ranges" WHERE "first_ip" <= input_address AND "last_ip" >= input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_address_range"(inet) IS 'Get the name of the range an address is in';

/* API - get_ip_ranges */
CREATE OR REPLACE FUNCTION "api"."get_ip_ranges"() RETURNS SETOF "ip"."range_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","first_ip","last_ip","subnet","use","class","comment","date_created","date_modified","last_modifier" FROM "ip"."ranges");
	END;
$$ LANGUAGE 'plpgsql';

/* API - get_ip_subnets */
CREATE OR REPLACE FUNCTION "api"."get_ip_subnets"() RETURNS SETOF "ip"."subnet_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","subnet","zone","owner","autogen","dhcp_enable","comment","date_created","date_modified","last_modifier"
		FROM "ip"."subnets");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_ip_subnets"() IS 'Get all IP subnet data';

/* API - get_ip_subnet */
CREATE OR REPLACE FUNCTION "api"."get_ip_subnet"(input_subnet cidr) RETURNS SETOF "ip"."subnet_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","subnet","zone","owner","autogen","dhcp_enable","comment","date_created","date_modified","last_modifier"
		FROM "ip"."subnets" WHERE "subnet" = input_subnet);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_ip_subnet"(cidr) IS 'Get all IP subnet data for a specific subnet';

/* API - get_firewall_default_data */
CREATE OR REPLACE FUNCTION "api"."get_firewall_default_data"(input_subnet cidr) RETURNS SETOF "firewall"."default_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "address","deny" FROM "firewall"."defaults" WHERE "address" IN 
		(SELECT"address" FROM "systems"."interface_addresses") AND "address" << input_subnet);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_default_data"(cidr) IS 'Get firewall default action data';