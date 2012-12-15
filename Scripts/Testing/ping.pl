#!/usr/bin/perl

use strict;
use warnings;
use Net::IP qw(ip_get_version);

# The reason I don't use a perl module for this is because:
# * Net::IP requires root privileges, which is stupid
# * Net::IP::External doesnt honor timeout values

my $res = 1;

if (ip_get_version($ARGV[0]) == 6) {
	$res = system("ping6 -W 1 -c 1 $ARGV[0] > /dev/null");
} else {
	$res = system("ping -W 1 -c 1 $ARGV[0] > /dev/null");
}
if($res == 0) {
	print "up";
} else {
	print "down";
}
