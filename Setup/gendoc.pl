#!/usr/bin/perl

use strict;
use warnings;
use feature 'switch';

open REFERENCE, "<", $ARGV[0] or die "Could not open file\n";

my %function_data = ();

my $index = 0;

while (<REFERENCE>)
{
	chomp $_;
	$_ =~ s/^\s{4}$//;
	if ($_ =~ m/^\d\.\d\.\d\.\d{1,}\s/)
	{
		$index++;
		$function_data{$index} = [];
	}
	else
	{
		if ($_ ne '')
		{
			push (@{$function_data{$index}}, $_);
		}
	}
}


for (my $i = 3; $i < $index; $i++)
{
	my $comment = "";
	my $definition = "";
	my $return = "";
	my $example = "";

	my @comment_lines = ();
	my @definition_lines = ();
	my @argument_lines = ();
	my @return_lines = ();
	my @rule_lines = ();
	my @example_lines = ();

	my $mode = "COM";
	foreach my $line (@{$function_data{$i}})
	{
		if ($line =~ m/\s{4}Definition:/)
		{
			$mode = "DEF";
			next;
		}
		elsif ($line =~ m/\s{4}Arguments:/)
		{
			$mode = "ARG";
			next;
		}
		elsif ($line =~ m/\s{4}Returns:/)
		{
			$mode = "RET";
			next;
		}
		elsif ($line =~ m/\s{4}Rules:/)
		{
			$mode = "RUL";
			next;
		}
		elsif ($line =~ m/\s{4}Example:/)
		{
			$mode = "EXA";
			next;
		}
		
		$line =~ s/^\s{4,}//;
		
		given ($mode) {
			when (/COM/) {
				$comment .= $line;
			}
			when (/DEF/) {
				$definition .= $line;
			}
			when (/ARG/) {
				push(@argument_lines, $line);
			}
			when (/RET/) {
				$return .= $line;
			}
			when (/RUL/) {
				push(@rule_lines, $line);
			}
			when (/EXA/) {
				$example .= $line;
			}
		}
	}
	
	#print "Comment: \"$comment\"\n";
	#print "Definition: \"$definition\"\n";
	#print "Return: \"$return\"\n";
	#print "Example: \"$example\"\n";
	
	my $name = $definition;
	$name =~ s/^(.*)\((.*)/$1/;
	$name =~ s/api\.//;
	#print "Name: \"$name\"\n";
	
	#$example =~ s/\'/\\\'/g;
	
	#print "\n\n";
	foreach my $arg (@argument_lines)
	{
		my ($arg_name,$arg_comment) = split(/ - /,$arg);
		if ($arg_comment)
		{
			#print "$name TROLO $comment\n";
			print "UPDATE \"documentation\"\.\"arguments\"
SET \"comment\" \= '$arg_comment'
WHERE \"argument\" = '$arg_name'
AND \"specific_name\" ~* '^$name",'(_)+([0-9])+$\';',"\n\n";
		}
	}
		print <<LOLZ
UPDATE "documentation"."functions"
SET "example" = \$\$$example\$\$, "comment" = '$comment'
WHERE "specific_name" ~* '^$name(_)+([0-9])+\$';

LOLZ
}

close REFERENCE;