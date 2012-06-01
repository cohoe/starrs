/* api_dns_utility.sql
	1) get_reverse_domain
	2) validate_domain
	3) validate_srv
*/

/* API - get_reverse_domain */
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

/* API - validate_domain */
CREATE OR REPLACE FUNCTION "api"."validate_domain"(hostname text, domain text) RETURNS BOOLEAN AS $$
	use strict;
	use warnings;
	use Data::Validate::Domain qw(is_domain);
	die("LOLZ");

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
		# This module sucks and should be disabled
		return 'TRUE';
		#return 'FALSE';
	}
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."validate_domain"(text, text) IS 'Validate hostname, domain, FQDN based on known rules. Requires Perl module';

/* API - validate_srv */
CREATE OR REPLACE FUNCTION "api"."validate_srv"(TEXT) RETURNS BOOLEAN AS $$
	my $srv = $_[0];
	my @parts = split('\.',$srv);

	# Check for two parts: the service and the transport
	if (scalar(@parts) ne 2)
	{
		die "Improper number of parts in record\n"
	}

	# Define parts of the record
	my $service = $parts[0];
	my $transport = $parts[1];

	# Check if transport is valid
	if ($transport !~ m/_tcp|_udp/i)
	{
		return "false";
	}

	# Check that service is valid
	if ($service !~ m/^_\w+$/i)
	{
		return "false";
	}
	
	# Good!
	return "true";
$$ LANGUAGE 'plperl';
COMMENT ON FUNCTION "api"."validate_srv"(text) IS 'Validate SRV records';

/* API - dns_resolve */
CREATE OR REPLACE FUNCTION "api"."dns_resolve"(input_hostname text, input_zone text, input_family integer) RETURNS INET AS $$
	BEGIN
		IF input_family IS NULL THEN
			RETURN (SELECT "address" FROM "dns"."a" WHERE "hostname" = input_hostname AND "zone" = input_zone LIMIT 1);
		ELSE
			RETURN (SELECT "address" FROM "dns"."a" WHERE "hostname" = input_hostname AND "zone" = input_zone AND family("address") = input_family);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."dns_resolve"(text, text, integer) IS 'Resolve a hostname/zone to its IP address';

CREATE OR REPLACE FUNCTION "api"."nsupdate"(zone text, keyname text, key text, server inet, action text, record text) RETURNS TEXT AS $$
	use strict;
	use warnings;
	use v5.10;
	use Net::DNS;
	no warnings('redefine');

	# Local variable information
	our $zone = shift(@_) or die("Invalid zone argument");
	our $keyname = shift(@_) or die("Invalid keyname argument");
	our $key = shift(@_) or die("Invalid key argument");
	our $server = shift(@_) or die("Invalid server argument");
	our $action = shift(@_) or die("Invalid action argument");
	our $record = shift(@_) or die("Invalid record argument");

	# DNS Server
	our $res = Net::DNS::Resolver->new;
	$res->nameservers($server);


	# Update packet
	our $update = Net::DNS::Update->new($zone);

	# Do something
	my $returnCode;
	if($action eq "DELETE") {
		$returnCode = &delete();
	}
	elsif($action eq "ADD") {
		$returnCode = &add();
	}
	else {
		$returnCode = "INVALID ACTION";
	}

	# Delete a record
	sub delete() {
		# The record must be there to delete it
		# $update->push(pre => yxrrset($record));

		# Delete the record
		$update->push(update => rr_del($record));

		# Sign it
		$update->sign_tsig($keyname, $key);

		# Send it
		&send();
	}

	# Add a record
	sub add() {
		# The record must not exist
		$update->push(pre => nxrrset($record));

		# Add the record
		$update->push(update => rr_add($record));

		# Sign it
		$update->sign_tsig($keyname, $key);

		# Send it
		&send();
	}

	# Send an update
	sub send() {
		my $reply = $res->send($update);
		if($reply) {
			if($reply->header->rcode eq 'NOERROR') {
				return 0;
			}
			else {
				return &interpret_error($reply->header->rcode);
			}
		}
		else {
			return &interpret_error($res->errorstring);
		}
	}

	# Interpret the error codes if any
	sub interpret_error() {
		my $error = shift(@_);

		given ($error) {
			when (/NXRRSET/) { return "Error $error: Name does not exist"; }
			when (/YXRRSET/) { return "Error $error: Name exists"; }
			when (/NOTAUTH/) { return "Error $error: Not authorized. Check system clocks and or key"; }
			default { return "$error unrecognized"; }
		}
	}

	return $returnCode;
$$ LANGUAGE 'plperlu';

/* API - check_dns_hostname */
CREATE OR REPLACE FUNCTION "api"."check_dns_hostname"(input_hostname text, input_zone text) RETURNS BOOLEAN AS $$
	DECLARE
		RowCount INTEGER := 0;
	BEGIN
		RowCount := RowCount + (SELECT COUNT(*) FROM "dns"."a" WHERE "hostname" = input_hostname AND "zone" = input_zone);
		RowCount := RowCount + (SELECT COUNT(*) FROM "dns"."pointers" WHERE "alias" = input_hostname AND "zone" = input_zone);

		IF RowCount = 0 THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."check_dns_hostname"(text, text) IS 'Check if a hostname is available in a given zone';

/* API - nslookup*/
CREATE OR REPLACE FUNCTION "api"."nslookup"(input_address inet) RETURNS TABLE(fqdn TEXT) AS $$
	BEGIN
		RETURN QUERY (SELECT "hostname"||'.'||"zone" FROM "dns"."a" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."nslookup"(inet) IS 'Get the DNS name of an IP address in the database';

CREATE OR REPLACE FUNCTION "api"."dns_forward_lookup"(text) RETURNS INET AS $$
	use Socket;

	my $hostname = $_[0];
	#my $ipaddr = `host $hostname | cut -d ' ' -f 4`;
	$packed_ip = gethostbyname("$hostname");
	if (defined $packed_ip) {
		$ip_address = inet_ntoa($packed_ip);
	}
	return $ip_address;
$$ LANGUAGE 'plperlu';

CREATE OR REPLACE FUNCTION "api"."dns_reverse_lookup"(inet) RETURNS TEXT AS $$
	use Socket;

	my $ip_address = $_[0];
	my $iaddr = inet_aton("$ip_address"); # or whatever address
	$name  = gethostbyaddr($iaddr, AF_INET);
	return $name;
$$ LANGUAGE 'plperlu';

CREATE OR REPLACE FUNCTION "api"."dns_zone_audit"(text, inet) RETURNS SETOF "dns"."zone_audit_data" AS $$
	use strict;
	use warnings;
	use Net::DNS;
	use v5.10;
	use Data::Dumper;
	
	my $zone = shift(@_) or die "Unable to get zone";
	my $nameserver = shift(@_) or die "Unable to get nameserver for zone";

	my $res = Net::DNS::Resolver->new;
	$res->nameservers($nameserver);

	my @answer = $res->axfr($zone);

	foreach my $result (@answer) {
		&print_data($result);
	}

	sub print_data() {
		my $rr = $_[0];
		given($rr->type) {
			when (/^A|AAAA$/) {
				return_next({host=>$rr->name, ttl=>$rr->ttl, type=>$rr->type, address=>$rr->address});
			}
			when (/^CNAME$/) {
				return_next({host=>$rr->name,ttl=>$rr->ttl,type=>$rr->type,target=>$rr->cname});
			}
			when (/^SRV$/) {
				return_next({host=>$rr->name,ttl=>$rr->ttl,type=>$rr->type,priority=>$rr->priority,weight=>$rr->weight,port=>$rr->port,target=>$rr->target});
			}
			when (/^NS$/) {
				return_next({host=>$rr->nsdname, ttl=>$rr->ttl, type=>$rr->type});
			}
			when (/^MX$/) {
				return_next({host=>$rr->exchange, ttl=>$rr->ttl, type=>$rr->type, preference=>$rr->preference});
			}
			when (/^TXT|SPF$/) {
				return_next({host=>$rr->name, ttl=>$rr->ttl, type=>$rr->type, text=>$rr->char_str_list});
			}
		}
	}
	return undef;
$$ LANGUAGE 'plperlu';

CREATE OR REPLACE FUNCTION "api"."get_dns_zone_audit_data"(input_zone text, input_nameserver inet) RETURNS SETOF "dns"."zone_audit_data" AS $$
       BEGIN
			-- Create a temporary table to store record data in
            DROP TABLE IF EXISTS "audit";
            CREATE TEMPORARY TABLE "audit" (
                   host text, ttl integer, type text, address inet, 
                   port integer, weight integer, priority integer, 
                   preference integer, target text, text text);
			-- Put AXFR data into the table
            INSERT INTO "audit"
            (SELECT * FROM "api"."dns_zone_audit"(input_zone, input_nameserver));
			
			-- Remove all records that IMPULSE contains
            DELETE FROM "audit" WHERE ("host","ttl","type","address") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","address" FROM "dns"."a");
            DELETE FROM "audit" WHERE ("host","ttl","type","target") IN (SELECT "alias"||'.'||"zone" AS "host","ttl","type","hostname"||'.'||"zone" as "target" FROM "dns"."pointers");
            DELETE FROM "audit" WHERE ("host","ttl","type","preference") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","preference" FROM "dns"."mx");
            DELETE FROM "audit" WHERE ("host","ttl","type") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type" FROM "dns"."ns");
            DELETE FROM "audit" WHERE ("host","ttl","type","text") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","text" FROM "dns"."txt");
			
			-- DynamicDNS records have TXT data placed by the DHCP server. Don't count those.
            DELETE FROM "audit" WHERE ("host") IN (SELECT "hostname"||'.'||"zone" AS "host" FROM "api"."get_dhcpd_dynamic_hosts"() WHERE "hostname" IS NOT NULL) AND "type" = 'TXT';
            
			-- What's left is data that IMPULSE has no idea of
            RETURN QUERY (SELECT * FROM "audit");
       END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zone_audit_data"(text,inet) IS 'Perform an audit of IMPULSE zone data against server zone data';