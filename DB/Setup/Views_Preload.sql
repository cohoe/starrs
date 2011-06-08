/* DHCPD Static Hosts */
CREATE OR REPLACE VIEW "dhcp"."dhcpd_static_hosts" AS SELECT current_timestamp;

/* DHCPD Dynamic Hosts */
CREATE OR REPLACE VIEW "dhcp"."dhcpd_dynamic_hosts" AS SELECT current_timestamp;