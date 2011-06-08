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