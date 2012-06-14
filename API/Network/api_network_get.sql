CREATE OR REPLACE FUNCTION "api"."get_switchview_vlans"(inet, text) RETURNS SETOF INTEGER AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $vtpVlanState = ".1.3.6.1.4.1.9.9.46.1.3.1.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $vlanList = $session->get_table(-baseoid => $vtpVlanState);

	while ( my ($vlan, $vtpState) = each(%$vlanList)) {
		$vlan =~ s/$vtpVlanState\.1\.//;
		return_next($vlan);
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_vlans"(inet, text) IS 'Get a list of all vlans configured on a network device';

CREATE OR REPLACE FUNCTION "api"."get_switchview_bridgeportid"(inet, text, integer) RETURNS TABLE("camportinstanceid" TEXT, "bridgeportid" INTEGER) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $dot1dTpFdbPort = ".1.3.6.1.2.1.17.4.3.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my $vlan = shift(@_) or die "Unable to get VLANID";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community\@$vlan",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $bridgePortList = $session->get_table(-baseoid => $dot1dTpFdbPort);

	# Do something for each item of the list
	while ( my ($camPortInstanceID, $bridgePortID) = each(%$bridgePortList)) {
		$camPortInstanceID =~ s/$dot1dTpFdbPort//;
		return_next({camportinstanceid=>$camPortInstanceID, bridgeportid=>$bridgePortID});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_bridgeportid"(inet, text, integer) IS 'Get a mapping of CAM instanceIDs and bridgeIDs';

CREATE OR REPLACE FUNCTION "api"."get_switchview_cam"(inet, text, integer) RETURNS TABLE ("camportinstanceid" TEXT, "mac" MACADDR) AS $$
	#!/usr/bin/perl -w 

	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $dot1dTpFdbAddress = ".1.3.6.1.2.1.17.4.3.1.1";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my $vlan = shift(@_) or die "Unable to get VLANID";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community\@$vlan",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $camList = $session->get_table(-baseoid => $dot1dTpFdbAddress);

	# Do something for each item of the list
	while ( my ($camPortInstanceID, $macaddr) = each(%$camList)) {
		$camPortInstanceID =~ s/$dot1dTpFdbAddress//;
		
		# Sometimes there are non-valid MAC addresses in the CAM.
		if($macaddr =~ m/[0-9a-fA-F]{12}/) {
			$macaddr = format_raw_mac($macaddr);
			#print "InstanceID: $camPortInstanceID - MAC: $macaddr\n";
			return_next({camportinstanceid=>$camPortInstanceID,mac=>$macaddr});
		}
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;

	# Subroutine to format a MAC address to something nice
	sub format_raw_mac() {
		my $mac = $_[0];
		# Get rid of the hex identifier
		$mac =~ s/^0x//;

		# Make groups of two characters
		$mac =~ s/(.{2})/$1:/gg;

		# Remove the trailing : left by the previous function
		$mac =~ s/\:$//;

		# Spit it back out
		return $mac;
	}

$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_cam"(inet, text, integer) IS 'Get the CAM/MAC table from a device on a certain VLAN';

CREATE OR REPLACE FUNCTION "api"."get_switchview_portindex"(inet, text, integer) RETURNS TABLE("bridgeportid" INTEGER, "ifindex" INTEGER) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $dot1dBasePortIfIndex = ".1.3.6.1.2.1.17.1.4.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my $vlan = shift(@_) or die "Unable to get VLANID";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community\@$vlan",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $portIndexList = $session->get_table(-baseoid => $dot1dBasePortIfIndex);

	# Do something for each item of the list
	while ( my ($bridgePortID, $portIndex) = each(%$portIndexList)) {
		$bridgePortID =~ s/$dot1dBasePortIfIndex\.//;
		return_next({bridgeportid=>$bridgePortID, ifindex=>$portIndex});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;

$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_portindex"(inet, text, integer) IS 'Get a mapping of port indexes to bridge indexes';

CREATE OR REPLACE FUNCTION "api"."get_switchview_portnames"(inet, text, integer) RETURNS TABLE("ifindex" INTEGER, "ifname" TEXT) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifName = ".1.3.6.1.2.1.31.1.1.1.1";
	#my $ifDesc = ".1.3.6.1.2.1.2.2.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my $vlan = shift(@_) or die "Unable to get VLANID";

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community\@$vlan",
	);

	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

	# Get a list of all data
	my $portNameList = $session->get_table(-baseoid => $ifName);

	# Do something for each item of the list
	while ( my ($portIndex, $portName) = each(%$portNameList)) {
		$portIndex =~ s/$ifName\.//;
		return_next({ifindex=>$portIndex, ifname=>$portName});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_portnames"(inet, text, integer) IS 'Map ifindexes to port names';

CREATE OR REPLACE FUNCTION "api"."get_switchview_cam"(input_host inet, input_community text) RETURNS SETOF "network"."cam" AS $$
	DECLARE
		Vlans RECORD;
		CamData RECORD;
	BEGIN
		FOR Vlans IN (SELECT get_switchview_vlans FROM api.get_switchview_vlans(input_host, input_community) ORDER BY get_switchview_vlans) LOOP
			FOR CamData IN (
				SELECT mac,ifname,Vlans.get_switchview_vlans FROM api.get_switchview_cam(input_host,input_community,vlans.get_switchview_vlans) AS "cam"
				JOIN api.get_switchview_bridgeportid(input_host,input_community,vlans.get_switchview_vlans) AS "bridgeportid"
				ON bridgeportid.camportinstanceid = cam.camportinstanceid
				JOIN api.get_switchview_portindex(input_host,input_community,vlans.get_switchview_vlans) AS "portindex"
				ON bridgeportid.bridgeportid = portindex.bridgeportid
				JOIN api.get_switchview_portnames(input_host,input_community,vlans.get_switchview_vlans) AS "portnames"
				ON portindex.ifindex = portnames.ifindex
			) LOOP
				RETURN NEXT CamData;
			END LOOP;
		END LOOP;
		RETURN;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_switchview_cam"(inet, text) IS 'Get all CAM data from a particular device';

-------------------------------------------------------------------------------
---- EVERYTHING ELSE IN THIS IS OLD CODE AND WILL PROBABLY BE REMOVED SOON ----
-------------------------------------------------------------------------------

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
	
	# Check that it did not error
	if (!defined($session)) {
		die $error;
	}

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
		RETURN QUERY (SELECT DISTINCT "mac" FROM "network"."switchport_macs" WHERE "system_name" = input_system_name AND "port_name" = input_port_name ORDER BY "mac");
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
		ORDER BY "network"."switchports"."port_name"
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

CREATE OR REPLACE FUNCTION "api"."get_snmp_rw"(input_system_name text) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "snmp_rw_community" FROM "network"."switchview" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_snmp_rw"(text) IS 'Get the name of the RW community of a system';

CREATE OR REPLACE FUNCTION "api"."get_snmp_ro"(input_system_name text) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "snmp_ro_community" FROM "network"."switchview" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_snmp_ro"(text) IS 'Get the name of the RO community of a system';

/* API - get_network_switchport_history */
CREATE OR REPLACE FUNCTION "api"."get_network_switchport_history"(input_system_name text, input_port_name text) RETURNS TABLE("mac" macaddr, "time" timestamp) AS $$
	BEGIN
		RETURN QUERY (SELECT distinct("network"."switchport_history"."mac"),"network"."switchport_history"."time" 
		FROM "network"."switchport_history" WHERE "port_name" = input_port_name AND "system_name" = input_system_name
		ORDER BY "time" DESC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_switchport_history"(text,text) IS 'Get the MAC address history of a port';