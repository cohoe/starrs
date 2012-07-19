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

	# Subroutine to format a MAC address to something nice
	sub format_raw_mac {
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

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_names"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifname" TEXT, "ifdesc" TEXT) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifName = ".1.3.6.1.2.1.31.1.1.1.1";
	my $ifDesc = ".1.3.6.1.2.1.2.2.1.2";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";
	my %ports;

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
	my $portNameList = $session->get_table(-baseoid => $ifName);
	my $portDescList = $session->get_table(-baseoid => $ifDesc);

	# Do something for each item of the list
	while ( my ($portIndex, $portName) = each(%$portNameList)) {
		$portIndex =~ s/$ifName\.//;
		$ports{$portIndex}{'ifName'} = $portName;
	}
	while ( my ($portIndex, $portDesc) = each(%$portDescList)) {
		$portIndex =~ s/$ifDesc\.//;
		$ports{$portIndex}{'ifDesc'} = $portDesc;
	}
	foreach my $key (keys(%ports)) {
		return_next({ifindex=>$key, ifname=>$ports{$key}{'ifName'}, ifdesc=>$ports{$key}{'ifDesc'}});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_names"(inet, text) IS 'Map ifindexes to port names';

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_descriptions"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifalias" TEXT) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifAlias = "1.3.6.1.2.1.31.1.1.1.18";

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
	my $portAliases = $session->get_table(-baseoid => $ifAlias);

	# Do something for each item of the list
	while ( my ($portIndex, $portAlias) = each(%$portAliases)) {
		$portIndex =~ s/$ifAlias\.//;
		return_next({ifindex=>$portIndex, ifalias=>$portAlias});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_descriptions"(inet, text) IS 'Map ifindexes to port descriptions (or aliases in Cisco-land)';

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_operstatus"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifoperstatus" BOOLEAN) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifOperStatus = ".1.3.6.1.2.1.2.2.1.8";

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
	my $portStates = $session->get_table(-baseoid => $ifOperStatus);

	# Do something for each item of the list
	while ( my ($portIndex, $portState) = each(%$portStates)) {
		$portIndex =~ s/$ifOperStatus\.//;
		if($portState-1 == 0) {
			# Then its up
			$portState = 1;
		}
		else {
			# Then its down
			$portState = 0;
		}
		return_next({ifindex=>$portIndex, ifoperstatus=>$portState});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_operstatus"(inet, text) IS 'Map ifindexes to port operational status';

CREATE OR REPLACE FUNCTION "api"."get_switchview_port_adminstatus"(inet, text) RETURNS TABLE("ifindex" INTEGER, "ifadminstatus" BOOLEAN) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;

	# Define OIDs
	my $ifAdminStatus = ".1.3.6.1.2.1.2.2.1.7";

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
	my $portStates = $session->get_table(-baseoid => $ifAdminStatus);

	# Do something for each item of the list
	while ( my ($portIndex, $portState) = each(%$portStates)) {
		$portIndex =~ s/$ifAdminStatus\.//;
		if($portState-1 == 0) {
			# Then its up
			$portState = 1;
		}
		else {
			# Then its down
			$portState = 0;
		}
		return_next({ifindex=>$portIndex, ifadminstatus=>$portState});
	}

	# Gracefully disconnect
	$session->close();
	
	# Return
	return undef;
	
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_port_adminstatus"(inet, text) IS 'Map ifindexes to port administrative status';

CREATE OR REPLACE FUNCTION "api"."get_switchview_device_cam"(input_system text) RETURNS SETOF "network"."cam" AS $$
	DECLARE
		Vlans RECORD;
		CamData RECORD;
		input_host INET;
		input_community TEXT;
	BEGIN
		SELECT get_system_primary_address::inet INTO input_host FROM api.get_system_primary_address(input_system);
		IF input_host IS NULL THEN
			RAISE EXCEPTION 'Unable to find address for system %',input_system;
		END IF;
		SELECT ro_community INTO input_community FROM api.get_network_snmp(input_system);
		IF input_community IS NULL THEN
			RAISE EXCEPTION 'Unable to find SNMP settings for system %',input_system;
		END IF;

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
COMMENT ON FUNCTION "api"."get_switchview_device_cam"(text) IS 'Get all CAM data from a particular device';

CREATE OR REPLACE FUNCTION "api"."get_switchview_neighbors"(inet, text) RETURNS TABLE("localifIndex" INTEGER, "remoteifdesc" TEXT, "remotehostname" TEXT) AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	use Socket;
	use 5.10.0;

	# Define OIDs
	my $cdpCacheEntry = "1.3.6.1.4.1.9.9.23.1.2.1.1";
	my $cdpCacheIfIndex = "1";
	my $cdpCacheDeviceId = "6";
	my $cdpCacheDevicePort = "7";
	my $cdpCachePlatform = "8";

	# Needed Variables
	my $hostname = shift(@_) or die "Unable to get host";
	my $community = shift(@_) or die "Unable to get READ community";

	# Data containers
	my %remoteHosts;
	my %remotePorts;
	my %remotePlatforms;
	my %localPorts;

	# Establish session
	my ($session,$error) = Net::SNMP->session (
		-hostname => "$hostname",
		-community => "$community",
	);

	# Check that it did not error
	if (!defined($session)) {
		print $error;
		exit 1;
	}

	# Get a list of all data
	my $neighborList = $session->get_table(-baseoid => $cdpCacheEntry);

	# Do something for each item of the list
	while ( my ($id, $value) = each(%$neighborList)) {
		$id=~ s/$cdpCacheEntry\.//;
		
		if($id =~ m/^($cdpCacheDeviceId|$cdpCacheDevicePort|$cdpCachePlatform|$cdpCacheIfIndex)\./) {
			my @cdpEntry = split(/\./,$id);

			given ($cdpEntry[0]) {
				when(/$cdpCacheDeviceId/) {
					$remoteHosts{$cdpEntry[1]} = $value;
				}
				when(/$cdpCacheDevicePort/) {
					$remotePorts{$cdpEntry[1]} = $value;
				}
				when(/$cdpCachePlatform/) {
					$remotePlatforms{$cdpEntry[1]} = $value;
				}
			}
		}
	}

	foreach my $ifIndex (keys(%remoteHosts)) {
		return_next({localifIndex=>$ifIndex,remoteifdesc=>$remotePorts{$ifIndex}, remotehostname=>$remoteHosts{$ifIndex}});
	}

	# Gracefully disconnect
	$session->close();

	# Return
	return undef;

$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchview_neighbors"(inet, text) IS 'Get the CDP table from a device to see who it is attached to';

CREATE OR REPLACE FUNCTION "api"."get_network_snmp"(input_system_name text) RETURNS SETOF "network"."snmp" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user THEN
				RAISE EXCEPTION 'Permission to get SNMP credentials denied: You are not owner or admin';
			END IF;
		END IF;
		
		-- Return
		RETURN QUERY (SELECT * FROM "network"."snmp" WHERE "system_name" = input_system_name);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_network_snmp"(text) IS 'Get SNMP connection information for a system';

CREATE OR REPLACE FUNCTION "api"."get_system_cam"(input_system_name text) RETURNS SETOF "network"."cam_cache" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user THEN
				RAISE EXCEPTION 'Permission to get CAM denied: You are not owner or admin';
			END IF;
		END IF;

		RETURN QUERY (SELECT * FROM "network"."cam_cache" WHERE "system_name" = input_system_name ORDER BY "ifname","vlan","mac");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_system_cam"(text) IS 'Get the latest CAM data from the cache';

CREATE OR REPLACE FUNCTION "api"."get_interface_switchports"(input_mac macaddr) RETURNS SETOF "network"."cam_cache" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "network"."cam_cache" WHERE "mac" = input_mac);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_switchports"(macaddr) IS 'Get all the cam cache entries for MAC';
