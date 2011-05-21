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

/*Trigger Function API - remove_subnet*/
CREATE OR REPLACE FUNCTION "api"."remove_subnet"(input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount	INTEGER;
		WasAuto		BOOLEAN;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.remove_subnet');
		input_subnet := api.sanitize_general(input_subnet);

		SELECT api.create_log_entry('API', 'INFO', 'Deleting subnet');
		DELETE FROM "ip"."subnets" WHERE "subnet" = input_subnet;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_subnet"() IS 'Delete/deactivate an existing subnet';

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

/*Trigger Function API - remove_ip_range*/
CREATE OR REPLACE FUNCTION "api"."remove_ip_range"(input_first_ip inet, input_last_ip inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.remove_ip_range');
		input_first_ip := api.sanitize_general(input_first_ip);
		input_last_ip := api.sanitize_general(input_last_ip);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting range');
		DELETE FROM "ip"."ranges" WHERE "first_ip" = input_first_ip AND "last_ip" = input_last_ip;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_ip_range"() IS 'Delete an existing IP range';

/* API - get_address_from_range */
CREATE OR REPLACE FUNCTION "api"."get_address_from_range"(input_range_name text) RETURNS INET AS $$
	DECLARE
		LowerBound	INET;
		UpperBound	INET;
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
COMMENT ON FUNCTION "api"."get_address_from_range"() IS 'get the first available address in a range';

/* API - get_subnet_addresses */
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
				# can cause confusion and possibly device problems. We'll just avoid them alltogether.
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
COMMENT ON FUNCTION "api"."get_subnet_addresses"() IS 'Given a subnet, return an array of all acceptable addresses within that subnet.';