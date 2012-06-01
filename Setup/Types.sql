/* Types */

/* DHCP - static hosts */
CREATE TYPE "dhcp"."dhcpd_static_hosts" AS (hostname varchar(63),zone text, mac macaddr, address inet, owner text, class text);
COMMENT ON TYPE "dhcp"."dhcpd_static_hosts" IS 'Static host information for the dhcpd.conf';

/* DHCP - dynamic hosts */
CREATE TYPE "dhcp"."dhcpd_dynamic_hosts" AS (hostname varchar(63),zone text, mac macaddr, owner text, class text);
COMMENT ON TYPE "dhcp"."dhcpd_static_hosts" IS 'Dynamic host information for the dhcpd.conf';

/* DHCP - subnet_options */
CREATE TYPE "dhcp"."dhcpd_subnet_options" AS (option text, value text);
COMMENT ON TYPE "dhcp"."dhcpd_subnet_options" IS 'Subnet options for the dhcpd.conf';

/* DHCP - subnet_settings */
CREATE TYPE "dhcp"."dhcpd_subnet_settings" AS (setting text, value text);
COMMENT ON TYPE "dhcp"."dhcpd_subnet_settings" IS 'Subnet settings for the dhcpd.conf';

/* DHCP - range_options */
CREATE TYPE "dhcp"."dhcpd_range_options" AS (option text, value text);
COMMENT ON TYPE "dhcp"."dhcpd_range_options" IS 'range options for the dhcpd.conf';

/* DHCP - range_settings */
CREATE TYPE "dhcp"."dhcpd_range_settings" AS (setting text, value text);
COMMENT ON TYPE "dhcp"."dhcpd_range_settings" IS 'range settings for the dhcpd.conf';

/* DHCP - subnet_ranges */
CREATE TYPE "dhcp"."dhcpd_subnet_ranges" AS (name text, first_ip inet, last_ip inet, class text);
COMMENT ON TYPE "dhcp"."dhcpd_subnet_ranges" IS 'list all dynamic ranges within a subnet';

/* DHCP - keys */
CREATE TYPE "dhcp"."dhcpd_keys" AS (keyname text, key text);
COMMENT ON TYPE "dhcp"."dhcpd_keys" IS 'get the keys of the DHCP enabled subnet zones';

/* DHCP - global options */
CREATE TYPE "dhcp"."dhcpd_global_options" AS (option text, value text);
COMMENT ON TYPE "dhcp"."dhcpd_global_options" IS 'Get all global DHCPD config directives';

/* DHCP - classes */
CREATE TYPE "dhcp"."dhcpd_classes" AS (class text, comment text);
COMMENT ON TYPE "dhcp"."dhcpd_classes" IS 'Class information for dhcpd.conf';

/* DHCP - zone keys */
CREATE TYPE "dhcp"."dhcpd_dns_keys" AS (keyname text, key text, enctype text);
COMMENT ON TYPE "dhcp"."dhcpd_dns_keys" IS 'Get all dns key information for dhcpd';

/* DHCP - zones */
CREATE TYPE "dhcp"."dhcpd_zones" AS (zone text, keyname text, primary_ns inet);
COMMENT ON TYPE "dhcp"."dhcpd_zones" IS 'Zone information for dhcpd';

/* DHCP - class options */
CREATE TYPE "dhcp"."dhcpd_class_options" AS (option text, value text);
COMMENT ON TYPE "dhcp"."dhcpd_class_options" IS 'Get class options for the dhcpd.conf';

/* DNS - mx_data */
CREATE TYPE "dns"."mx_data" AS (hostname varchar(63), zone text, address inet, type text, preference integer, ttl integer, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "dns"."mx_data" IS 'All MX data';

/* DNS - ns_data */
CREATE TYPE "dns"."ns_data" AS (hostname varchar(63), zone text, address inet, type text, isprimary boolean, ttl integer, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "dns"."ns_data" IS 'All NS data';

/* DNS - txt_data */
CREATE TYPE "dns"."txt_data" AS (hostname varchar(63), zone text, address inet, type text, text text, ttl integer, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "dns"."txt_data" IS 'All text (TXT,SPF) data';

/* DNS - pointer_data */
CREATE TYPE "dns"."pointer_data" AS (alias varchar(63), hostname varchar(63), zone text, address inet, type text, extra text, ttl integer, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "dns"."pointer_data" IS 'All pointer (CNAME,SRV) data';

/* DNS - a_data */
CREATE TYPE "dns"."a_data" AS (hostname varchar(63), zone text, address inet, type text, ttl integer, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "dns"."a_data" IS 'All address (A/AAAA) data';

/* DNS - zone_data */
CREATE TYPE "dns"."zone_audit_data" AS (host TEXT, ttl INTEGER, type TEXT, address INET, port INTEGER, weight INTEGER, priority INTEGER, preference INTEGER, target TEXT, text TEXT, contact TEXT, serial TEXT, refresh INTEGER, retry INTEGER, expire INTEGER, minimum INTEGER);
COMMENT ON TYPE "dns"."zone_audit_data" IS 'All DNS zone data for auditing purposes';

/* Firewall - rule_data */
CREATE TYPE "firewall"."rule_data" AS (address inet, port integer, transport text, deny boolean, owner text, comment text, source text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."rule_data" IS 'Firewall rule data';

/* Systems - interface_address_data */
CREATE TYPE "systems"."interface_address_data" AS (mac macaddr, address inet, family integer, config text, class text, isprimary boolean, comment text, renew_date date, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "systems"."interface_address_data" IS 'Interface address data';

/* Systems - interface_data */
CREATE TYPE "systems"."interface_data" AS (system_name text, mac macaddr, name text, comment text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "systems"."interface_data" IS 'System interface information';

/* Systems - system_data */
CREATE TYPE "systems"."system_data" AS (system_name text, type text, family text, os_name text, owner text, comment text, renew_date date, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "systems"."system_data" IS 'System information';

/* Systems - os_family_distribution */
CREATE TYPE "systems"."os_family_distribution" AS (family text, count integer, percentage integer);
COMMENT ON TYPE "systems"."os_family_distribution" IS 'OS distribution statistics';

/* Systems - os_distribution */
CREATE TYPE "systems"."os_distribution" AS (name text, count integer, percentage integer);
COMMENT ON TYPE "systems"."os_distribution" IS 'OS distribution statistics';

CREATE TYPE "dhcp"."config_type_data" AS (config text, family integer, comment text, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "dhcp"."class_data" AS (class text, comment text, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "ip"."range_data" AS (name text, first_ip inet, last_ip inet, subnet cidr, use varchar(4), class text, comment text, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "firewall"."program_data" AS (name text, port integer, transport text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."program_data" IS 'Firewall Program Data';

CREATE TYPE "firewall"."metahost_data" AS (name text, comment text, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."metahost_data" IS 'Firewall metahost data';

CREATE TYPE "firewall"."metahost_member_data" AS (name text, address inet, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."metahost_member_data" IS 'Firewall metahost data';

/* FIREWALL RULES */
CREATE TYPE "firewall"."standalone_rule_data" AS (address inet, port integer, transport text, deny boolean, comment text, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."standalone_rule_data" IS 'Data for standalone firewall rules';

CREATE TYPE "firewall"."standalone_program_data" AS (address inet, name text, port integer, transport text, deny boolean, comment text, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."standalone_program_data" IS 'Data for standalone firewall program rules';

CREATE TYPE "firewall"."metahost_standalone_data" AS (name text, port integer, transport text, deny boolean, comment text, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."metahost_standalone_data"  IS 'Standalone metahost rules data';

CREATE TYPE "firewall"."metahost_program_data" AS (metahost_name text, program_name text, port integer, transport text, deny boolean, comment text, owner text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "firewall"."metahost_program_data"  IS 'Program based metahost rules data';

CREATE TYPE "ip"."subnet_data" AS (name text, subnet cidr, zone text, owner text, autogen boolean, dhcp_enable boolean, comment text, date_created timestamp, date_modified timestamp, last_modifier text);
COMMENT ON TYPE "ip"."subnet_data" IS 'IP subnet data';

CREATE TYPE "firewall"."address_data" AS (subnet cidr, address inet, isprimary boolean, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "firewall"."default_data" AS (address inet, deny boolean);

CREATE TYPE "firewall"."rule_export_data" AS (action text, address inet, port integer, transport text, deny boolean);

CREATE TYPE "dns"."zone_data" AS (zone text, keyname text, forward boolean, shared boolean, owner text, comment text, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "dns"."key_data" AS (keyname text, key text, comment text, owner text, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "dhcp"."option_data" AS (option text, value text, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "network"."switchview_data" AS (port text, mac macaddr);

CREATE TYPE "network"."switchport_data" AS (system_name text, port_name text, type text, description text, port_state boolean, admin_state boolean, date_created timestamp, date_modified timestamp, last_modifier text);

CREATE TYPE "network"."switchview_setting_data" AS (snmp_ro_community text, snmp_rw_community text, enable boolean);

CREATE TYPE "network"."switchview_state_data" AS (port text, state boolean);

CREATE TYPE "api"."search_data" AS (system_name text, mac macaddr, address inet, system_owner text, system_last_modifier text, range text, hostname varchar(63), zone text, dns_owner text, dns_last_modifier text);
