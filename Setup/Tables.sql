CREATE TABLE "dhcp"."class_options"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"class" TEXT NOT NULL,
CONSTRAINT "class_options_pkey" PRIMARY KEY ("option","value","class")
)
WITHOUT OIDS;

CREATE TABLE "ip"."range_uses"(
"use" VARCHAR(4) NOT NULL,
"comment" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "range_uses_pkey" PRIMARY KEY ("use")
)
WITHOUT OIDS;

CREATE TABLE "systems"."device_types"(
"type" TEXT NOT NULL,
"family" TEXT NOT NULL,
CONSTRAINT "device_types_pkey" PRIMARY KEY ("type"),
CONSTRAINT "device_types_family_check" CHECK ("family" ~ '^PC|Network$')
)
WITHOUT OIDS;

CREATE TABLE "ip"."subnets"(
"subnet" CIDR NOT NULL,
"comment" TEXT,
"autogen" BOOLEAN NOT NULL DEFAULT TRUE,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"name" TEXT NOT NULL,
"owner" TEXT NOT NULL,
"zone" TEXT DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
"dhcp_enable" BOOLEAN NOT NULL DEFAULT FALSE,
"datacenter" TEXT NOT NULL DEFAULT api.get_site_configuration('DEFAULT_DATACENTER'),
"vlan" INTEGER NOT NULL,
CONSTRAINT "subnets_pkey" PRIMARY KEY ("subnet")
)
WITHOUT OIDS;

CREATE TABLE "ip"."ranges"(
"first_ip" INET NOT NULL,
"last_ip" INET NOT NULL,
"comment" TEXT,
"use" VARCHAR(4) NOT NULL,
"datacenter" TEXT NOT NULL DEFAULT api.get_site_configuration('DEFAULT_DATACENTER'),
"zone" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"name" TEXT NOT NULL,
"subnet" CIDR,
"class" TEXT,
CONSTRAINT "ranges_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "dns"."ns"(
"zone" TEXT NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"type" TEXT NOT NULL DEFAULT 'NS',
"nameserver" TEXT NOT NULL,
"address" INET NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "ns_pkey" PRIMARY KEY ("zone","nameserver")
)
WITHOUT OIDS;

CREATE TABLE "systems"."os_family"(
"family" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "os_family_pkey" PRIMARY KEY ("family")
)
WITHOUT OIDS;

CREATE TABLE "systems"."interface_addresses"(
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"comment" TEXT,
"address" INET NOT NULL,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"config" TEXT NOT NULL,
"family" INTEGER NOT NULL,
"isprimary" BOOLEAN NOT NULL,
"renew_date" DATE NOT NULL DEFAULT date((('now'::text)::date + (api.get_site_configuration('DEFAULT_RENEW_INTERVAL'::text))::interval)),
"mac" MACADDR,
"class" TEXT,
CONSTRAINT "interface_addresses_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."classes"(
"class" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "classes_pkey" PRIMARY KEY ("class")
)
WITHOUT OIDS;

CREATE TABLE "systems"."systems"(
"system_name" TEXT NOT NULL,
"owner" TEXT NOT NULL,
"group" TEXT NOT NULL DEFAULT api.get_site_configuration('DEFAULT_LOCAL_USER_GROUP'),
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"type" TEXT,
"os_name" TEXT,
"last_modifier" TEXT NOT NULL,
"platform_name" TEXT NOT NULL,
"asset" TEXT,
"datacenter" TEXT NOT NULL DEFAULT api.get_site_configuration('DEFAULT_DATACENTER'),
CONSTRAINT "systems_pkey" PRIMARY KEY ("system_name")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."subnet_options"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"subnet" CIDR NOT NULL,
CONSTRAINT "subnet_options_pkey" PRIMARY KEY ("option","value","subnet")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."config_types"(
"config" TEXT NOT NULL,
"comment" TEXT,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"family" INTEGER NOT NULL,
CONSTRAINT "config_types_pkey" PRIMARY KEY ("config")
)
WITHOUT OIDS;

CREATE TABLE "systems"."os"(
"name" TEXT NOT NULL,
"family" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "os_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "dns"."cname"(
"alias" VARCHAR(63) NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"owner" TEXT NOT NULL,
"type" TEXT NOT NULL DEFAULT 'CNAME',
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
CONSTRAINT "cname_pkey" PRIMARY KEY ("alias","hostname","address","zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."srv"(
"alias" VARCHAR(63) NOT NULL,
"priority" INTEGER NOT NULL DEFAULT 0,
"weight" INTEGER NOT NULL DEFAULT 0,
"port" INTEGER NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"owner" TEXT NOT NULL,
"type" TEXT NOT NULL DEFAULT 'SRV',
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
CONSTRAINT "srv_pkey" PRIMARY KEY ("alias","hostname","address","zone","priority","weight","port")
)
WITHOUT OIDS;

CREATE TABLE "dns"."mx"(
"preference" INTEGER NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"owner" TEXT NOT NULL,
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
"type" TEXT NOT NULL,
CONSTRAINT "mx_pkey" PRIMARY KEY ("hostname","address","zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."zones"(
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
"forward" BOOLEAN NOT NULL,
"keyname" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"owner" TEXT NOT NULL,
"comment" TEXT,
"shared" BOOLEAN NOT NULL DEFAULT FALSE,
"ddns" BOOLEAN NOT NULL DEFAULT FALSE,
CONSTRAINT "zones_pkey" PRIMARY KEY ("zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."soa"(
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
"nameserver" TEXT NOT NULL DEFAULT 'ns1.'||api.get_site_configuration('DNS_DEFAULT_ZONE'),
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"contact" TEXT NOT NULL DEFAULT 'hostmaster.'||api.get_site_configuration('DNS_DEFAULT_ZONE'),
"serial" TEXT NOT NULL DEFAULT '0000000000',
"refresh" INTEGER NOT NULL DEFAULT 3600,
"retry" INTEGER NOT NULL DEFAULT 600,
"expire" INTEGER NOT NULL DEFAULT 172800,
"minimum" INTEGER NOT NULL DEFAULT 43200,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "soa_pkey" PRIMARY KEY ("zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."keys"(
"keyname" TEXT NOT NULL,
"key" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"comment" TEXT,
"owner" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "keys_pkey" PRIMARY KEY ("keyname")
)
WITHOUT OIDS;

CREATE TABLE "ip"."addresses"(
"address" INET NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"owner" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "addresses_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dns"."txt"(
"text" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"type" TEXT NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"owner" TEXT NOT NULL,
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
CONSTRAINT "txt_pkey" PRIMARY KEY ("text","hostname","address","zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."zone_txt"(
"text" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"hostname" VARCHAR(63),
"type" TEXT NOT NULL DEFAULT 'TXT',
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
"address" INET DEFAULT '0.0.0.0'
)
WITHOUT OIDS;

CREATE TABLE "management"."log_master"(
"timestamp" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"user" TEXT NOT NULL,
"message" TEXT,
"source" TEXT NOT NULL,
"severity" TEXT NOT NULL
)
WITHOUT OIDS;

CREATE TABLE "dns"."a"(
"hostname" VARCHAR(63) NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"address" INET NOT NULL,
"type" TEXT NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"owner" TEXT NOT NULL,
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
"reverse" BOOLEAN NOT NULL DEFAULT TRUE,
CONSTRAINT "a_pkey" PRIMARY KEY ("hostname","address","zone"),
CONSTRAINT "dns_a_type_check" CHECK ("type" ~ '^A|AAAA$'),
CONSTRAINT "dns_a_hostname" CHECK ("hostname" !~ '_')
)
WITHOUT OIDS;

CREATE TABLE "management"."output"(
"output_id" INTEGER NOT NULL DEFAULT NEXTVAL('"management"."output_id_seq"'),
"value" TEXT,
"file" TEXT,
"timestamp" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
CONSTRAINT "output_pkey" PRIMARY KEY ("output_id")
)
WITHOUT OIDS;

CREATE TABLE "systems"."interfaces"(
"mac" MACADDR NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"system_name" TEXT,
"name" TEXT NOT NULL,
CONSTRAINT "interfaces_pkey" PRIMARY KEY ("mac")
)
WITHOUT OIDS;

CREATE TABLE "management"."configuration"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "configuration_pkey" PRIMARY KEY ("option")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."range_options"(
"option" TEXT NOT NULL,
"name" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"value" TEXT NOT NULL,
CONSTRAINT "range_options_pkey" PRIMARY KEY ("name","option")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."global_options"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "global_options_pkey" PRIMARY KEY ("option")
)
WITHOUT OIDS;

CREATE TABLE "dns"."types"(
"type" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "types_pkey" PRIMARY KEY ("type")
)
WITHOUT OIDS;

CREATE TABLE "dns"."zone_a"(
"hostname" TEXT DEFAULT NULL,
"zone" TEXT NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_ZONE'),
"type" TEXT NOT NULL,
"address" INET NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT api.get_site_configuration('DNS_DEFAULT_TTL')::integer,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "dns_zone_a_pkey" PRIMARY KEY ("zone","type"),
CONSTRAINT "dns_zone_a_type_check" CHECK ("type" ~ '^A|AAAA$')
)
WITHOUT OIDS;

CREATE TABLE "network"."snmp"(
"system_name" TEXT NOT NULL,
"address" INET NOT NULL,
"ro_community" TEXT,
"rw_community" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "network_snmp_pkey" PRIMARY KEY ("system_name")
)
WITHOUT OIDS;

CREATE TABLE "systems"."architectures"(
"architecture" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "systems_architecture_pkey" PRIMARY KEY ("architecture")
)
WITHOUT OIDS;

COMMENT ON TABLE "systems"."architectures" IS 'The CPU architecture of a platform';

CREATE TABLE "systems"."platforms"(
"platform_name" TEXT NOT NULL,
"architecture" TEXT NOT NULL,
"disk" TEXT NOT NULL,
"cpu" TEXT NOT NULL,
"memory" INTEGER NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "systems_platforms_pkey" PRIMARY KEY ("platform_name")
)
WITHOUT OIDS;

COMMENT ON TABLE "systems"."platforms" IS 'Platform templates of a system';

CREATE TABLE "systems"."datacenters"(
"datacenter" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "systems_datacenter_pkey" PRIMARY KEY ("datacenter")
)
WITHOUT OIDS;

COMMENT ON TABLE "systems"."datacenters" IS 'Regional locations for systems';

CREATE TABLE "systems"."availability_zones"(
"datacenter" TEXT NOT NULL,
"zone" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "systems_az_pkey" PRIMARY KEY ("datacenter","zone")
)
WITHOUT OIDS;

COMMENT ON TABLE "systems"."availability_zones" IS 'Availability zones within datacenters';

CREATE TABLE "management"."groups"(
"group" TEXT NOT NULL,
"comment" TEXT,
"privilege" TEXT NOT NULL DEFAULT "USER",
"renew_interval" INTERVAL NOT NULL DEFAULT api.get_site_configuration('DEFAULT_RENEW_INTERVAL')::interval,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "management_group_privilege_check" CHECK ("privilege" ~* '^ADMIN|USER|PROGRAM$'),
CONSTRAINT "management_groups_pkey" PRIMARY KEY ("group")
)
WITHOUT OIDS;

COMMENT ON TABLE "management"."groups" IS 'Groups of users with different privilege levels';

CREATE TABLE "management"."group_members"(
"group" TEXT NOT NULL,
"user" TEXT NOT NULL,
"privilege" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "management_group_member_privilege_check" CHECK ("privilege" ~* '^ADMIN|USER|PROGRAM$'),
CONSTRAINT "management_group_members_pkey" PRIMARY KEY ("group","user")
)
WITHOUT OIDS;

COMMENT ON TABLE "management"."group_members" IS 'Map usernames to groups';

COMMENT ON TABLE "network"."snmp" IS 'SNMP community settings for network systems';

CREATE TABLE "network"."cam_cache"(
"system_name" TEXT NOT NULL,
"mac" MACADDR NOT NULL,
"ifname" TEXT NOT NULL,
"vlan" INTEGER NOT NULL,
"timestamp" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0)
)
WITHOUT OIDS;
COMMENT ON TABLE "network"."cam_cache" IS 'Cache switch data for port mappings';

COMMENT ON TABLE "dns"."zone_a" IS 'Zone address records';

COMMENT ON TABLE "dhcp"."class_options" IS 'Options to apply to a specific DHCP class (like Netbooting)';

COMMENT ON TABLE "ip"."range_uses" IS 'Ranges are intended for a specific purpose.';

COMMENT ON TABLE "systems"."device_types" IS 'Computers are different than switches and routers, as they appear in the network overview.';

COMMENT ON TABLE "ip"."subnets" IS 'Subnets for which this application has control';

COMMENT ON TABLE "ip"."ranges" IS 'Ranges of addresses can be reserved for specific purposes (Autoreg, Dynamics, etc)';

COMMENT ON TABLE "dns"."ns" IS 'Nameservers (to be inserted as NS records)';

COMMENT ON TABLE "systems"."os_family" IS 'General classification for operating systems.';

COMMENT ON TABLE "systems"."interface_addresses" IS 'Interfaces are assigned IP addresses based on certain rules. If DHCP is being used, then a class may be specified.';

COMMENT ON TABLE "dhcp"."classes" IS 'DHCP classes allow configuration of hosts in certain ways';

COMMENT ON TABLE "systems"."systems" IS 'Systems are devices that connect to the network.';

COMMENT ON TABLE "dhcp"."subnet_options" IS 'Options to apply to an entire subnet';

COMMENT ON TABLE "dhcp"."config_types" IS 'List of ways to configure your address';

COMMENT ON TABLE "systems"."os" IS 'Track what primary operating systems are in use on the network.';

COMMENT ON TABLE "dns"."cname" IS 'CNAME records';

COMMENT ON TABLE "dns"."srv" IS 'SRV records';

COMMENT ON TABLE "dns"."mx" IS 'Mail servers (MX records)';

COMMENT ON TABLE "dns"."zones" IS 'Authoritative DNS zones';

COMMENT ON TABLE "dns"."soa" IS 'SOA records for DNS zones';

COMMENT ON TABLE "dns"."keys" IS 'Zone keys';

COMMENT ON TABLE "ip"."addresses" IS 'Master list of all controlled addresses in the application';

COMMENT ON TABLE "dns"."txt" IS 'TXT records for hosts';

COMMENT ON TABLE "dns"."zone_txt" IS 'TXT records for zones';

COMMENT ON TABLE "management"."log_master" IS 'Record every single transaction that occurs in this application.';

COMMENT ON TABLE "management"."output" IS 'Destination of the output functions rather than write a file to disk.';

COMMENT ON TABLE "systems"."interfaces" IS 'Systems have interfaces that connect to the network. This corresponds to your physical hardware.';

COMMENT ON TABLE "dns"."types" IS 'All DNS record types';

COMMENT ON TABLE "dns"."a" IS 'DNS forward address records';

COMMENT ON TABLE "dhcp"."global_options" IS 'Global DHCP options that affect all objects';

COMMENT ON TABLE "dhcp"."range_options" IS 'DHCP options that apply to a specific range';

COMMENT ON TABLE "management"."configuration" IS 'Site specific configuration directives';

CREATE TABLE "network"."vlans" (
"datacenter" TEXT NOT NULL,
"vlan" INTEGER NOT NULL,
"name" TEXT NOT NULL,
"comment" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT localtimestamp(0),
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "network_vlans_pkey" PRIMARY KEY ("datacenter","vlan")
)
WITHOUT OIDS;
COMMENT ON TABLE "network"."vlans" IS 'VLANs in the organization';
