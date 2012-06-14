#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  dns.pl
#
#        USAGE:  ./dns.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  YOUR NAME (), 
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  05/21/2012 11:19:09 AM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Socket;

my $address = inet_ntoa(inet_aton("www.csh.rit.edu"));
print $address,"\n";

my $name = gethostbyaddr(inet_aton("129.21.49.249"), AF_INET);
print $name,"\n";
