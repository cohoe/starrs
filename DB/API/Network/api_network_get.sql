CREATE OR REPLACE FUNCTION "api"."get_network_switchport_view"(inet,text) RETURNS SETOF "network"."switchview_data" AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings 'redefine';

	#my $host = $ARGV[0] or die "IP address must be the first argument";
	#my $community = $ARGV[1] or die "Community must be the second argument";
	our $host = $_[0];
	our $community = $_[1];

	our $vlanList_OID = '.1.3.6.1.4.1.9.9.46.1.3.1.1.2';
	our $macTable_OID = '.1.3.6.1.2.1.17.4.3.1.1';
	our $bridgeNum_OID = '.1.3.6.1.2.1.17.4.3.1.2';
	our $ifIndex_OID = '.1.3.6.1.2.1.17.1.4.1.2';
	our $ifName_OID = '.1.3.6.1.2.1.31.1.1.1.1';

	sub format_mac() {
		my $mac = $_[0];

		$mac =~ s/(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})/$1:$2:$3:$4:$5:$6/;

		return $mac;
	}

	sub vlans() {
		my ($session,$error) = Net::SNMP->session (
			-hostname => shift || $host,
			-community => shift || "$community",
		);

		my $vlans = $session->get_table(-baseoid => $vlanList_OID);
		
		my @returns;
		while (my ($key,$value) = each(%$vlans)) {
			$key =~ s/$vlanList_OID\.1\.//;
			push(@returns,$key);
		}

		return @returns;
		#my @actuals = (49,50);
		#return @actuals;
	}

	my @vlans = &vlans();
	foreach my $vlan (@vlans) {
		my ($session,$error) = Net::SNMP->session (
			-hostname => shift || $host,
			-community => shift || "$community\@$vlan",
		);
		
		my %results;
		my $mac_addresses = $session->get_table(-baseoid => $macTable_OID);
		while (my ($key,$value) = each(%$mac_addresses) ) {
			#print "$key - $value\n";
			$key =~ s/$macTable_OID//;
			#print "$key\n";
			$value =~ s/^0x//;
			$results{$key} = $value;
		}
		
		my %mac_index;
		my $mac_bridge_numbers = $session->get_table(-baseoid => $bridgeNum_OID);
		while (my ($key,$value) = each(%$mac_bridge_numbers) ) {
			$key =~ s/$bridgeNum_OID//;
			$mac_index{$value} = $results{$key};
		}
		
		my %bridge_mac;
		my $interface_indexes = $session->get_table(-baseoid => $ifIndex_OID);
		while (my ($key,$value) = each(%$interface_indexes)) {
			$key =~ s/$ifIndex_OID\.//;
			my $mac = $mac_index{$key};
			if($mac) {
				$bridge_mac{$value} = $mac;
			}
		}
		
		my %final;
		my $interface_names = $session->get_table(-baseoid => $ifName_OID);
		while (my ($key,$value) = each(%$interface_names)) {
			$key =~ s/$ifName_OID\.//;
			my $mac = $bridge_mac{$key};
			if($mac) {
				$final{$mac} = $value;
			}
		}
		
		my %output;
		while (my ($key,$value) = each(%final)) {
			if($key =~ m/[a-fA-F0-9]{12}/) {
				$output{$value} = &format_mac($key);
				my %row;
				$row{port} = $value;
				$row{mac} = &format_mac($key);
				return_next(\%row);
				#print &format_mac($key)." - $value\n";
			}
		}

		#while (my ($port,$mac) = each(%output)) {
		#	#print "$port - VLAN $vlan - $mac\n";
		#	my %row;
		#	$row{port} = $port;
		#	$row{mac} = $mac;
		#	return_next(\%row);
		#}
		$session->close();
	}

	return;
$$ LANGUAGE 'plperlu';

/* API - get_network_switchview_active_state */
CREATE OR REPLACE FUNCTION "api"."get_network_switchview_active_state"(inet,text) RETURNS SETOF "network"."switchview_state_data" AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings 'redefine';

	# Connection information
	our $host = $_[0];
	our $community = $_[1];

	# OID List
	our $ifName_OID = '.1.3.6.1.2.1.31.1.1.1.1';
	our $ifOperStatus_OID = '.1.3.6.1.2.1.2.2.1.8';

	# Arrays of data
	my %ifIndexData;
	my %ifNameData;

	# Establish session
	my ($session,$error) = Net::SNMP->session (
	     -hostname => $host,
	     -community => $community,
	);

	# Get a listing of all port indexes and their current state
	my $portIndexStatus = $session->get_table(-baseoid => $ifOperStatus_OID);
	while (my($ifIndex,$portState) = each(%$portIndexStatus)) {
		$ifIndex =~ s/$ifOperStatus_OID\.//;
		if($ifIndex =~ m/\d{5}/) {
			$ifIndexData{$ifIndex} = $portState;
		}
	}

	# Get a list of all port names?
	my $portNames = $session->get_table(-baseoid => $ifName_OID);
	while (my($ifIndex,$ifName) = each(%$portNames)) {
		$ifIndex =~ s/$ifName_OID\.//;
		if($ifIndex =~ m/\d{5}/) {
			$ifNameData{$ifIndex} = $ifName;
		}
	}

	# Map the data;
	while (my ($ifIndex,$ifName) = each(%ifNameData)) {
		my %row;
		$row{port} = $ifName;
		$row{state}=0;
		if($ifIndexData{$ifIndex}-1==0) {
			$row{state}=1;
		}
		return_next(\%row);
	}

	# Close session
	$session->close();
	return;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_network_switchview_active_state"(inet,text) IS 'Get the current state of the switchports on a system';

/* API - get_network_switchview_admin_state */
CREATE OR REPLACE FUNCTION "api"."get_network_switchview_admin_state"(inet,text) RETURNS SETOF "network"."switchview_state_data" AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings 'redefine';

	# Connection information
	our $host = $_[0];
	our $community = $_[1];

	# OID List
	our $ifName_OID = '.1.3.6.1.2.1.31.1.1.1.1';
	our $ifAdminStatus_OID = '.1.3.6.1.2.1.2.2.1.7';

	# Arrays of data
	my %ifIndexData;
	my %ifNameData;

	# Establish session
	my ($session,$error) = Net::SNMP->session (
	     -hostname => $host,
	     -community => $community,
	);

	# Get a listing of all port indexes and their current state
	my $portIndexStatus = $session->get_table(-baseoid => $ifAdminStatus_OID);
	while (my($ifIndex,$portState) = each(%$portIndexStatus)) {
		$ifIndex =~ s/$ifAdminStatus_OID\.//;
		if($ifIndex =~ m/\d{5}/) {
			$ifIndexData{$ifIndex} = $portState;
		}
	}

	# Get a list of all port names?
	my $portNames = $session->get_table(-baseoid => $ifName_OID);
	while (my($ifIndex,$ifName) = each(%$portNames)) {
		$ifIndex =~ s/$ifName_OID\.//;
		if($ifIndex =~ m/\d{5}/) {
			$ifNameData{$ifIndex} = $ifName;
		}
	}

	# Map the data
	while (my ($ifIndex,$ifName) = each(%ifNameData)) {
		my %row;
		$row{port} = $ifName;
		$row{state} = $ifIndexData{$ifIndex};
		return_next(\%row);
	}

	# Close session
	$session->close();
	return;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_network_switchview_admin_state"(inet,text) IS 'Get the current administrative state of the switchports on a system';

/* API - get_network_switchport_types */
CREATE OR REPLACE FUNCTION "api"."get_network_switchport_types"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "type" FROM "network"."switchport_types" ORDER BY "type" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_switchport_types"() IS 'Get a list of all network switchport types';

/* API - get_network_switchports */
CREATE OR REPLACE FUNCTION "api"."get_network_switchports"(input_system_name text) RETURNS SETOF "network"."switchport_data" AS $$
	BEGIN
		RETURN QUERY (
		SELECT "network"."switchports"."system_name",
			"network"."switchports"."port_name",
			"network"."switchports"."type",
			"network"."switchports"."description",
			"network"."switchport_states"."port_state",
			"network"."switchport_states"."admin_state",
			"network"."switchports"."date_created",
			"network"."switchports"."date_modified",
			"network"."switchports"."last_modifier"
		FROM "network"."switchports"
		LEFT JOIN "network"."switchport_states" 
		ON "network"."switchports"."port_name" = "network"."switchport_states"."port_name" 
		WHERE "network"."switchports"."system_name" = input_system_name
		ORDER BY substring("network"."switchports"."port_name" from E'[0-9]+$')::integer ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_switchports"(text) IS 'Get all switchport data for a system';

/* API - get_network_switchview_settings */
CREATE OR REPLACE FUNCTION "api"."get_network_switchview_settings"(input_system_name text) RETURNS SETOF "network"."switchview_setting_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "snmp_ro_community","snmp_rw_community","enable" FROM "network"."switchview" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_switchview_settings"(text) IS 'Get switchview settings for a system';

/* API - get_network_switchport_macs */ 
CREATE OR REPLACE FUNCTION "api"."get_network_switchport_macs"(input_system_name text, input_port_name text) RETURNS SETOF MACADDR AS $$
	BEGIN
		RETURN QUERY (SELECT DISTINCT "mac" FROM "network"."switchport_macs" WHERE "system_name" = input_system_name AND "port_name" = input_port_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_switchport_macs"(text, text) IS 'Get a list of all mac addresses on a switchport';