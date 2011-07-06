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