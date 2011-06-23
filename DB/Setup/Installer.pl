#!/usr/bin/perl

use strict;
use warnings;
use Cwd;

my $dbhost = "localhost";
my $dbuser = "postgres";
my $dbport = 5432;
my $dbname = "impulse";

my @files = ('create','remove','get','modify','utility');
my @schemas = ('dhcp','dns','firewall','ip','management','network','systems');

my $dir = getcwd();


print "Jumpstarting...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Jumpstart.sql\"");
print "Setup...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Setup.sql\" $dbname");
print "Types...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Types.sql\" $dbname");

foreach my $schema (@schemas)
{
	foreach my $file (@files)
	{
		print "API $schema $file\n";
		system("psql -h $dbhost -p $dbport -U $dbuser -f \"API\\$schema\\api\_$schema\_$file.sql\" $dbname");

	}
}

print "Tables...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Tables.sql\" $dbname");
print "Fixes...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Fixes.sql\" $dbname");
print "Constraints...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Constraints.sql\" $dbname");

foreach my $schema (@schemas)
{
	print "Triggers for $schema\n";
	system("psql -h $dbhost -p $dbport -U $dbuser -f \"Triggers\\triggers_$schema.sql\" $dbname");
}

print "Triggers...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Triggers\\Triggers.sql\" $dbname");

print "Views...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Views.sql\" $dbname");
print "Base...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Base.sql\" $dbname");
print "Privileges...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Privileges.sql\" $dbname");

print "Documentation...\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"API\\Documentation\\api_documentation_get.sql\" $dbname");
system("psql -h $dbhost -p $dbport -U $dbuser -f \"API\\Documentation\\api_documentation_utility.sql\" $dbname");
system("psql -h $dbhost -p $dbport -U $dbuser -f \"Setup\\Document.sql\" $dbname");
foreach my $schema (@schemas)
{
	print "Documentation for $schema\n";
	system("psql -h $dbhost -p $dbport -U $dbuser -f \"API\\Documentation\\api_documentation_$schema.sql\" $dbname");

}
print "Documentation for documentation\n";
system("psql -h $dbhost -p $dbport -U $dbuser -f \"API\\Documentation\\api_documentation_documentation.sql\" $dbname");

print "Done!";
