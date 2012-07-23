#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';

# These will ensure the user has the right modules installed
use Net::IP;
use Data::Validate::Domain;
use Net::LDAP;
use Net::DNS;
use Net::SNMP;
use Net::SMTP;

my $dbhost = "localhost";
my $dbuser = "postgres";
my $dbport = 5432;
my $dbname = "impulse";

my @files = ('create','remove','get','modify','utility');
my @schemas = ('DHCP','DNS','IP','Management','Network','Systems');

my $dir = abs_path($0);
$dir =~ s/Setup\/Reload.pl//;

print "Clearing...";
system("psql -h $dbhost -p $dbport -U $dbuser $dbname -c \"SELECT 'DROP FUNCTION ' || ns.nspname || '.' || proname || '(' || oidvectortypes(proargtypes) || ');'
FROM pg_proc INNER JOIN pg_namespace ns ON (pg_proc.pronamespace = ns.oid)
WHERE ns.nspname = 'api'  order by proname\" --no-align --no-readline --quiet --tuples-only > $dir/Setup/apilist.sql");
system("psql -h $dbhost -p $dbport -U $dbuser $dbname -f $dir/Setup/apilist.sql");

print "Privileged...";
system("psql -h $dbhost -p $dbport -U postgres $dbname -f $dir/API/plperl.sql");
foreach my $schema (@schemas)
{
	foreach my $file (@files)
	{
		print "API $schema $file\n";
		system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"API\/$schema\/api\_".lc($schema)."\_$file.sql\" $dbname");

	}
}

foreach my $schema (@schemas)
{
	print "Triggers for $schema\n";
	$schema = lc($schema);
	system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Triggers\/triggers_$schema.sql\" $dbname");
}

print "Done!\n";
