set search_path TO "public";

/*Schema firewall*/
CREATE SCHEMA "firewall";

/*Schema systems*/
CREATE SCHEMA "systems";

/*Schema dhcp*/
CREATE SCHEMA "dhcp";

/*Schema ip*/
CREATE SCHEMA "ip";

/*Schema dns*/
CREATE SCHEMA "dns";

/*Schema management*/
CREATE SCHEMA "management";

/*Schema network*/
CREATE SCHEMA "network";

/*Schema api*/
CREATE SCHEMA "api";

/*Sequence Output ID*/
CREATE SEQUENCE "output_id_seq";

/*Language plperl*/
CREATE LANGUAGE "plperl";

/*Language plperlu*/
CREATE LANGUAGE "plperlu";

CREATE TABLE "firewall"."metahosts"(
"name" TEXT NOT NULL,
"comment" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" VARCHAR NOT NULL,
"owner" TEXT NOT NULL,
CONSTRAINT "metahosts_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."transports"(
"transport" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT,
CONSTRAINT "transports_pkey" PRIMARY KEY ("transport")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."class_options"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"class" TEXT NOT NULL,
CONSTRAINT "class_options_pkey" PRIMARY KEY ("option","value","class")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."programs"(
"port" INTEGER NOT NULL,
"name" TEXT NOT NULL,
"transport" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "programs_pkey" PRIMARY KEY ("port")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."defaults"(
"deny" BOOLEAN NOT NULL DEFAULT TRUE,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"address" INET NOT NULL,
CONSTRAINT "defaults_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."rules"(
"deny" BOOLEAN NOT NULL,
"port" INTEGER NOT NULL,
"comment" TEXT,
"transport" TEXT NOT NULL,
"address" INET NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"owner" TEXT NOT NULL,
CONSTRAINT "rules_pkey" PRIMARY KEY ("port","transport","address")
)
WITHOUT OIDS;

CREATE TABLE "ip"."range_uses"(
"use" VARCHAR(4) NOT NULL,
"comment" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "range_uses_pkey" PRIMARY KEY ("use")
)
WITHOUT OIDS;

CREATE TABLE "systems"."device_types"(
"type" TEXT NOT NULL,
"last_modifier" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
CONSTRAINT "device_types_pkey" PRIMARY KEY ("type")
)
WITHOUT OIDS;

CREATE TABLE "ip"."subnets"(
"subnet" CIDR NOT NULL,
"comment" TEXT,
"autogen" BOOLEAN NOT NULL DEFAULT TRUE,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"name" TEXT NOT NULL,
"owner" TEXT NOT NULL,
"zone" TEXT DEFAULT 'localdomain',
CONSTRAINT "subnets_pkey" PRIMARY KEY ("subnet")
)
WITHOUT OIDS;

CREATE TABLE "ip"."ranges"(
"first_ip" INET NOT NULL,
"last_ip" INET NOT NULL,
"comment" TEXT,
"use" VARCHAR(4) NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"name" TEXT NOT NULL,
"subnet" CIDR,
CONSTRAINT "ranges_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "dns"."ns"(
"isprimary" BOOLEAN NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT 3600,
"owner" TEXT NOT NULL,
"zone" TEXT NOT NULL DEFAULT 'localdomain',
CONSTRAINT "ns_pkey" PRIMARY KEY ("isprimary","hostname","address","zone")
)
WITHOUT OIDS;

CREATE TABLE "systems"."os_family"(
"family" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "os_family_pkey" PRIMARY KEY ("family")
)
WITHOUT OIDS;

CREATE TABLE "network"."switchports"(
"port_name" TEXT NOT NULL,
"description" TEXT,
"type" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"attached_mac" MACADDR,
"last_modifier" TEXT NOT NULL,
"system_name" TEXT NOT NULL,
CONSTRAINT "switchports_pkey" PRIMARY KEY ("port_name","system_name")
)
WITHOUT OIDS;

CREATE TABLE "systems"."interface_addresses"(
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"comment" TEXT,
"address" INET NOT NULL,
"last_modifier" TEXT NOT NULL,
"config" TEXT NOT NULL,
"family" VARCHAR NOT NULL,
"isprimary" VARCHAR NOT NULL,
"renew_date" DATE NOT NULL DEFAULT date(current_date + interval '1 year'),
"mac" MACADDR,
"class" TEXT,
CONSTRAINT "interface_addresses_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."classes"(
"class" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "classes_pkey" PRIMARY KEY ("class")
)
WITHOUT OIDS;

CREATE TABLE "systems"."systems"(
"system_name" TEXT NOT NULL,
"owner" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"type" TEXT,
"os_name" TEXT,
"last_modifier" TEXT NOT NULL,
"renew_date" DATE NOT NULL DEFAULT date(current_date + interval '1 year'),
CONSTRAINT "systems_pkey" PRIMARY KEY ("system_name")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."subnet_options"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"subnet" CIDR NOT NULL,
CONSTRAINT "subnet_options_pkey" PRIMARY KEY ("option","value","subnet")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."metahost_members"(
"address" INET NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"name" TEXT,
CONSTRAINT "metahost_members_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."config_types"(
"config" TEXT NOT NULL,
"comment" TEXT,
"last_modifier" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"family" VARCHAR NOT NULL,
CONSTRAINT "config_types_pkey" PRIMARY KEY ("config")
)
WITHOUT OIDS;

CREATE TABLE "systems"."os"(
"name" TEXT NOT NULL,
"default_connection_name" TEXT NOT NULL,
"family" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "os_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "dns"."pointers"(
"alias" VARCHAR(63) NOT NULL,
"extra" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"type" TEXT NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT 300,
"owner" TEXT NOT NULL,
"zone" TEXT DEFAULT 'localdomain',
CONSTRAINT "pointers_pkey" PRIMARY KEY ("alias"),
CONSTRAINT "dns_pointers_type_check" CHECK ("type" ~ '^CNAME|SRV$')
)
WITHOUT OIDS;

CREATE TABLE "network"."switchport_types"(
"type" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "switchport_types_pkey" PRIMARY KEY ("type")
)
WITHOUT OIDS;

CREATE TABLE "dns"."mx"(
"preference" INTEGER NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT 3600,
"owner" TEXT NOT NULL,
"zone" TEXT NOT NULL DEFAULT 'localdomain',
CONSTRAINT "mx_pkey" PRIMARY KEY ("hostname","address","zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."zones"(
"zone" TEXT NOT NULL DEFAULT 'localdomain',
"forward" BOOLEAN NOT NULL,
"keyname" TEXT NOT NULL,
"date_modified" TIME WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"owner" TEXT NOT NULL,
CONSTRAINT "zones_pkey" PRIMARY KEY ("zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."keys"(
"keyname" TEXT NOT NULL,
"key" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "keys_pkey" PRIMARY KEY ("keyname")
)
WITHOUT OIDS;

CREATE TABLE "ip"."addresses"(
"address" INET NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
CONSTRAINT "addresses_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dns"."txt"(
"text" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"hostname" VARCHAR(63) NOT NULL,
"address" INET NOT NULL,
"type" TEXT NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT 300,
"owner" TEXT NOT NULL,
"zone" TEXT NOT NULL DEFAULT 'localdomain',
CONSTRAINT "txt_pkey" PRIMARY KEY ("text","hostname","address","zone"),
CONSTRAINT "dns_txt_type_check" CHECK ("type" ~ '^SPF|TXT$')
)
WITHOUT OIDS;

CREATE TABLE "management"."log_master"(
"timestamp" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"user" TEXT NOT NULL,
"message" TEXT,
"source" TEXT NOT NULL,
"severity" VARCHAR NOT NULL,
CONSTRAINT "log_master_pkey" PRIMARY KEY ("timestamp")
)
WITHOUT OIDS;

CREATE TABLE "dns"."a"(
"hostname" VARCHAR(63) NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"address" INET NOT NULL,
"type" TEXT NOT NULL,
"ttl" INTEGER NOT NULL DEFAULT 300,
"owner" TEXT NOT NULL,
"zone" TEXT NOT NULL DEFAULT 'localdomain',
CONSTRAINT "a_pkey" PRIMARY KEY ("hostname","address","zone"),
CONSTRAINT "dns_a_type_check" CHECK ("type" ~ '^A|AAAA$')
)
WITHOUT OIDS;

CREATE TABLE "firewall"."systems"(
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"system_name" TEXT NOT NULL,
"subnet" CIDR NOT NULL,
"software_name" TEXT NOT NULL,
CONSTRAINT "systems_pkey" PRIMARY KEY ("system_name")
)
WITHOUT OIDS;

CREATE TABLE "management"."output"(
"output_id" VARCHAR NOT NULL DEFAULT NEXTVAL('output_id_seq'),
"value" TEXT,
"file" TEXT,
"timestamp" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
CONSTRAINT "output_pkey" PRIMARY KEY ("output_id")
)
WITHOUT OIDS;

CREATE TABLE "systems"."interfaces"(
"mac" MACADDR NOT NULL,
"name" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL,
"system_name" TEXT,
CONSTRAINT "interfaces_pkey" PRIMARY KEY ("mac")
)
WITHOUT OIDS;

CREATE TABLE "management"."privileges"(
"privilege" VARCHAR NOT NULL,
"comment" TEXT,
CONSTRAINT "privileges_pkey" PRIMARY KEY ("privilege")
)
WITHOUT OIDS;

CREATE TABLE "management"."user_privileges"(
"username" TEXT NOT NULL,
"privilege" VARCHAR NOT NULL,
"allow" VARCHAR NOT NULL DEFAULT FALSE,
CONSTRAINT "user_privileges_pkey" PRIMARY KEY ("username","privilege")
)
WITHOUT OIDS;

CREATE TABLE "management"."configuration"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
CONSTRAINT "configuration_pkey" PRIMARY KEY ("option")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."software"(
"software_name" TEXT NOT NULL,
CONSTRAINT "software_pkey" PRIMARY KEY ("software_name")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."metahost_rules"(
"deny" BOOLEAN NOT NULL DEFAULT TRUE,
"port" VARCHAR NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT 'Database Root',
"transport" TEXT NOT NULL,
"name" TEXT NOT NULL,
CONSTRAINT "metahost_rules_pkey" PRIMARY KEY ("port","transport","name")
)
WITHOUT OIDS;

COMMENT ON TABLE "firewall"."metahosts" IS 'Groups of addresses with similar firewall rules';

COMMENT ON TABLE "firewall"."transports" IS 'TCP, UDP, or Both';

COMMENT ON TABLE "dhcp"."class_options" IS 'Options to apply to a specific DHCP class (like Netbooting)';

COMMENT ON TABLE "firewall"."programs" IS 'Common programs to easily block.';

COMMENT ON TABLE "firewall"."defaults" IS 'Address default action';

COMMENT ON TABLE "firewall"."rules" IS 'The actual rules that get put into the firewall.';

COMMENT ON TABLE "ip"."range_uses" IS 'Ranges are intended for a specific purpose.';

COMMENT ON TABLE "systems"."device_types" IS 'Computers are different than switches and routers, as they appear in the network overview.';

COMMENT ON TABLE "ip"."subnets" IS 'Subnets for which this application has control';

COMMENT ON TABLE "ip"."ranges" IS 'Ranges of addresses can be reserved for specific purposes (Autoreg, Dynamics, etc)';

COMMENT ON TABLE "dns"."ns" IS 'Nameservers (to be inserted as NS records)';

COMMENT ON TABLE "systems"."os_family" IS 'General classification for operating systems.';

COMMENT ON TABLE "network"."switchports" IS 'Certain network devices have ports that can be marked with special options.';

COMMENT ON TABLE "systems"."interface_addresses" IS 'Interfaces are assigned IP addresses based on certain rules. If DHCP is being used, then a class may be specified.';

COMMENT ON TABLE "dhcp"."classes" IS 'DHCP classes allow configuration of hosts in certain ways';

COMMENT ON TABLE "systems"."systems" IS 'Systems are devices that connect to the network.';

COMMENT ON TABLE "dhcp"."subnet_options" IS 'Options to apply to an entire subnet';

COMMENT ON TABLE "firewall"."metahost_members" IS 'Map addresses to metahosts';

COMMENT ON TABLE "dhcp"."config_types" IS 'List of ways to configure your address';

COMMENT ON TABLE "systems"."os" IS 'Track what primary operating systems are in use on the network.';

COMMENT ON TABLE "dns"."pointers" IS 'CNAMEs and SRV records';

COMMENT ON TABLE "network"."switchport_types" IS 'Switchports are uplinks, trunks, access ports, etc.';

COMMENT ON TABLE "dns"."mx" IS 'Mail servers (MX records)';

COMMENT ON TABLE "dns"."zones" IS 'Authoritative DNS zones';

COMMENT ON TABLE "dns"."keys" IS 'Zone keys';

COMMENT ON TABLE "ip"."addresses" IS 'Master list of all controlled addresses in the application';

COMMENT ON TABLE "dns"."txt" IS 'TXT records for hosts';

COMMENT ON TABLE "management"."log_master" IS 'Record every single transaction that occurs in this application.';

COMMENT ON TABLE "firewall"."systems" IS 'Firewall boxes on the network';

COMMENT ON TABLE "management"."output" IS 'Destination of the output functions rather than write a file to disk.';

COMMENT ON TABLE "systems"."interfaces" IS 'Systems have interfaces that connect to the network. This corresponds to your physical hardware.';

ALTER TABLE "dhcp"."class_options" ADD CONSTRAINT "class_options_class_option_value_key" UNIQUE ("option","value","class");

COMMENT ON CONSTRAINT "class_options_class_option_value_key" ON "dhcp"."class_options" IS 'No two directives can be the same';

ALTER TABLE "ip"."ranges" ADD CONSTRAINT "ranges_first_ip_key" UNIQUE ("first_ip");

COMMENT ON CONSTRAINT "ranges_first_ip_key" ON "ip"."ranges" IS 'Unique starting IP''s';

ALTER TABLE "ip"."ranges" ADD CONSTRAINT "ranges_last_ip_key" UNIQUE ("last_ip");

COMMENT ON CONSTRAINT "ranges_last_ip_key" ON "ip"."ranges" IS 'Unique ending IP''s';

ALTER TABLE "network"."switchports" ADD CONSTRAINT "switchports_system_name_port_name_key" UNIQUE ("system_name","port_name");

COMMENT ON CONSTRAINT "switchports_system_name_port_name_key" ON "network"."switchports" IS 'Unique port names on a system';

ALTER TABLE "network"."switchports" ADD CONSTRAINT "switchports_attached_mac_key" UNIQUE ("attached_mac");

COMMENT ON CONSTRAINT "switchports_attached_mac_key" ON "network"."switchports" IS 'An attached MAC can only be on one switchport';

ALTER TABLE "dhcp"."subnet_options" ADD CONSTRAINT "subnet_option_subnet_option_value_key" UNIQUE ("option","value","subnet");

COMMENT ON CONSTRAINT "subnet_option_subnet_option_value_key" ON "dhcp"."subnet_options" IS 'No two directives can be the same';

ALTER TABLE "dns"."pointers" ADD CONSTRAINT "pointers_alias_hostname_type_key" UNIQUE ("alias","type","hostname");

COMMENT ON CONSTRAINT "pointers_alias_hostname_type_key" ON "dns"."pointers" IS 'Each record type can only have a single combination of Alias and Target';

ALTER TABLE "dns"."pointers" ADD CONSTRAINT "pointers_alias_extra_key" UNIQUE ("extra","alias");

COMMENT ON CONSTRAINT "pointers_alias_extra_key" ON "dns"."pointers" IS 'No duplicate infomation';

ALTER TABLE "dns"."mx" ADD CONSTRAINT "dns_mx_preference_zone_key" UNIQUE ("preference","zone");

COMMENT ON CONSTRAINT "dns_mx_preference_zone_key" ON "dns"."mx" IS 'No two MX servers can have the same preference in a domain';

ALTER TABLE "dns"."txt" ADD CONSTRAINT "dns_txt_hostname_type_key" UNIQUE ("hostname","type");

COMMENT ON CONSTRAINT "dns_txt_hostname_type_key" ON "dns"."txt" IS 'A hostname can have on only one of each type of TXT record';

ALTER TABLE "dns"."a" ADD CONSTRAINT "a_hostname_type_key" UNIQUE ("hostname","type");

COMMENT ON CONSTRAINT "a_hostname_type_key" ON "dns"."a" IS 'Can only have 1 of each A or AAAA';

ALTER TABLE "dns"."a" ADD CONSTRAINT "a_address_key" UNIQUE ("address");

COMMENT ON CONSTRAINT "a_address_key" ON "dns"."a" IS 'Addresses in this table must be unique';

ALTER TABLE "systems"."interfaces" ADD CONSTRAINT "systems_interfaces_name_system_name_key" UNIQUE ("system_name","name");

COMMENT ON CONSTRAINT "systems_interfaces_name_system_name_key" ON "systems"."interfaces" IS 'Unique interface names per system';

ALTER TABLE "dhcp"."class_options" ADD CONSTRAINT "fk_dhcp_class_options_class" FOREIGN KEY ("class") REFERENCES "dhcp"."classes"("class") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "firewall"."programs" ADD CONSTRAINT "fk_firewall_programs_transport" FOREIGN KEY ("transport") REFERENCES "firewall"."transports"("transport") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "firewall"."defaults" ADD CONSTRAINT "fk_defaults_address" FOREIGN KEY ("address") REFERENCES "ip"."addresses"("address") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "firewall"."rules" ADD CONSTRAINT "fk_firewall_rules_transport" FOREIGN KEY ("transport") REFERENCES "firewall"."transports"("transport") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "firewall"."rules" ADD CONSTRAINT "fk_firewall_rules_address" FOREIGN KEY ("address") REFERENCES "systems"."interface_addresses"("address") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "ip"."subnets" ADD CONSTRAINT "fk_subnets_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET DEFAULT;

ALTER TABLE "ip"."ranges" ADD CONSTRAINT "fk_ip_ranges_use" FOREIGN KEY ("use") REFERENCES "ip"."range_uses"("use") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "ip"."ranges" ADD CONSTRAINT "fk_ip_ranges_subnet" FOREIGN KEY ("subnet") REFERENCES "ip"."subnets"("subnet") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."ns" ADD CONSTRAINT "fk_ns_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "network"."switchports" ADD CONSTRAINT "fk_network_switchports_type" FOREIGN KEY ("type") REFERENCES "network"."switchport_types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "network"."switchports" ADD CONSTRAINT "fk_switchports_system_name" FOREIGN KEY ("system_name") REFERENCES "systems"."systems"("system_name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interfaces_address" FOREIGN KEY ("address") REFERENCES "ip"."addresses"("address") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT
DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interface_address_config" FOREIGN KEY ("config") REFERENCES "dhcp"."config_types"("config") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interface_address_class" FOREIGN KEY ("class") REFERENCES "dhcp"."classes"("class") MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interface_addresses_mac" FOREIGN KEY ("mac") REFERENCES "systems"."interfaces"("mac") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "systems"."systems" ADD CONSTRAINT "fk_systems_systems_type" FOREIGN KEY ("type") REFERENCES "systems"."device_types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "systems"."systems" ADD CONSTRAINT "fk_systems_systems_os" FOREIGN KEY ("os_name") REFERENCES "systems"."os"("name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "dhcp"."subnet_options" ADD CONSTRAINT "fk_dhcp_subnet_options_subnet" FOREIGN KEY ("subnet") REFERENCES "ip"."subnets"("subnet") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "firewall"."metahost_members" ADD CONSTRAINT "fk_firewall_metahost_members_address" FOREIGN KEY ("address") REFERENCES "systems"."interface_addresses"("address") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "firewall"."metahost_members" ADD CONSTRAINT "fk_firewall_metahost_members_name" FOREIGN KEY ("name") REFERENCES "firewall"."metahosts"("name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "systems"."os" ADD CONSTRAINT "fk_systems_os_family" FOREIGN KEY ("family") REFERENCES "systems"."os_family"("family") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "dns"."pointers" ADD CONSTRAINT "fk_pointers_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."mx" ADD CONSTRAINT "fk_mx_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."zones" ADD CONSTRAINT "fk_dns_zones_keyname" FOREIGN KEY ("keyname") REFERENCES "dns"."keys"("keyname") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."txt" ADD CONSTRAINT "fk_txt_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."a" ADD CONSTRAINT "fk_dns_a_address" FOREIGN KEY ("address") REFERENCES "systems"."interface_addresses"("address") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."a" ADD CONSTRAINT "fk_a_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "firewall"."systems" ADD CONSTRAINT "fk_firewall_systems_system_name" FOREIGN KEY ("system_name") REFERENCES "systems"."systems"("system_name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "firewall"."systems" ADD CONSTRAINT "fk_firewall_systems_subnet" FOREIGN KEY ("subnet") REFERENCES "ip"."subnets"("subnet") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "firewall"."systems" ADD CONSTRAINT "fk_firewall_systems_software" FOREIGN KEY ("software_name") REFERENCES "firewall"."software"("software_name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "systems"."interfaces" ADD CONSTRAINT "fk_systems_interfaces_system_name" FOREIGN KEY ("system_name") REFERENCES "systems"."systems"("system_name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "management"."user_privileges" ADD CONSTRAINT "fk_user_privileges_privilege" FOREIGN KEY ("privilege") REFERENCES "management"."privileges"("privilege") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "firewall"."metahost_rules" ADD CONSTRAINT "fk_metahost_rules_transport" FOREIGN KEY ("transport") REFERENCES "firewall"."transports"("transport") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "firewall"."metahost_rules" ADD CONSTRAINT "fk_metahost_rules_name" FOREIGN KEY ("name") REFERENCES "firewall"."metahosts"("name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

/*View Log - Master Debug*/
CREATE OR REPLACE VIEW "management"."log_master_debug" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'DEBUG';

COMMENT ON VIEW "management"."log_master_debug" IS 'View all DEBUG level data (all function calls and data)';

/*View Log - Master Info*/
CREATE OR REPLACE VIEW "management"."log_master_info" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'INFO';

COMMENT ON VIEW "management"."log_master_info" IS 'View all INFO level data (when something happens)';

/*View Log - Master Error*/
CREATE OR REPLACE VIEW "management"."log_master_error" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'ERROR';

COMMENT ON VIEW "management"."log_master_error" IS 'View all ERROR level data (there was an exception in some function)';