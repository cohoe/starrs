CREATE OR REPLACE FUNCTION "api"."get_switchport_operstatus"(text, integer, text, text, text, text, text) RETURNS BOOLEAN AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings('redefine');

	our $host = shift;
	our $ifIndex = shift;
	our $user = shift;
	our $password = shift;
	our $authenctype = shift;
	our $privpass = shift;
	our $privenctype = shift;

	my $OID_ifOperStatus = ".1.3.6.1.2.1.2.2.1.8";

	my ($session, $error) = Net::SNMP->session(
		-hostname		=> $host,
		-version		=> 'snmpv3',
		-username		=> $user,
		-authprotocol	=> $authenctype,
		-authpassword	=> $password,
		-privprotocol	=> $privenctype,
		-privpassword	=> $privpass,
	);

	if (!defined $session) {
		die $error;
	}

	our $result = $session->get_request(
		-varbindlist => [ "$OID_ifOperStatus.$ifIndex" ]
	);

	if (!defined $result) {
		die $session->error();
	}

	my $retVal = $result->{"$OID_ifOperStatus.$ifIndex"};

	if($retVal !~ m/[0-2]/) { die $retVal; }
	if($retVal-1 == 0) {
		# Then its up
		$retVal = 1;
	} else {
		# Then its down
		$retVal = 0;
	}
	
	$session->close();

	return $retVal;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchport_operstatus"(text, integer, text, text, text, text, text) IS 'Get the operationsl state of a specific switchport';

CREATE OR REPLACE FUNCTION "api"."get_switchport_adminstatus"(text, integer, text, text, text, text, text) RETURNS BOOLEAN AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings('redefine');

	our $host = shift;
	our $ifIndex = shift;
	our $user = shift;
	our $password = shift;
	our $authenctype = shift;
	our $privpass = shift;
	our $privenctype = shift;

	my $OID_ifAdminStatus = ".1.3.6.1.2.1.2.2.1.7";

	my ($session, $error) = Net::SNMP->session(
		-hostname		=> $host,
		-version		=> 'snmpv3',
		-username		=> $user,
		-authprotocol	=> $authenctype,
		-authpassword	=> $password,
		-privprotocol	=> $privenctype,
		-privpassword	=> $privpass,
	);

	if (!defined $session) {
		die $error;
	}

	our $result = $session->get_request(
		-varbindlist => [ "$OID_ifAdminStatus.$ifIndex" ]
	);

	if (!defined $result) {
		die $session->error();
	}

	my $retVal = $result->{"$OID_ifAdminStatus.$ifIndex"};

	if($retVal !~ m/[0-2]/) { die $retVal; }
	if($retVal-1 == 0) {
		# Then its up
		$retVal = 1;
	} else {
		# Then its down
		$retVal = 0;
	}
	
	$session->close();

	return $retVal;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchport_adminstatus"(text, integer, text, text, text, text, text) IS 'Get the administrative state of a specific switchport';

CREATE OR REPLACE FUNCTION "api"."get_switchport_vlan"(text, integer, text, text, text, text, text) RETURNS INTEGER AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings('redefine');

	our $host = shift;
	our $ifIndex = shift;
	our $user = shift;
	our $password = shift;
	our $authenctype = shift;
	our $privpass = shift;
	our $privenctype = shift;

	my $OID_vmVlan = "1.3.6.1.4.1.9.9.68.1.2.2.1.2";

	my ($session, $error) = Net::SNMP->session(
		-hostname		=> $host,
		-version		=> 'snmpv3',
		-username		=> $user,
		-authprotocol	=> $authenctype,
		-authpassword	=> $password,
		-privprotocol	=> $privenctype,
		-privpassword	=> $privpass,
	);

	if (!defined $session) {
		die $error;
	}

	our $result = $session->get_request(
		-varbindlist => [ "$OID_vmVlan.$ifIndex" ]
	);

	if (!defined $result) {
		die $session->error();
	}

	my $retVal = $result->{"$OID_vmVlan.$ifIndex"};
	if($retVal !~ m/[0-9]+/) { die $retVal; }

	$session->close();

	return $retVal;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchport_vlan"(text, integer, text, text, text, text, text) IS 'Get the VLAN of a specific switchport';

CREATE OR REPLACE FUNCTION "api"."get_switchport_alias"(text, integer, text, text, text, text, text) RETURNS TEXT AS $$
	use strict;
	use warnings;
	use Net::SNMP;
	no warnings('redefine');

	our $host = shift;
	our $ifIndex = shift;
	our $user = shift;
	our $password = shift;
	our $authenctype = shift;
	our $privpass = shift;
	our $privenctype = shift;

	my $OID_ifAlias = "1.3.6.1.2.1.31.1.1.1.18";

	my ($session, $error) = Net::SNMP->session(
		-hostname		=> $host,
		-version		=> 'snmpv3',
		-username		=> $user,
		-authprotocol	=> $authenctype,
		-authpassword	=> $password,
		-privprotocol	=> $privenctype,
		-privpassword	=> $privpass,
	);

	if (!defined $session) {
		die $error;
	}

	our $result = $session->get_request(
		-varbindlist => [ "$OID_ifAlias.$ifIndex" ]
	);

	if (!defined $result) {
		die $session->error();
	}

	my $retVal = $result->{"$OID_ifAlias.$ifIndex"};
	if($retVal eq "noSuchInstance" ) { die $retVal; }

	$session->close();

	return $retVal;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."get_switchport_alias"(text, integer, text, text, text, text, text) IS 'Get the alias of a specific switchport';


-- vim: set filetype=perl:

-- vim: set filetype=perl:
