/* Database Installer
	1) Schemas
	2) Languages
	3) Sequences
*/

-- Schemas
CREATE SCHEMA "api";
COMMENT ON SCHEMA "api" IS 'All API functions that clients should use to interface with this application';

CREATE SCHEMA "dhcp";
COMMENT ON SCHEMA "dhcp" IS 'Configuration for the DHCP environment';

CREATE SCHEMA "dns";
COMMENT ON SCHEMA "dns" IS 'DNS records and configuration for BIND';

CREATE SCHEMA "firewall";
COMMENT ON SCHEMA "firewall" IS 'Firewall rules for hosts';

CREATE SCHEMA "ip";
COMMENT ON SCHEMA "ip" IS 'Network resources that are available for use';

CREATE SCHEMA "management";
COMMENT ON SCHEMA "management" IS 'Application data, logging, and output';

CREATE SCHEMA "network";
COMMENT ON SCHEMA "network" IS 'SNMP information for SwitchTalk';

CREATE SCHEMA "systems";
COMMENT ON SCHEMA "systems" IS 'User machine information';

CREATE SCHEMA "public";
COMMENT ON SCHEMA "public" IS 'All the generic crap';

-- Languages
CREATE LANGUAGE "plperl";

CREATE LANGUAGE "plperlu";

-- Sequences
CREATE SEQUENCE "management"."output_id_seq";