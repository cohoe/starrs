#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';

my $dbhost = "localhost";
my $dbuser = "impulse_admin";
my $dbport = 5432;
my $dbname = "impulse";

my @files = ('create','remove','get','modify','utility');
my @schemas = ('DHCP','DNS','IP','Management','Network','Systems');

my $dir = abs_path($0);
$dir =~ s/Setup\/Installer.pl//;

print "Jumpstarting...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Jumpstart.sql\" postgres");
print "Setup...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Setup.sql\" $dbname");
print "Types...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Types.sql\" $dbname");

foreach my $schema (@schemas)
{
	foreach my $file (@files)
	{
		print "API $schema $file\n";
		system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"API\/$schema\/api\_".lc($schema)."\_$file.sql\" $dbname");

	}
}

print "Tables...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Tables.sql\" $dbname");
print "Fixes...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Fixes.sql\" $dbname");
print "Constraints...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Constraints.sql\" $dbname");

foreach my $schema (@schemas)
{
	print "Triggers for $schema\n";
	$schema = lc($schema);
	system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Triggers\/triggers_$schema.sql\" $dbname");
}

print "Triggers...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Triggers\/triggers.sql\" $dbname");

print "Views...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Views.sql\" $dbname");
print "Base...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Base.sql\" $dbname");
print "Privileges...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Privileges.sql\" $dbname");

print "Documentation...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"API\/Documentation\/api_documentation_get.sql\" $dbname");
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"API\/Documentation\/api_documentation_utility.sql\" $dbname");
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"Setup\/Document.sql\" $dbname");
foreach my $schema (@schemas)
{
	print "Documentation for $schema\n";
	$schema = lc($schema);
	system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"API\/Documentation\/api_documentation_$schema.sql\" $dbname");

}
print "Documentation for documentation\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"$dir\"\"API\/Documentation\/api_documentation_documentation.sql\" $dbname");

print "Done!\n";
