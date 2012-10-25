#!/usr/bin/perl -w 

use strict;
use warnings;

use Net::SNMP;
use Getopt::Std;
use Data::Dumper;
use Socket;

# Define OIDs
my $dot1dBasePortIfIndex = ".1.3.6.1.2.1.17.1.4.1.2";

# Needed Variables
my $hostname;
my $community;
my $vlan;
my $sql;

# Get command line options
my %options;
getopts('h:c:v:s',\%options);

# Check that required CLI options were given
if(defined($options{h}) && defined($options{c}) && defined($options{v})) {
	$hostname = $options{h};
	$community = $options{c};
	$vlan = $options{v};
}
else {
	print "Usage: perl $0 -h hostname -c community -v vlan [-s]\n";
	exit 1;
}

# Establish session
my ($session,$error) = Net::SNMP->session (
	-hostname => "$hostname",
	-community => "$community\@$vlan",
);

# Check that it did not error
if (!defined($session)) {
	print $error;
	exit 1;
}

# Get a list of all data
my $portIndexList = $session->get_table(-baseoid => $dot1dBasePortIfIndex);

# Do something for each item of the list
if(defined($options{s})) {
	$sql = "INSERT INTO portindex (hostname, vlan, bridgeportid, ifindex) VALUES ";
}
while ( my ($bridgePortID, $portIndex) = each(%$portIndexList)) {
	$bridgePortID =~ s/$dot1dBasePortIfIndex\.//;
	if(defined($options{s})) {
		$sql .= "('$hostname','$vlan','$bridgePortID','$portIndex'),";
	}
	else {
		print "BridgePortID: $bridgePortID - IfIndex: $portIndex\n";
	}
}
if(defined($options{s})) {
	$sql =~ s/\,$/;/;
	print $sql,"\n";
}

# Gracefully disconnect
$session->close();
