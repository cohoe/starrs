/* API - generate_dhcpd_config*/
CREATE OR REPLACE FUNCTION "api"."generate_dhcpd_config"() RETURNS VOID AS $$
	# Script written by Anthony Gargiulo
	use strict;
	use warnings;
	no warnings 'redefine';

	# First things first. defining the subroutines that make up this script.

	# Global Options
	sub global_opts
	{
		my ($row, $option, $value, $output);
		my $global_options = spi_query("SELECT * FROM api.get_dhcpd_global_options()");
		while (defined($row = spi_fetchrow($global_options)))
		{
			$option = $row->{option};
			$value = $row->{value};
			$output .= "$option    $value;\n"
		}
		return $output;
	} # end global options

	# DNS keys added here
	sub dns_keys
	{
		my $keys = spi_query("SELECT * FROM api.get_dhcpd_dns_keys()");
		my ($keyname, $key, $enctype, $row, $output);
		while (defined ($row = spi_fetchrow($keys)))
		{
			$keyname = $row->{keyname};
			$key = $row->{key};
			$enctype = $row->{enctype};
			$output .= "key $keyname {\n  algorithm ${enctype};\n  secret \"$key\";\n}\n";
		}
		return $output;
	}# end DNS keys
	
	# Zones are added here.
	sub forward_zones
	{
		my $zones = spi_query("SELECT * FROM api.get_dhcpd_forward_zones()");
		my ($zone, $keyname, $primary_ns, $row, $output);
		$output = "";
		while (defined ($row = spi_fetchrow($zones)))
		{
			$zone = $row->{zone};
			$keyname = $row->{keyname};
			$primary_ns = $row->{primary_ns};
			$output .= "zone $zone {\n  primary ${primary_ns};\n  key ${keyname};\n}\n";
		}
		return $output;
	}# end forward zones

	# Zones are added here.
	sub reverse_zones
	{
		my $zones = spi_query("SELECT * FROM api.get_dhcpd_reverse_zones()");
		my ($zone, $keyname, $primary_ns, $row, $output);
		$output = "";
		while (defined ($row = spi_fetchrow($zones)))
		{
			$zone = $row->{zone};
			$keyname = $row->{keyname};
			$primary_ns = $row->{primary_ns};
			$output .= "zone $zone {\n  primary ${primary_ns};\n  key ${keyname};\n}\n";
		}
		return $output;
	}# end reverse zones

	# DHCP Classes
	sub dhcp_classes
	{
		my $classes = spi_query("SELECT class,comment FROM api.get_dhcpd_classes()");
		my ($class, $comment, $row, $output);
		while (defined($row = spi_fetchrow($classes)))
		{
			$class = $row->{class};
			$comment = $row->{comment};
			$output .= "class \"$class\" {\n  # ${comment}\n";
			$output .= &dhcp_class_options($class);
			$output .= "}\n\n";
		}
		return $output;
	}# end &dhcp_classes

	# DHCP Class options
	sub dhcp_class_options
	{
		my $class = $_[0];
		my $options = spi_query("SELECT * FROM api.get_dhcpd_class_options('$class')");
		my ($option, $value, $row, $output);
		while (defined($row = spi_fetchrow($options)))
		{
			$option = $row->{option};
			$value = $row->{value};
			$output .= "    " . $option . ' ' . $value . ";\n";
		}
		return $output;
	}# end &dhcp_class_options

	## Shared networks
	#sub shared_networks
	#{
	#	my $network = spi_exec_query("SELECT api.get_site_configuration('NETWORK_NAME')");
	#	my $output = "shared-network " . $network->{rows}[0]->{get_site_configuration}. " {\n";
	#	$output .= &subnets;
	#	$output .= "}\n";
	#	return $output;
	#}
	
	# Subnets (for shared networks)
	sub subnets
	{
		my $subnets = spi_query("SELECT get_dhcpd_subnets, netmask(get_dhcpd_subnets) FROM api.get_dhcpd_subnets()");
		
		# $subnet = ip + netmask in slash notation; i.e. 10.21.49.0/24
		# $net = only the network address; i.e. 10.21.49.0
		# $mask = netmask in dotted decimal notation; i.e. 255.255.255.0
		my ($subnet, $net, $mask, $row, $output);
		
		while (defined($row = spi_fetchrow($subnets)))
		{
			$subnet = $row->{get_dhcpd_subnets};
			$net = substr($subnet, 0, index($subnet, "/"));
			$mask = $row->{netmask};
			$output .= "subnet $net netmask $mask {\n  ";
			$output .= "authoritative;";
			my $subnet_option = &subnet_options($subnet);
			if(defined($subnet_option))
			{
			   $output .= $subnet_option;
			}
			my $subnet_range = &subnet_ranges($subnet);
			if(defined($subnet_range))
			{
			   $output .= $subnet_range;
			}
			$output .= "\n}\n";
		}
		return $output;
	}
	
	# Subnet options
	sub subnet_options
	{
		my $subnet = $_[0];
		my $options = spi_query("SELECT option,value from api.get_dhcpd_subnet_options('$subnet')");
		my ($option, $value, $row, $output);
		while (defined($row = spi_fetchrow($options)))
		{
			$option = $row->{option};
			$value = $row->{value};
			$output .= "\n    $option $value;";
		}
		return $output;
	}
	
	# Subnet ranges
	sub subnet_ranges
	{
		my $subnet = $_[0];
		my $pool = spi_query("SELECT name,first_ip,last_ip,class from api.get_dhcpd_subnet_ranges('$subnet')");
		my ($range_name, $first_ip, $last_ip, $class, $row, $output);
		$output="";
		
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
				$output .= "\n      allow members of \"$class\";";
			}
			else
			{
				$output .= "\n      allow unknown clients;";
			}
			$output .= "\n    }";
		}
		return $output;
	}

	# hosts
	sub hosts
	{
		my $static_hosts = spi_query("SELECT * FROM api.get_dhcpd_static_hosts() order by owner,hostname");
		my $dynamic_hosts = spi_query("SELECT * FROM api.get_dhcpd_dynamic_hosts() order by owner,hostname");
		my ($hostname, $zone, $mac, $address, $owner, $class, $row, $output);
		$output .= "# Static hosts\n";
		while (defined($row = spi_fetchrow($static_hosts)))
		{
			$hostname = $row->{hostname};
			$zone = $row->{zone};
			$mac = $row->{mac};
			$address = $row->{address};
			$owner = $row->{owner};
			$class = $row->{class};
			
			$output .= &host_config($hostname, $zone, $mac, $address, $owner, $class);
		}
		$output .= "# Dynamic hosts\n";
		while (defined($row = spi_fetchrow($dynamic_hosts)))
		{
			$hostname = $row->{hostname};
			$zone = $row->{zone};
			$mac = $row->{mac};
			$owner = $row->{owner};
			$class = $row->{class};
			
			$output .= &host_config($hostname, $zone, $mac, undef, $owner, $class);
		}
		return $output;
	}

	# hosts config generation
	sub host_config
	{
		my ($hostname, $zone, $mac, $address, $owner, $class) = @_;
		
		my $hostmac = $mac;
		$hostmac =~ s/://g;
		
		my $output .= "# $owner\n";
		if (defined($hostname) && defined($zone))
		{
			$output .= "host $hostname.$zone {\n";
		}else 
		{
			$output .= "host $hostmac {\n";
		}
		$output .= "  option dhcp-client-identifier 1:$mac;\n";
		$output .= "  hardware ethernet $mac;\n";
		$output .= "  fixed-address $address;\n" if (defined($address));
		$output .= "  option host-name \"$hostname\";\n" if (defined($hostname));
		$output .= "  ddns-hostname \"$hostname\";\n" if (defined($hostname));
		$output .= "  ddns-domainname \"$zone\";\n" if (defined($zone));
		$output .= "  option domain-name \"$zone\";\n" if (defined($zone));
		$output .= "}\n";
		$output .= "subclass \"$class\" 1:$mac;\n";
		$output .= "subclass \"$class\" $mac;\n\n";
		return $output;
	}


	# lets start with the DHCPd.conf header from the DB
	my $header = spi_exec_query("SELECT api.get_site_configuration('DHCPD_HEADER')");
	my $output = $header->{rows}[0]->{get_site_configuration}. "\n\n"; 

	# add the date to the file
	my $date = spi_exec_query("SELECT localtimestamp(0)")->{rows}[0]->{now};
	$output .= "\# Generated at $date\n\n";

	# now for the rest of the config file
	$output .= &global_opts() . "\n";
	$output .= &dns_keys() . "\n";
	$output .= &forward_zones() . "\n";
	$output .= &reverse_zones() . "\n";
	$output .= &dhcp_classes() . "\n";
	$output .= &subnets() . "\n";
	$output .= &hosts() . "\n";

	$output .= "\# End dhcpd configuration file";

	# finally, store the config in the db, so we can get it back later.
	spi_exec_query("INSERT INTO management.output (value,file,timestamp) VALUES (\$\$".$output."\$\$,'dhcpd.conf',now())");

	#log our success with the api logging tool.
	spi_exec_query("SELECT api.create_log_entry('API','INFO','Successfully generated dhcpd.conf')");
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."generate_dhcpd_config"() IS 'Generate the config file for the dhcpd server, and store it in the db';
-- vim: set filetype=perl:
