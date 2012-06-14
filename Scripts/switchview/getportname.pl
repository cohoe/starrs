#!/usr/bin/perl -w 

use strict;
use warnings;

use Net::SNMP;
use Getopt::Std;
use Data::Dumper;
use Socket;

# Define OIDs
#my $ifName = ".1.3.6.1.2.1.31.1.1.1.1";
my $ifDesc = ".1.3.6.1.2.1.2.2.1.2";

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
	$hostname = gethostbyaddr(inet_aton($options{h}),AF_INET);
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
my $portNameList = $session->get_table(-baseoid => $ifDesc);

# Do something for each item of the list
if(defined($options{s})) {
	$sql = "INSERT INTO portname (hostname, vlan, ifindex, ifname) VALUES ";
}
while ( my ($portIndex, $portName) = each(%$portNameList)) {
	$portIndex =~ s/$ifDesc\.//;
	if(defined($options{s})) {
		$sql .= "('$hostname','$vlan','$portIndex','$portName'),";
	}
	else {
		print "PortIndex: $portIndex - Name: $portName\n";
	}
}
if(defined($options{s})) {
	$sql =~ s/\,$/;/;
	print $sql,"\n";
}

# Gracefully disconnect
$session->close();
