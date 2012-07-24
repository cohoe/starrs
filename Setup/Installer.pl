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

# Settings
my $dbsuperuser = "postgres";
my $dbadminuser = "starrs_admin";
my $dbadminpass = "adminpass";
my $dbclientuser = "starrs_client";
my $dbclientpass = "clientpass";

my $dbhost = "localhost";
my $dbport = 5432;
my $dbname = "starrs";

my @files = ('create','remove','get','modify','utility');
my @schemas = ('DHCP','DNS','IP','Management','Network','Systems');

my $dir = abs_path($0);
$dir =~ s/Setup\/Installer.pl//;

my $sed = "sed -e 's/STARRSADMINUSER/$dbadminuser/g' -e 's/STARRSCLIENTUSER/$dbclientuser/g' -e 's/STARRSDBNAME/$dbname/g' -e 's/STARRSADMINPASSWORD/$dbadminpass/g' -e 's/STARRSCLIENTPASSWORD/$dbclientpass/g'";

print "Jumpstarting ($dbsuperuser)...\n";
system("$sed \"$dir\"\"Setup\/Jumpstart.sql\" | psql -h $dbhost -p $dbport -U $dbsuperuser");
print "Setup...\n";
system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Setup\/Setup.sql\" $dbname");
print "Preload...\n";
system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Setup\/Preload.sql\" $dbname");
print "Tables...\n";
system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Setup\/Tables.sql\" $dbname");
print "Types...\n";
system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Setup\/Types.sql\" $dbname");
print "Privileged functions ($dbsuperuser)...\n";
system("psql -h $dbhost -p $dbport -U postgres -f \"$dir\"\"API\/plperl.sql\" $dbname");

foreach my $schema (@schemas)
{
	foreach my $file (@files)
	{
		print "API $schema $file\n";
		system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"API\/$schema\/api\_".lc($schema)."\_$file.sql\" $dbname");

	}
}

print "Constraints...\n";
system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Setup\/Constraints.sql\" $dbname");

foreach my $schema (@schemas)
{
	print "Triggers for $schema\n";
	$schema = lc($schema);
	system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Triggers\/triggers_$schema.sql\" $dbname");
}

print "Triggers...\n";
system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Triggers\/triggers.sql\" $dbname");

print "Base...\n";
system("psql -h $dbhost -p $dbport -U $dbadminuser -f \"$dir\"\"Setup\/Base.sql\" $dbname");
print "Privileges...\n";
system("$sed \"$dir\"\"Setup\/Privileges.sql\" | psql -h $dbhost -p $dbport -U $dbadminuser $dbname");

print "Done!\n";
