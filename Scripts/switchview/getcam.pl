#!/usr/bin/perl -w 

use strict;
use warnings;

use Net::SNMP;
use Getopt::Std;
use Data::Dumper;
use Socket;

# Define OIDs
my $dot1dTpFdbAddress = ".1.3.6.1.2.1.17.4.3.1.1";

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
	print "Usage: perl $0 -h hostname -c community -v vlan\n";
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
my $camList = $session->get_table(-baseoid => $dot1dTpFdbAddress);

# Do something for each item of the list
if(defined($options{s})) {
	$sql = "INSERT INTO cam (hostname, vlan, camportinstanceid, mac) VALUES ";
}
while ( my ($camPortInstanceID, $macaddr) = each(%$camList)) {
	$camPortInstanceID =~ s/$dot1dTpFdbAddress//;
	
	# Sometimes there are non-valid MAC addresses in the CAM.
	if($macaddr =~ m/[0-9a-fA-F]{12}/) {
		$macaddr = &format_raw_mac($macaddr);
		if(defined($options{s})) {
			$sql .= "('$hostname','$vlan','$camPortInstanceID','$macaddr'),";
		}
		else {
			print "InstanceID: $camPortInstanceID - MAC: $macaddr\n";
		}
	}
}

if(defined($options{s})) {
	$sql =~ s/\,$/;/;
	print $sql,"\n";
}

# Gracefully disconnect
$session->close();

# Subroutine to format a MAC address to something nice
sub format_raw_mac() {
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
