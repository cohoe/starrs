/* API - generate_dhcpd_config*/
CREATE OR REPLACE FUNCTION "api"."generate_dhcpd_config"() RETURNS VOID AS $$
	# Script written by Anthony Gargiulo
	use strict;
	use warnings;
	no warnings 'redefine';

	# First things first. defining the subroutines that make up this script.

	# Global Options
	sub global_opts
	{
		my ($row, $option, $value, $output);
		my $global_options = spi_query("SELECT * FROM api.get_dhcpd_global_options()");
		while (defined($row = spi_fetchrow($global_options)))
		{
			$option = $row->{option};
			$value = $row->{value};
			$output .= "$option    $value;\n"
		}
		return $output;
	} # end global options

	# DNS keys added here
	sub dns_keys
	{
		my $keys = spi_query("SELECT * FROM api.get_dhcpd_dns_keys()");
		my ($keyname, $key, $enctype, $row, $output);
		while (defined ($row = spi_fetchrow($keys)))
		{
			$keyname = $row->{keyname};
			$key = $row->{key};
			$enctype = $row->{enctype};
			$output .= "key $keyname {\n  algorithm ${enctype};\n  secret \"$key\";\n}\n";
		}
		return $output;
	}# end DNS keys
	
	# Zones are added here.
	sub forward_zones
	{
		my $zones = spi_query("SELECT * FROM api.get_dhcpd_forward_zones()");
		my ($zone, $keyname, $primary_ns, $row, $output);
		$output = "";
		while (defined ($row = spi_fetchrow($zones)))
		{
			$zone = $row->{zone};
			$keyname = $row->{keyname};
			$primary_ns = $row->{primary_ns};
			$output .= "zone $zone {\n  primary ${primary_ns};\n  key ${keyname};\n}\n";
		}
		return $output;
	}# end forward zones

	# Zones are added here.
	sub reverse_zones
	{
		my $zones = spi_query("SELECT * FROM api.get_dhcpd_reverse_zones()");
		my ($zone, $keyname, $primary_ns, $row, $output);
		$output = "";
		while (defined ($row = spi_fetchrow($zones)))
		{
			$zone = $row->{zone};
			$keyname = $row->{keyname};
			$primary_ns = $row->{primary_ns};
			$output .= "zone $zone {\n  primary ${primary_ns};\n  key ${keyname};\n}\n";
		}
		return $output;
	}# end reverse zones

	# DHCP Classes
	sub dhcp_classes
	{
		my $classes = spi_query("SELECT class,comment FROM api.get_dhcpd_classes()");
		my ($class, $comment, $row, $output);
		while (defined($row = spi_fetchrow($classes)))
		{
			$class = $row->{class};
			$comment = $row->{comment};
			$output .= "class \"$class\" {\n";
			$output .= "  # ${comment}\n" if(defined($comment));
			$output .= &dhcp_class_options($class);
			$output .= "}\n\n";
		}
		return $output;
	}# end &dhcp_classes

	# DHCP Class options
	sub dhcp_class_options
	{
		my $class = $_[0];
		my $options = spi_query("SELECT * FROM api.get_dhcpd_class_options('$class')");
		my ($option, $value, $row, $output);
		while (defined($row = spi_fetchrow($options)))
		{
			$option = $row->{option};
			$value = $row->{value};
			$output .= "    " . $option . ' ' . $value . ";\n";
		}
		return $output;
	}# end &dhcp_class_options

	## Shared networks
	#sub shared_networks
	#{
	#	my $network = spi_exec_query("SELECT api.get_site_configuration('NETWORK_NAME')");
	#	my $output = "shared-network " . $network->{rows}[0]->{get_site_configuration}. " {\n";
	#	$output .= &subnets;
	#	$output .= "}\n";
	#	return $output;
	#}
	
	# Subnets (for shared networks)
	sub subnets
	{
		my $subnets = spi_query("SELECT get_dhcpd_subnets, netmask(get_dhcpd_subnets) FROM api.get_dhcpd_subnets()");
		
		# $subnet = ip + netmask in slash notation; i.e. 10.21.49.0/24
		# $net = only the network address; i.e. 10.21.49.0
		# $mask = netmask in dotted decimal notation; i.e. 255.255.255.0
		my ($subnet, $net, $mask, $row, $output);
		
		while (defined($row = spi_fetchrow($subnets)))
		{
			$subnet = $row->{get_dhcpd_subnets};
			$net = substr($subnet, 0, index($subnet, "/"));
			$mask = $row->{netmask};
			$output .= "subnet $net netmask $mask {\n  ";
			$output .= "authoritative;";
			my $subnet_option = &subnet_options($subnet);
			if(defined($subnet_option))
			{
			   $output .= $subnet_option;
			}
			my $subnet_range = &subnet_ranges($subnet);
			if(defined($subnet_range))
			{
			   $output .= $subnet_range;
			}
			$output .= "\n}\n";
		}
		return $output;
	}
	
	# Subnet options
	sub subnet_options
	{
		my $subnet = $_[0];
		my $options = spi_query("SELECT option,value from api.get_dhcpd_subnet_options('$subnet')");
		my ($option, $value, $row, $output);
		while (defined($row = spi_fetchrow($options)))
		{
			$option = $row->{option};
			$value = $row->{value};
			$output .= "\n    $option $value;";
		}
		return $output;
	}
	
	# Subnet ranges
	sub subnet_ranges
	{
		my $subnet = $_[0];
		my $pool = spi_query("SELECT name,first_ip,last_ip,class from api.get_dhcpd_subnet_ranges('$subnet')");
		my ($range_name, $first_ip, $last_ip, $class, $row, $output);
		$output="";
		
		while (defined($row = spi_fetchrow($pool)))
		{
			$range_name = $row->{name};
			$first_ip = $row->{first_ip};
			$last_ip = $row->{last_ip};
			$class = $row->{class};
			$output .= "\n    pool {\n      range $first_ip $last_ip;";
			{
				my $range_options = spi_query("SELECT * from api.get_dhcpd_range_options('$range_name')");
				my ($option, $value, $row);
				while (defined($row = spi_fetchrow($range_options)))
				{
					$option = $row->{option};
					$value = $row->{value};
					$output .= "\n      $option $value;";
				}
			}
			if (defined($class))
			{
				$output .= "\n      allow members of \"$class\";";
			}
			else
			{
				$output .= "\n      allow unknown clients;";
			}
			$output .= "\n    }";
		}
		return $output;
	}

	# hosts
	sub hosts
	{
		my $static_hosts = spi_query("SELECT * FROM api.get_dhcpd_static_hosts() order by owner,hostname");
		my $dynamic_hosts = spi_query("SELECT * FROM api.get_dhcpd_dynamic_hosts() order by owner,hostname");
		my ($hostname, $zone, $mac, $address, $owner, $class, $row, $output);
		$output .= "# Static hosts\n";
		while (defined($row = spi_fetchrow($static_hosts)))
		{
			$hostname = $row->{hostname};
			$zone = $row->{zone};
			$mac = $row->{mac};
			$address = $row->{address};
			$owner = $row->{owner};
			$class = $row->{class};
			
			$output .= &host_config($hostname, $zone, $mac, $address, $owner, $class);
		}
		$output .= "# Dynamic hosts\n";
		while (defined($row = spi_fetchrow($dynamic_hosts)))
		{
			$hostname = $row->{hostname};
			$zone = $row->{zone};
			$mac = $row->{mac};
			$owner = $row->{owner};
			$class = $row->{class};
			
			$output .= &host_config($hostname, $zone, $mac, undef, $owner, $class);
		}
		return $output;
	}

	# hosts config generation
	sub host_config
	{
		my ($hostname, $zone, $mac, $address, $owner, $class) = @_;
		
		my $hostmac = $mac;
		$hostmac =~ s/://g;
		
		my $output .= "# $owner\n";
		if (defined($hostname) && defined($zone))
		{
			$output .= "host $hostname.$zone {\n";
		}else 
		{
			$output .= "host $hostmac {\n";
		}
		$output .= "  option dhcp-client-identifier 1:$mac;\n";
		$output .= "  hardware ethernet $mac;\n";
		$output .= "  fixed-address $address;\n" if (defined($address));
		$output .= "  option host-name \"$hostname\";\n" if (defined($hostname));
		$output .= "  ddns-hostname \"$hostname\";\n" if (defined($hostname));
		$output .= "  ddns-domainname \"$zone\";\n" if (defined($zone));
		$output .= "  option domain-name \"$zone\";\n" if (defined($zone));
		$output .= "}\n";
		$output .= "subclass \"$class\" 1:$mac;\n";
		$output .= "subclass \"$class\" $mac;\n\n";
		return $output;
	}


	# lets start with the DHCPd.conf header from the DB
	my $header = spi_exec_query("SELECT api.get_site_configuration('DHCPD_HEADER')");
	my $output = $header->{rows}[0]->{get_site_configuration}. "\n\n"; 

	# add the date to the file
	my $date = spi_exec_query("SELECT localtimestamp(0)")->{rows}[0]->{timestamp};
	$output .= "\# Generated at $date\n\n";

	# now for the rest of the config file
	$output .= &global_opts() . "\n";
	$output .= &dns_keys() . "\n";
	$output .= &forward_zones() . "\n";
	$output .= &reverse_zones() . "\n";
	$output .= &dhcp_classes() . "\n";
	$output .= &subnets() . "\n";
	$output .= &hosts() . "\n";

	$output .= "\# End dhcpd configuration file";

	# finally, store the config in the db, so we can get it back later.
	spi_exec_query("INSERT INTO management.output (value,file,timestamp) VALUES (\$\$".$output."\$\$,'dhcpd.conf',now())");

	#log our success with the api logging tool.
	spi_exec_query("SELECT api.create_log_entry('API','INFO','Successfully generated dhcpd.conf')");
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."generate_dhcpd_config"() IS 'Generate the config file for the dhcpd server, and store it in the db';

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
	# die("LOLZ");

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
		#return 'TRUE';
		# Seems to be working normally... Keep an eye on your domain validation
		return 'FALSE';
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
	if ($service !~ m/^_[\w-]+$/i)
	{
		return "false";
	}
	
	# Good!
	return "true";
$$ LANGUAGE 'plperl';
COMMENT ON FUNCTION "api"."validate_srv"(text) IS 'Validate SRV records';

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
		# MX and TXT records will already exist. Otherwise the record you are 
		# creating should not already be in the zone. That would be silly.
		#
		# Frak it, you better be sure IMPULSE owns your DNS zone. Otherwise old records
		# WILL be overwriten.
		# 
		# if($record !~ m/\s(MX|TXT|NS)\s/) {
		# 	$update->push(pre => nxrrset($record));
		# }

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

CREATE OR REPLACE FUNCTION "api"."query_address_reverse"(inet) RETURNS TEXT AS $$
	use strict;
	use warnings;
	use Net::DNS;
	use Net::IP;
	use Net::IP qw(:PROC);
	use v5.10;

	# Define some variables
	my $address = shift(@_) or die "Unable to get address";
	
	# Generate the reverse string (d.c.b.a.in-addr.arpa.)
	my $reverse = new Net::IP ($address)->reverse_ip() or die (Net::IP::Error());

	# Create the resolver
	my $res = Net::DNS::Resolver->new;

	# Run the query
	my $rr = $res->query($reverse,'PTR');

	# Check for a response
	if(!defined($rr)) {
		return;
	}

	# Parse the response
	my @answer = $rr->answer;
	foreach my $response(@answer) {
		return $response->ptrdname;
	}
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."query_address_reverse"(inet) IS 'Print the forward host of a reverse lookup';

CREATE OR REPLACE FUNCTION "api"."query_axfr"(text, text) RETURNS SETOF "dns"."zone_audit_data" AS $$
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
			when (/^TXT$/) {
				return_next({host=>$rr->name, ttl=>$rr->ttl, type=>$rr->type, text=>$rr->char_str_list});
			}
			when (/^SOA$/) {
				return_next({host=>$rr->name, target=>$rr->mname, ttl=>$rr->ttl, contact=>$rr->rname, serial=>$rr->serial, refresh=>$rr->refresh, retry=>$rr->retry, expire=>$rr->expire, minimum=>$rr->minimum, type=>$rr->type});
			}
			when (/^PTR$/) {
				return_next({host=>$rr->name, target=>$rr->ptrdname, ttl=>$rr->ttl, type=>$rr->type});
			}
		}
	}
	return undef;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."query_axfr"(text, text) IS 'Query a nameserver for the DNS zone transfer to use for auditing';

CREATE OR REPLACE FUNCTION "api"."query_zone_serial"(text) RETURNS TEXT AS $$
	use strict;
	use warnings;
	use Net::DNS;
	
	# Get the zone
	my $zone = shift(@_) or die "Unable to get DNS zone to query";
	
	# Establish the resolver and make the query
	my $res = Net::DNS::Resolver->new;
	my $rr = $res->query($zone,'soa');

	# Check if it actually returned
	if(!defined($rr)) {
		die "Unable to find record for zone $zone";
	}
	
	# Spit out the serial
	my @answer = $rr->answer;
	return $answer[0]->serial;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."query_zone_serial"(text) IS 'Query this hosts resolver for the serial number of the zone.';

CREATE OR REPLACE FUNCTION "api"."resolve"(text) RETURNS INET AS $$
	use strict;
	use warnings;
	use Socket qw(inet_ntoa);
	
	my $hostname = shift() or die "Unable to get name argument";
	my ($name,$aliases,$addrtype,$length,@addrs) = gethostbyname($hostname);
	return inet_ntoa($addrs[0]);
$$ LANGUAGE 'plperlu';

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
$$ LANGUAGE 'plperlu';
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

/* API - get_ldap_user_level
	1) Load configuration
	2) Bind to the LDAP server
	3) Figure out permission level
	4) Unbind from LDAP server
*/
CREATE OR REPLACE FUNCTION "api"."get_ldap_user_level"(TEXT) RETURNS TEXT AS $$
	use strict;
	use warnings;
	use Net::LDAP;
	
	# Get the current authenticated username
	my $username = $_[0] or die "Need to give a username";
	
	# If this is the installer, we dont need to query the server
	if ($username eq "root")
	{
		return "ADMIN";
	}
	
	# Get LDAP connection information
	my $host = spi_exec_query("SELECT api.get_site_configuration('LDAP_HOST')")->{rows}[0]->{"get_site_configuration"};
	my $binddn = spi_exec_query("SELECT api.get_site_configuration('LDAP_BINDDN')")->{rows}[0]->{"get_site_configuration"};
	my $password = spi_exec_query("SELECT api.get_site_configuration('LDAP_PASSWORD')")->{rows}[0]->{"get_site_configuration"};
	my $admin_filter = spi_exec_query("SELECT api.get_site_configuration('LDAP_ADMIN_FILTER')")->{rows}[0]->{"get_site_configuration"};
	my $admin_basedn = spi_exec_query("SELECT api.get_site_configuration('LDAP_ADMIN_BASEDN')")->{rows}[0]->{"get_site_configuration"};
	my $program_filter = spi_exec_query("SELECT api.get_site_configuration('LDAP_PROGRAM_FILTER')")->{rows}[0]->{"get_site_configuration"};
	my $program_basedn = spi_exec_query("SELECT api.get_site_configuration('LDAP_PROGRAM_BASEDN')")->{rows}[0]->{"get_site_configuration"};
	my $user_filter = spi_exec_query("SELECT api.get_site_configuration('LDAP_USER_FILTER')")->{rows}[0]->{"get_site_configuration"};
	my $user_basedn = spi_exec_query("SELECT api.get_site_configuration('LDAP_USER_BASEDN')")->{rows}[0]->{"get_site_configuration"};

	# The lowest status. Build from here.
	my $status = "NONE";

	# Bind to the LDAP server
	my $srv = Net::LDAP->new ($host) or die "Could not connect to LDAP server ($host)\n";
	my $mesg = $srv->bind($binddn,password=>$password) or die "Could not bind to LDAP server at $host\n";
	
	# Go through the directory and see if this user is a user account
	$mesg = $srv->search(filter=>"($user_filter=$username)",base=>$user_basedn,attrs=>[$user_filter]);
	foreach my $entry ($mesg->entries)
	{
		my @users = $entry->get_value($user_filter);
		foreach my $user (@users)
		{
			$user =~ s/^uid=(.*?)\,(.*?)$/$1/;
			if ($user eq $username)
			{
				$status = "USER";
			}
		}
	}

	# Go through the directory and see if this user is a program account
	$mesg = $srv->search(filter=>"($program_filter=$username)",base=>$program_basedn,attrs=>[$program_filter]);
	foreach my $entry ($mesg->entries)
	{
		my @programs = $entry->get_value($program_filter);
		foreach my $program (@programs)
		{
			if ($program eq $username)
			{
				$status = "PROGRAM";
			}
		}
	}
	
	# Go through the directory and see if this user is an admin
	# Fancy hacks to allow for less hardcoding of attributes
	my $admin_filter_atr = $admin_filter;
	$admin_filter_atr =~ s/^(.*?)[^a-zA-Z0-9]+$/$1/;
	$mesg = $srv->search(filter=>"($admin_filter)",base=>$admin_basedn,attrs=>[$admin_filter_atr]);
	foreach my $entry ($mesg->entries)
	{
		my @admins = $entry->get_value($admin_filter_atr);
		foreach my $admin (@admins)
		{
			$admin =~ s/^uid=(.*?)\,(.*?)$/$1/;
			if ($admin eq $username)
			{
				$status = "ADMIN";
			}
		}
	}

	# Unbind from the LDAP server
	$srv->unbind;

	# Done
	return $status;

#	if($_[0] eq 'root')
#	{
#		return "ADMIN"
#	}
#	else
#	{
#		return "USER";
#	}
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_ldap_user_level"(text) IS 'Get the level of access for the authenticated user';

CREATE OR REPLACE FUNCTION "api"."get_switchview_bridgeportid"(inet, text, integer) RETURNS TABLE("camportinstanceid" TEXT, "bridgeportid" INTEGER) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $dot1dTpFdbPort = ".1.3.6.1.2.1.17.4.3.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my $vlan = shift(@_) or die "Unable to get VLANID";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community\@$vlan",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $bridgePortList = $session->get_table(-baseoid => $dot1dTpFdbPort);

	# Do something for each item of the list
	while ( my ($camPortInstanceID, $bridgePortID) = each(%$bridgePortList)) {
		$camPortInstanceID =~ s/$dot1dTpFdbPort//;
		return_next({camportinstanceid=>$camPortInstanceID, bridgeportid=>$bridgePortID});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_bridgeportid"(inet, text, integer) IS 'Get a mapping of CAM instanceIDs and bridgeIDs';

CREATE OR REPLACE FUNCTION "api"."get_switchview_cam"(inet, text, integer) RETURNS TABLE ("camportinstanceid" TEXT, "mac" MACADDR) AS $$
	#!/usr/bin/perl -w 

	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $dot1dTpFdbAddress = ".1.3.6.1.2.1.17.4.3.1.1";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my $vlan = shift(@_) or die "Unable to get VLANID";

	# Subroutine to format a MAC address to something nice
	sub format_raw_mac {
		my $mac = $_[0];
		# Get rid of the hex identifier
		$mac =~ s/^0x//;

		# Make groups of two characters
		$mac =~ s/(.{2})/$1:/gg;

		# Remove the trailing : left by the previous function
		$mac =~ s/\:$//;

		# Spit it back out
		return $mac;
	}

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community\@$vlan",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $camList = $session->get_table(-baseoid => $dot1dTpFdbAddress);

	# Do something for each item of the list
	while ( my ($camPortInstanceID, $macaddr) = each(%$camList)) {
		$camPortInstanceID =~ s/$dot1dTpFdbAddress//;
		
		# Sometimes there are non-valid MAC addresses in the CAM.
		if($macaddr =~ m/[0-9a-fA-F]{12}/) {
			$macaddr = format_raw_mac($macaddr);
			#print "InstanceID: $camPortInstanceID - MAC: $macaddr\n";
			return_next({camportinstanceid=>$camPortInstanceID,mac=>$macaddr});
		}
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;

$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_cam"(inet, text, integer) IS 'Get the CAM/MAC table from a device on a certain VLAN';

CREATE OR REPLACE FUNCTION "api"."get_switchview_portindex"(inet, text, integer) RETURNS TABLE("bridgeportid" INTEGER, "ifindex" INTEGER) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $dot1dBasePortIfIndex = ".1.3.6.1.2.1.17.1.4.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my $vlan = shift(@_) or die "Unable to get VLAN";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community\@$vlan"
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $portIndexList = $session->get_table(-baseoid => $dot1dBasePortIfIndex);

	# Do something for each item of the list
	while ( my ($bridgePortID, $portIndex) = each(%$portIndexList)) {
		$bridgePortID =~ s/$dot1dBasePortIfIndex\.//;
		return_next({bridgeportid=>$bridgePortID, ifindex=>$portIndex});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;

$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_portindex"(inet, text, integer) IS 'Get a mapping of port indexes to bridge indexes';

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_names"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifname" TEXT, "ifdesc" TEXT) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifName = ".1.3.6.1.2.1.31.1.1.1.1";
	my $ifDesc = ".1.3.6.1.2.1.2.2.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my %ports;

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $portNameList = $session->get_table(-baseoid => $ifName);
	my $portDescList = $session->get_table(-baseoid => $ifDesc);

	# Do something for each item of the list
	while ( my ($portIndex, $portName) = each(%$portNameList)) {
		$portIndex =~ s/$ifName\.//;
		$ports{$portIndex}{'ifName'} = $portName;
	}
	while ( my ($portIndex, $portDesc) = each(%$portDescList)) {
		$portIndex =~ s/$ifDesc\.//;
		$ports{$portIndex}{'ifDesc'} = $portDesc;
	}
	foreach my $key (keys(%ports)) {
		return_next({ifindex=>$key, ifname=>$ports{$key}{'ifName'}, ifdesc=>$ports{$key}{'ifDesc'}});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_names"(inet, text) IS 'Map ifindexes to port names';

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_descriptions"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifalias" TEXT) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifAlias = "1.3.6.1.2.1.31.1.1.1.18";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $portAliases = $session->get_table(-baseoid => $ifAlias);

	# Do something for each item of the list
	while ( my ($portIndex, $portAlias) = each(%$portAliases)) {
		$portIndex =~ s/$ifAlias\.//;
		return_next({ifindex=>$portIndex, ifalias=>$portAlias});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_descriptions"(inet, text) IS 'Map ifindexes to port descriptions (or aliases in Cisco-land)';

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_operstatus"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifoperstatus" BOOLEAN) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifOperStatus = ".1.3.6.1.2.1.2.2.1.8";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $portStates = $session->get_table(-baseoid => $ifOperStatus);

	# Do something for each item of the list
	while ( my ($portIndex, $portState) = each(%$portStates)) {
		$portIndex =~ s/$ifOperStatus\.//;
		if($portState-1 == 0) {
			# Then its up
			$portState = 1;
		}
		else {
			# Then its down
			$portState = 0;
		}
		return_next({ifindex=>$portIndex, ifoperstatus=>$portState});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_operstatus"(inet, text) IS 'Map ifindexes to port operational status';

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_adminstatus"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifadminstatus" BOOLEAN) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifAdminStatus = ".1.3.6.1.2.1.2.2.1.7";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $portStates = $session->get_table(-baseoid => $ifAdminStatus);

	# Do something for each item of the list
	while ( my ($portIndex, $portState) = each(%$portStates)) {
		$portIndex =~ s/$ifAdminStatus\.//;
		if($portState-1 == 0) {
			# Then its up
			$portState = 1;
		}
		else {
			# Then its down
			$portState = 0;
		}
		return_next({ifindex=>$portIndex, ifadminstatus=>$portState});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_adminstatus"(inet, text) IS 'Map ifindexes to port administrative status';

CREATE OR REPLACE FUNCTION "api"."get_switchview_neighbors"(inet, text) RETURNS TABLE("localifIndex" INTEGER, "remoteifdesc" TEXT, "remotehostname" TEXT) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;
	use 5.10.0;

	# Define OIDs
	my $cdpCacheEntry = "1.3.6.1.4.1.9.9.23.1.2.1.1";
	my $cdpCacheIfIndex = "1";
	my $cdpCacheDeviceId = "6";
	my $cdpCacheDevicePort = "7";
	my $cdpCachePlatform = "8";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";

	# Data containers
	my %remoteHosts;
	my %remotePorts;
	my %remotePlatforms;
	my %localPorts;

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community",
	);

	# Check that it did not error
	if (!defined($session)) {
		print $error;
		exit 1;
	}

	# Get a list of all data
	my $neighborList = $session->get_table(-baseoid => $cdpCacheEntry);

	# Do something for each item of the list
	while ( my ($id, $value) = each(%$neighborList)) {
		$id=~ s/$cdpCacheEntry\.//;
		
		if($id =~ m/^($cdpCacheDeviceId|$cdpCacheDevicePort|$cdpCachePlatform|$cdpCacheIfIndex)\./) {
			my @cdpEntry = split(/\./,$id);

			given ($cdpEntry[0]) {
				when(/$cdpCacheDeviceId/) {
					$remoteHosts{$cdpEntry[1]} = $value;
				}
				when(/$cdpCacheDevicePort/) {
					$remotePorts{$cdpEntry[1]} = $value;
				}
				when(/$cdpCachePlatform/) {
					$remotePlatforms{$cdpEntry[1]} = $value;
				}
			}
		}
	}

	foreach my $ifIndex (keys(%remoteHosts)) {
		return_next({localifIndex=>$ifIndex,remoteifdesc=>$remotePorts{$ifIndex}, remotehostname=>$remoteHosts{$ifIndex}});
	}

	# Gracefully disconnect
	$session->close();

	# Return
	return undef;

$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_neighbors"(inet, text) IS 'Get the CDP table from a device to see who it is attached to';

/* API - modify_network_switchport_description
	
*/
CREATE OR REPLACE FUNCTION "api"."modify_network_switchport_description"(input_address inet, input_port text, input_rw_community text, input_description text) RETURNS VOID AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings('redefine');

	# Local variables and things
	our $host = shift;
	our $portName = shift;
	our $community = shift;
	our $description = shift;

	# OID List
	our $ifNameList_OID = '.1.3.6.1.2.1.31.1.1.1.1';
	our $ifAliasList_OID = '1.3.6.1.2.1.31.1.1.1.18';

	# Stored data
	our %ifIndexData;
	our $ifAliasOid = '1.3.6.1.2.1.31.1.1.1.18';

	# Establish session
	our ($session,$error) = Net::SNMP->session (
	     -hostname => $host,
	     -community => $community,
	);

	# Get the index of all interfaces
	my $ifNameList = $session->get_table(-baseoid => $ifNameList_OID);
	while (my($ifIndex,$ifName) = each(%$ifNameList)) {
		$ifIndex =~ s/$ifNameList_OID\.//;
		if($ifIndex =~ m/\d{5}/) {
			# $ifIndexData{$ifIndex} = $ifName;
			if($ifName eq $portName) {
				$ifAliasOid .= ".$ifIndex";
			}
		}
		# warn("$ifIndex - $ifName\n");
	}

	# Set the new description
	my $result = $session->set_request(
		-varbindlist => [ $ifAliasOid, OCTET_STRING, $description ],
	);

	if(!$result) {
		die("Error: ",$session->error());
	}

	# Close initial session
	$session->close();
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."modify_network_switchport_description"(inet, text, text, text) IS 'Modify the description of a network switchport';

CREATE OR REPLACE FUNCTION "api"."modify_network_switchport_admin_state"(input_address inet, input_port text, input_rw_community text, input_state boolean) RETURNS VOID AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings('redefine');

	# Local variables and things
	our $host = shift;
	our $portName = shift;
	our $community = shift;
	our $state = shift;

	# OID List
	our $ifNameList_OID = '.1.3.6.1.2.1.31.1.1.1.1';
	#our $ifAliasList_OID = '1.3.6.1.2.1.31.1.1.1.18';

	# Stored data
	our %ifIndexData;
	our $ifAdminStatusOid = '.1.3.6.1.2.1.2.2.1.7';

	# Establish session
	our ($session,$error) = Net::SNMP->session (
	     -hostname => $host,
	     -community => $community,
	);

	# Get the index of all interfaces
	my $ifNameList = $session->get_table(-baseoid => $ifNameList_OID);
	while (my($ifIndex,$ifName) = each(%$ifNameList)) {
		$ifIndex =~ s/$ifNameList_OID\.//;
		if($ifIndex =~ m/\d{5}/) {
			# $ifIndexData{$ifIndex} = $ifName;
			if($ifName eq $portName) {
				$ifAdminStatusOid .= ".$ifIndex";
			}
		}
		# warn("$ifIndex - $ifName\n");
	}

	# Finalize the data
	my $snmpState = 1;
	if($state eq 'f') {
		$snmpState = 2;
	}

	# Set the new description
	my $result = $session->set_request(
		-varbindlist => [ $ifAdminStatusOid, INTEGER, $snmpState ],
	);
	#die($state);
	#die($ifAdminStatusOid);

	if(!$result) {
		die("Error: ",$session->error());
	}

	# Close initial session
	$session->close();
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."modify_network_switchport_admin_state"(inet, text, text, boolean) IS 'Modify the admin state of a network switchport';

CREATE OR REPLACE FUNCTION "api"."send_renewal_email"(text, text, text) RETURNS VOID AS $$
	use strict;
	use warnings;
	use Net::SMTP;

	my $username = shift(@_) or die "Unable to get username";
	my $system = shift(@_) or die "Unable to get system name";
	my $domain = shift(@_) or die "Unable to get mail domain";

	my $smtp = Net::SMTP->new("mail.$domain");

	$smtp->mail("impulse\@$domain");
	$smtp->recipient("$username\@$domain");
	$smtp->data;
	$smtp->datasend("From: impulse\@$domain\n");
	$smtp->datasend("To: $username\@$domain\n");
	$smtp->datasend("Subject: System Renewal Notification - $system\n");
	$smtp->datasend("\n");
	$smtp->datasend("Your system \"$system\" will expire in less than 7 days and will be removed from IMPULSE automatically. You can click https://impulse.$domain/system/renew/$system to renew your system for another year. Alternatively you can navigate to the System view and click the Renew button. If you have any questions, please see your local system administrator.");

	$smtp->datasend;
	$smtp->quit;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."send_renewal_email"(text, text, text) IS 'Send an email to a user saying their system is about to expire';









-- vim: set filetype=perl:
