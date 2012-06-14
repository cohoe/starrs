#!/usr/bin/perl -w 

use strict;
use warnings;

use Net::SNMP;
use Getopt::Std;
use Data::Dumper;
use Socket;

# Define OIDs
my $vtpVlanState = ".1.3.6.1.4.1.9.9.46.1.3.1.1.2";

# Needed Variables
my $hostname;
my $community;
my $sql;

# Get command line options
my %options;
getopts('h:c:s',\%options);

# Check that required CLI options were given
if(defined($options{h}) && defined($options{c})) {
	$hostname = gethostbyaddr(inet_aton($options{h}),AF_INET);
	$community = $options{c};
}
else {
	print "Usage: perl $0 -h hostname -c community [-s]\n";
	exit 1;
}

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
my $vlanList = $session->get_table(-baseoid => $vtpVlanState);

# Do something for each item of the list
if(defined($options{s})) {
	$sql = "INSERT INTO vlans (hostname, vlan) VALUES ";
}
while ( my ($vlan, $vtpState) = each(%$vlanList)) {
	$vlan =~ s/$vtpVlanState\.1\.//;
	if(defined($options{s})) {
		$sql .= "('$hostname','$vlan'),";
	}
	else {
		print "VLAN $vlan State $vtpState\n";
	}
}
if(defined($options{s})) {
	$sql =~ s/\,$/;/;
	print $sql, "\n";
}

# Gracefully disconnect
$session->close();
