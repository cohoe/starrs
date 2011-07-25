CREATE OR REPLACE FUNCTION "api"."generate_dhcpd_config"() RETURNS VOID AS $$
	# Script written by Anthony Gargiulo
	use strict;
	use warnings;
	
	my $username = 'root';
	spi_exec_query("SELECT api.initialize('$username')");

	#let's start with the DHCPd.conf header from the DB
	my $header = spi_exec_query("SELECT api.get_site_configuration('DHCPD_HEADER')");
	my $output = $header->{rows}[0]->{get_site_configuration}. "\n\n"; 

	# Global Options are added here.
	{
		my ($row, $option, $value);
		my $global_options = spi_query("SELECT * FROM api.get_dhcpd_global_options()");
		while (defined($row = spi_fetchrow($global_options)))
		{
			$option = $row->{option};
			$value = $row->{value};
			$output .= "$option    $value;\n"
		}
	}# end global options
	
	$output .= "\n";
	
	# DNS keys added here
	{
		my $keys = spi_query("SELECT * FROM api.get_dhcpd_dns_keys()");
		my ($keyname, $key, $enctype, $row);
		while (defined ($row = spi_fetchrow($keys)))
		{
			$keyname = $row->{keyname};
			$key = $row->{key};
			$enctype = $row->{enctype};
			$output .= "key $keyname {\n  algorithm ${enctype};\n  secret \"$key\";\n}\n";
		}
	}# end DNS keys
	
	$output .= "\n";

	# Zones are added here.
	{
		my $zones = spi_query("SELECT * FROM api.get_dhcpd_reverse_zones()");
		my ($zone, $keyname, $primary_ns, $row);
		while (defined ($row = spi_fetchrow($zones)))
		{
			$zone = $row->{zone};
			$keyname = $row->{keyname};
			$primary_ns = $row->{primary_ns};
			$output .= "zone $zone {\n  primary ${primary_ns};\n  key ${keyname};\n}\n";
		}
	}# end reverse zones

	$output .= "\n";

	# DHCP Classes and class options
	{
		my $classes = spi_query("SELECT class,comment FROM api.get_dhcpd_classes()");
		my ($class, $comment, $option, $value, $row, $row_opts);
		while (defined($row = spi_fetchrow($classes)))
		{
			$class = $row->{class};
			$comment = $row->{comment};
			$output .= "class \"$class\" {\n  # ${comment}\n";
			my $options = spi_query("SELECT option,value FROM api.get_dhcpd_class_options('$class')");
			while (defined($row_opts = spi_fetchrow($options)))
			{
				$option = $row_opts->{option};
				$value = $row_opts->{value};
				$output .= "    " . $option . ' ' . $value . ";\n";
			}
			$output .= "}\n\n";
		}# end DHCP classes and class options
	}

	$output .= "\n";

	# shared network
	{
		my $subnets = spi_query("SELECT get_dhcpd_subnets, netmask(get_dhcpd_subnets) FROM api.get_dhcpd_subnets()");

		# $subnet = ip + netmask in / notation; i.e. 10.21.49.0/24
		# $net = only the network address; i.e. 10.21.49.0
		# $mask = netmask in dotted decimal notation; i.e. 255.255.255.0
		my ($subnet, $net, $mask, $row);
		my $network = spi_exec_query("SELECT api.get_site_configuration('NETWORK_NAME')");
		$output .= "shared-network " . $network->{rows}[0]->{get_site_configuration}. " {\n  "; 
		while (defined($row = spi_fetchrow($subnets)))
		{
			$subnet = $row->{get_dhcpd_subnets};
			$net = substr($subnet, 0, index($subnet, "/"));
			$mask = $row->{netmask};
			$output .= "subnet $net netmask $mask {\n    ";
			$output .= "authoritative;";
			{
				my $options = spi_query("SELECT option,value from api.get_dhcpd_subnet_options('$subnet')");
				my ($option, $value, $row);
				while (defined($row = spi_fetchrow($options)))
				{
					$option = $row->{option};
					$value = $row->{value};
					$output .= "\n    $option $value;";
				}
				{
					my $pool = spi_query("SELECT name,first_ip,last_ip,class from api.get_dhcpd_subnet_ranges('$subnet')");
					my ($range_name, $first_ip, $last_ip, $class, $row);
					while (defined($row = spi_fetchrow($pool)))
					{
						$range_name = $row->{name};
						$first_ip = $row->{first_ip};
						$last_ip = $row->{last_ip};
						$class = $row->{class};
						$output .= "\n    pool {\n      range $first_ip $last_ip;";
						{
							my $range_options = spi_query("SELECT * from api.get_dhcpd_range_options('$range_name')");
							my ($option, $value, $row);
							while (defined($row = spi_fetchrow($range_options)))
							{
								$option = $row->{option};
								$value = $row->{value};
								$output .= "\n      $option $value;";
							}
						}
						if (defined($class))
						{
							$output .= "\n      allow members of \"$class\"";
						}
						else
						{
							$output .= "\n      allow unknown clients";
						}
						$output .= "\n    }";
					}
				}
			}
			$output .= "\n  }\n\n  ";
		}
	}# shared networks

	$output .= "\n";

	# 'static' hosts
	{
		my $hosts = spi_query("SELECT * FROM api.get_dhcpd_static_hosts() order by owner,hostname");
		my ($hostname, $zone, $mac, $address, $owner, $class, $row);
		while (defined($row = spi_fetchrow($hosts)))
		{
			$hostname = $row->{hostname};
			$zone = $row->{zone};
			$mac = $row->{mac};
			$address = $row->{address};
			$owner = $row->{owner};
			$class = $row->{class};
			
			$output .= "#$owner\n";
			$output .= "host $hostname {\n";
			$output .= "  opiton dhcp-client-identifier 1:$mac;\n";
			$output .= "  hardware ethernet $mac;\n";
			$output .= "  fixed-address $address;\n";
			$output .= "  option host-name \"$hostname\";\n";
			$output .= "  ddns-hostname \"$hostname\";\n";
			$output .= "  ddns-domainname \"$zone\";\n";
			$output .= "  option domain-name \"$zone\";\n}\n";
			$output .= "subclass \"$class\" 1:$mac;\n";
			$output .= "subclass \"$class\" $mac;\n\n";
			
		}
	}
	
	# dynamic hosts
	{
		my $hosts = spi_query("SELECT * FROM api.get_dhcpd_dynamic_hosts() order by owner,hostname");
		my ($hostname, $zone, $mac, $owner, $class, $row);
		while (defined($row = spi_fetchrow($hosts)))
		{
			$hostname = $row->{hostname};
			$zone = $row->{zone};
			$mac = $row->{mac};
			$owner = $row->{owner};
			$class = $row->{class};
			
			$output .= "#$owner\n";
			$output .= "host $hostname {\n";
			$output .= "  opiton dhcp-client-identifier 1:$mac;\n";
			$output .= "  hardware ethernet $mac;\n";
			$output .= "  option host-name \"$hostname\";\n";
			$output .= "  ddns-hostname \"$hostname\";\n";
			$output .= "  ddns-domainname \"$zone\";\n";
			$output .= "  option domain-name \"$zone\";\n}\n";
			$output .= "subclass \"$class\" 1:$mac;\n";
			$output .= "subclass \"$class\" $mac;\n\n";
			
		}
	}

	# finally, store the config in the db, so we can get it back later.
	spi_exec_query("INSERT INTO management.output (value,file,timestamp) VALUES (\$\$".$output."\$\$,'dhcpd.conf',now())");

	#log our success with the api logging tool.
	spi_exec_query("SELECT api.create_log_entry('API','INFO','Successfully generated dhcpd.conf')");
	spi_exec_query("SELECT api.deinitialize()");
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."generate_dhcpd_config"() IS 'Generate the config file for the dhcpd server, and store it in the db';
CREATE OR REPLACE FUNCTION "api"."write_dhcpd_config"() RETURNS VOID AS $$
	# Script written by Anthony Gargiulo
	my $configFile = "/etc/dhcpd.conf";
	my $tempConfigFile = "/tmp/dhcpd.conf.tmp";
	
	if (! open (CONFIG, ">", "$configFile"))
	{
		warn("Cannot open $configFile for writing: [$!]. Using $tempConfigFile instead.\n");
		open (CONFIG, ">", "$tempConfigFile") || die "Cannot open the temp config file at $tempConfigFile: $!";
	}

	my $row;
	my $output;
	my $cursor = spi_query("SELECT * FROM management.output where file = 'dhcpd.conf' order by output_id desc limit 1");
	while (defined ($row = spi_fetchrow($cursor)))
	{
		$output = $row->{value};
		print CONFIG $output;
	}
#	use Mail::Sendmail;
#
#	sendmail(
#		From 	=> 'sendmail@iota.csh.rit.edu',
#		To 		=> 'bballtheway7@gmail.com',
#		Subject => 'foobar',
#		Message => "$output",
#	);
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."write_dhcpd_config"() IS 'Writes the dhcpd server config file from the database to the location of the users choice, default is to disk, as the main config for said server';
