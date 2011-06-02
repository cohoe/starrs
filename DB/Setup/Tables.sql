CREATE TABLE "firewall"."metahosts"(
"name" TEXT NOT NULL,
"comment" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"owner" TEXT NOT NULL,
CONSTRAINT "metahosts_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."transports"(
"transport" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT DEFAULT api.get_current_user(),
CONSTRAINT "transports_pkey" PRIMARY KEY ("transport")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."class_options"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "programs_pkey" PRIMARY KEY ("port")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."defaults"(
"deny" BOOLEAN NOT NULL DEFAULT api.get_firewall_site_default(),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"owner" TEXT NOT NULL,
CONSTRAINT "rules_pkey" PRIMARY KEY ("port","transport","address")
)
WITHOUT OIDS;

CREATE TABLE "ip"."range_uses"(
"use" VARCHAR(4) NOT NULL,
"comment" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "range_uses_pkey" PRIMARY KEY ("use")
)
WITHOUT OIDS;

CREATE TABLE "systems"."device_types"(
"type" TEXT NOT NULL,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"name" TEXT NOT NULL,
"owner" TEXT NOT NULL,
"zone" TEXT DEFAULT 'localdomain',
"dhcp_enable" BOOLEAN NOT NULL DEFAULT FALSE,
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"name" TEXT NOT NULL,
"subnet" CIDR,
CONSTRAINT "ranges_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "dns"."ns"(
"isprimary" BOOLEAN NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"system_name" TEXT NOT NULL,
CONSTRAINT "switchports_pkey" PRIMARY KEY ("port_name","system_name")
)
WITHOUT OIDS;

CREATE TABLE "systems"."interface_addresses"(
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"comment" TEXT,
"address" INET NOT NULL,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"config" TEXT NOT NULL,
"family" INTEGER NOT NULL,
"isprimary" BOOLEAN NOT NULL,
"renew_date" DATE NOT NULL DEFAULT date(current_date + interval '1 year'),
"mac" MACADDR,
"class" TEXT,
"name" TEXT NOT NULL,
CONSTRAINT "interface_addresses_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."classes"(
"class" TEXT NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"subnet" CIDR NOT NULL,
CONSTRAINT "subnet_options_pkey" PRIMARY KEY ("option","value","subnet")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."metahost_members"(
"address" INET NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"name" TEXT,
CONSTRAINT "metahost_members_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dhcp"."config_types"(
"config" TEXT NOT NULL,
"comment" TEXT,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"family" INTEGER NOT NULL,
CONSTRAINT "config_types_pkey" PRIMARY KEY ("config")
)
WITHOUT OIDS;

CREATE TABLE "systems"."os"(
"name" TEXT NOT NULL,
"default_connection_name" TEXT NOT NULL,
"family" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "os_pkey" PRIMARY KEY ("name")
)
WITHOUT OIDS;

CREATE TABLE "dns"."pointers"(
"alias" VARCHAR(63) NOT NULL,
"extra" TEXT,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "switchport_types_pkey" PRIMARY KEY ("type")
)
WITHOUT OIDS;

CREATE TABLE "dns"."mx"(
"preference" INTEGER NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"owner" TEXT NOT NULL,
"comment" TEXT,
CONSTRAINT "zones_pkey" PRIMARY KEY ("zone")
)
WITHOUT OIDS;

CREATE TABLE "dns"."keys"(
"keyname" TEXT NOT NULL,
"key" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"comment" TEXT,
CONSTRAINT "keys_pkey" PRIMARY KEY ("keyname")
)
WITHOUT OIDS;

CREATE TABLE "ip"."addresses"(
"address" INET NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "addresses_pkey" PRIMARY KEY ("address")
)
WITHOUT OIDS;

CREATE TABLE "dns"."txt"(
"text" TEXT NOT NULL,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"severity" TEXT NOT NULL
)
WITHOUT OIDS;

CREATE TABLE "dns"."a"(
"hostname" VARCHAR(63) NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
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
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"system_name" TEXT,
"subnet" CIDR NOT NULL,
"software_name" TEXT NOT NULL,
CONSTRAINT "systems_pkey" PRIMARY KEY ("subnet")
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
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"system_name" TEXT,
CONSTRAINT "interfaces_pkey" PRIMARY KEY ("mac")
)
WITHOUT OIDS;

CREATE TABLE "management"."privileges"(
"privilege" TEXT NOT NULL,
"comment" TEXT,
CONSTRAINT "privileges_pkey" PRIMARY KEY ("privilege")
)
WITHOUT OIDS;

CREATE TABLE "management"."user_privileges"(
"username" TEXT NOT NULL,
"privilege" TEXT NOT NULL,
"allow" BOOLEAN NOT NULL DEFAULT FALSE,
CONSTRAINT "user_privileges_pkey" PRIMARY KEY ("username","privilege")
)
WITHOUT OIDS;

CREATE TABLE "management"."configuration"(
"option" TEXT NOT NULL,
"value" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "configuration_pkey" PRIMARY KEY ("option")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."software"(
"software_name" TEXT NOT NULL,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
CONSTRAINT "software_pkey" PRIMARY KEY ("software_name")
)
WITHOUT OIDS;

CREATE TABLE "firewall"."metahost_rules"(
"deny" BOOLEAN NOT NULL DEFAULT TRUE,
"port" INTEGER NOT NULL,
"comment" TEXT,
"date_created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"date_modified" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
"last_modifier" TEXT NOT NULL DEFAULT api.get_current_user(),
"transport" TEXT NOT NULL,
"name" TEXT NOT NULL,
CONSTRAINT "metahost_rules_pkey" PRIMARY KEY ("port","transport","name")
)
WITHOUT OIDS;

CREATE TABLE "management"."processes"(
"process" TEXT NOT NULL,
"locked" BOOLEAN NOT NULL DEFAULT FALSE,
CONSTRAINT "processes_pkey" PRIMARY KEY ("process")
)
WITHOUT OIDS;