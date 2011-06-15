#!/usr/bin/perl

use strict;
use warnings;
use Cwd;

my $dbname = "impulse";

my @files = ('create','remove','get','modify','utility');
my @schemas = ('dhcp','dns','firewall','ip','management','network','systems');

my $dir = getcwd();

print "Jumpstarting...\n";
system("psql","-f","\"$dir/Setup/Jumpstart.sql\"");
print "Setup...\n";
system("psql","-f","\"$dir/Setup/Setup.sql\"",$dbname);

print "Types...\n";
system("psql","-f","\"$dir/Setup/Types.sql\"",$dbname);

foreach my $schema (@schemas)
{
	foreach my $file (@files)
	{
		print "API $schema $file\n";
		system("psql","-f","\"$dir/API/$schema/api\_$schema\_$file.sql\"",$dbname);
	}
}

print "Tables...\n";
system("psql","-f","\"$dir/Setup/Tables.sql\"",$dbname);
print "Fixes...\n";
system("psql","-f","\"$dir/Setup/Fixes.sql\"",$dbname);
print "Constraints...\n";
system("psql","-f","\"$dir/Setup/Constraints.sql\"",$dbname);

foreach my $schema (@schemas)
{
	print "Triggers for $schema\n";
	system("psql","-f","\"$dir/Triggers/triggers\_$schema.sql\"",$dbname);
}

print "Triggers...\n";
system("psql","-f","\"$dir/Triggers/Triggers.sql\"",$dbname);
print "Views...\n";
system("psql","-f","\"$dir/Setup/Views.sql\"",$dbname);
print "Base...\n";
system("psql","-f","\"$dir/Setup/Base.sql\"",$dbname);
print "Privileges...\n";
system("psql","-f","\"$dir/Setup/Privileges.sql\"",$dbname);
print "Documentation...\n";
system("psql","-f","\"$dir/API/Documentation/api_documentation_get.sql\"",$dbname);
system("psql","-f","\"$dir/Setup/Document.sql\"",$dbname);
foreach my $schema (@schemas)
{
	print "Documentation for $schema\n";
	system("psql","-f","\"$dir/API/Documentation/api\_documentation\_$schema.sql\"",$dbname);
}
print "Done!";