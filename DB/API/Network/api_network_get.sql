CREATE OR REPLACE FUNCTION "api"."get_network_switchport_view"(inet,text) RETURNS SETOF "network"."switchview_data" AS $$
	use strict;
	use warnings;
	use Data::Dumper;
	use Net::SNMP;
	no warnings 'redefine';

	# Connection information
	#our $host = $ARGV[0];
	#our $community = $ARGV[1];
	our $host = $_[0];
	our $community = $_[1];

	# OID List
	our $vlanList_OID = '.1.3.6.1.4.1.9.9.46.1.3.1.1.2';
	our $macBridge_OID = '.1.3.6.1.2.1.17.4.3.1.1';
	our $bridgeList_OID = '1.3.6.1.2.1.17.4.3.1.2';
	our $ifIndexList_OID = '.1.3.6.1.2.1.17.1.4.1.2';
	our $ifNameList_OID = '.1.3.6.1.2.1.31.1.1.1.1';
	our $ifAdminStatus_OID = '.1.3.6.1.2.1.2.2.1.7';

	our %ifNameData;
	our %ifIndexData;
	our %bridgeNumData;

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		 -hostname => $host,
		 -community => $community,
	);

	# Get a list of all VLANs
	my $vlanList = $session->get_table(-baseoid => $vlanList_OID);

	while (my($vlanID,$opCode) = each(%$vlanList)) {
		$vlanID =~ s/$vlanList_OID\.1\.//;
		my ($vlanSession,$vlanError) = Net::SNMP->session (
			-hostname => $host,
			-community => "$community\@$vlanID",
		);
		&get_names($vlanSession);
		&get_indexes($vlanSession);
		&get_bridge_nums($vlanSession);
		&get_macs($vlanSession);
		$vlanSession->close();
	}

	sub get_macs() {
		my $vlanSession = $_[0];

		my $macBridgeList = $vlanSession->get_table(-baseoid => $macBridge_OID);
		while (my($bridgeID,$mac) = each(%$macBridgeList)) {
			$bridgeID =~ s/$macBridge_OID\.//;
			$mac =~ s/^0x//;
			if($mac =~ m/[0-9a-fA-F]{12}/) {
				#print "$bridgeNumData{$bridgeID} - $mac\n";
				$mac = &format_mac($mac);
				my %row;
				$row{port} = $bridgeNumData{$bridgeID};
				$row{mac} = $mac;
				return_next(\%row);
			}
		}
	}

	sub get_bridge_nums() {
		my $vlanSession = $_[0];

		my $bridgeList = $vlanSession->get_table(-baseoid => $bridgeList_OID);
		while (my($bridgeID,$bridgeNum) = each(%$bridgeList)) {
			$bridgeID =~ s/$bridgeList_OID\.//;
			$bridgeNumData{$bridgeID} = $ifIndexData{$bridgeNum};
		}
	}

	sub get_indexes() {
		my $vlanSession = $_[0];

		my $ifIndexList = $vlanSession->get_table(-baseoid => $ifIndexList_OID);
		while (my($ifID,$ifIndex) = each(%$ifIndexList)) {
			$ifID =~ s/$ifIndexList_OID\.//;
			$ifIndexData{$ifID} = $ifNameData{$ifIndex};
		}
	}

	sub get_names() {
		my $vlanSession = $_[0];

		my $ifNameList = $vlanSession->get_table(-baseoid => $ifNameList_OID);
		while (my($ifIndex,$ifName) = each(%$ifNameList)) {
			$ifIndex =~ s/$ifNameList_OID\.//;
			if($ifIndex =~ m/\d{5}/) {
				$ifNameData{$ifIndex} = $ifName;
			}
		}
	}

	sub format_mac() {
			my $mac = $_[0];

			$mac =~ s/(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})/$1:$2:$3:$4:$5:$6/;

			return $mac;
		}

	# Close initial session
	$session->close();

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

CREATE OR REPLACE FUNCTION "api"."get_network_switchport"(input_system_name text, input_port_name text) RETURNS SETOF "network"."switchport_data" AS $$
	BEGIN
		RETURN QUERY (
		SELECT  "network"."switchports"."system_name",
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
		AND "network"."switchports"."port_name" = input_port_name
		);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_switchport"(text,text) IS 'Get a switchport';

CREATE OR REPLACE FUNCTION "api"."get_switchview_descriptions"(inet,text) RETURNS TABLE(port text, description text) AS $$
	use strict;
	use warnings;
	use Data::Dumper;
	use Net::SNMP;
	no warnings 'redefine';

	# Connection information
	#our $host = $ARGV[0];
	#our $community = $ARGV[1];
	our $host = $_[0];
	our $community = $_[1];

	# OID List
	our $ifAliasList_OID = '1.3.6.1.2.1.31.1.1.1.18';
	our $ifNameList_OID = '.1.3.6.1.2.1.31.1.1.1.1';

	# Data
	our %ifNameData;

	# Establish session
	our ($session,$error) = Net::SNMP->session (
	     -hostname => $host,
	     -community => $community,
	);

	# Get a list of all port names;
	&get_names($session);
	&get_aliases();

	sub get_names() {
		my $vlanSession = $_[0];

		my $ifNameList = $vlanSession->get_table(-baseoid => $ifNameList_OID);
		while (my($ifIndex,$ifName) = each(%$ifNameList)) {
			$ifIndex =~ s/$ifNameList_OID\.//;
			if($ifIndex =~ m/\d{5}/) {
				$ifNameData{$ifIndex} = $ifName;
			}
		}
	}

	sub get_aliases() {
		my $ifAliasList = $session->get_table(-baseoid => $ifAliasList_OID);
		while (my($ifIndex,$ifAlias) = each(%$ifAliasList)) {
			$ifIndex =~ s/$ifAliasList_OID\.//;
			if($ifIndex =~ m/\d{5}/) {
				#print "$ifNameData{$ifIndex} - $ifAlias\n";
				my %row;
				$row{port} = $ifNameData{$ifIndex};
				$row{description} = $ifAlias;
				return_next(\%row);
			}
		}
	}

	# Close initial session
	$session->close();
	return;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_descriptions"(inet,text) IS 'Get the descriptions of each port on a device';