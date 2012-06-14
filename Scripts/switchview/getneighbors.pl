#!/usr/bin/perl -w 

use strict;
use warnings;

use Net::SNMP;
use Getopt::Std;
use Data::Dumper;
use Socket;
use 5.10.0;

# Define OIDs
my $cdpCacheEntry = "1.3.6.1.4.1.9.9.23.1.2.1.1";
my $cdpCacheDeviceId = "6";
my $cdpCacheDevicePort = "7";
my $cdpCachePlatform = "8";

# Needed Variables
my $hostname;
my $community;
my $vlan;
my $sql;

# Data containers
my %remoteHosts;
my %remotePorts;
my %remotePlatforms;

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
my $neighborList = $session->get_table(-baseoid => $cdpCacheEntry);

# Do something for each item of the list
if(defined($options{s})) {
	$sql = "INSERT INTO neighbors (hostname, vlan, ifindex, neighbor, port, platform) VALUES ";
}

while ( my ($id, $value) = each(%$neighborList)) {
	$id=~ s/$cdpCacheEntry\.//;
	
	if($id =~ m/^($cdpCacheDeviceId|$cdpCacheDevicePort|$cdpCachePlatform)\./) {
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
	if(defined($options{s})) {
		$sql .= "('$hostname','$vlan','$ifIndex','$remoteHosts{$ifIndex}','$remotePorts{$ifIndex}','$remotePlatforms{$ifIndex}'),";
	}
	else {
		print "Remote Device: $remoteHosts{$ifIndex} - Remote Port: $remotePorts{$ifIndex} - Remote Platform: $remotePlatforms{$ifIndex}\n";	
	}
}
if(defined($options{s})) {
	$sql =~ s/\,$/;/;
	print $sql,"\n";
}

# Gracefully disconnect
$session->close();
