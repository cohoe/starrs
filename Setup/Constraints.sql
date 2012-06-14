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

ALTER TABLE "dns"."srv" ADD CONSTRAINT "srv_alias_information_key" UNIQUE ("port","weight","priority","alias");

COMMENT ON CONSTRAINT "srv_alias_information_key" ON "dns"."srv" IS 'No duplicate infomation';

ALTER TABLE "dns"."srv" ADD CONSTRAINT "srv_alias_zone_key" UNIQUE ("alias","zone");

COMMENT ON CONSTRAINT "srv_alias_zone_key" ON "dns"."srv" IS 'Cannot have two of the same alises in the same zone';

ALTER TABLE "dns"."cname" ADD CONSTRAINT "cname_alias_zone_key" UNIQUE ("alias","zone");

COMMENT ON CONSTRAINT "cname_alias_zone_key" ON "dns"."cname" IS 'Cannot have two of the same alises in the same zone';

ALTER TABLE "dns"."mx" ADD CONSTRAINT "dns_mx_preference_zone_key" UNIQUE ("preference","zone");

COMMENT ON CONSTRAINT "dns_mx_preference_zone_key" ON "dns"."mx" IS 'No two MX servers can have the same preference in a domain';

ALTER TABLE "dns"."txt" ADD CONSTRAINT "dns_txt_hostname_zone_text_key" UNIQUE ("hostname","zone","text");

COMMENT ON CONSTRAINT "dns_txt_hostname_zone_text_key" ON "dns"."txt" IS 'No duplicate TXT records';

ALTER TABLE "dns"."a" ADD CONSTRAINT "a_hostname_zone_type_key" UNIQUE ("hostname","type","zone");

COMMENT ON CONSTRAINT "a_hostname_zone_type_key" ON "dns"."a" IS 'Can only have 1 of each A or AAAA';

ALTER TABLE "dns"."a" ADD CONSTRAINT "a_address_zone_key" UNIQUE ("address","zone");

COMMENT ON CONSTRAINT "a_address_zone_key" ON "dns"."a" IS 'Addresses in this table must be unique';

ALTER TABLE "systems"."interfaces" ADD CONSTRAINT "interfaces_system_name_name_key" UNIQUE ("system_name","name");

COMMENT ON CONSTRAINT "interfaces_system_name_name_key" ON "systems"."interfaces" IS 'Inteface names must be unique on a system';

ALTER TABLE "dhcp"."class_options" ADD CONSTRAINT "fk_dhcp_class_options_class" FOREIGN KEY ("class") REFERENCES "dhcp"."classes"("class") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "ip"."subnets" ADD CONSTRAINT "fk_subnets_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET DEFAULT;

ALTER TABLE "ip"."ranges" ADD CONSTRAINT "fk_ip_ranges_use" FOREIGN KEY ("use") REFERENCES "ip"."range_uses"("use") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "ip"."ranges" ADD CONSTRAINT "fk_ip_ranges_subnet" FOREIGN KEY ("subnet") REFERENCES "ip"."subnets"("subnet") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "ip"."ranges" ADD CONSTRAINT "fk_ranges_class" FOREIGN KEY ("class") REFERENCES "dhcp"."classes"("class") MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "dns"."ns" ADD CONSTRAINT "fk_dns_ns_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "network"."switchports" ADD CONSTRAINT "fk_network_switchports_type" FOREIGN KEY ("type") REFERENCES "network"."switchport_types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "network"."switchports" ADD CONSTRAINT "fk_switchports_system_name" FOREIGN KEY ("system_name") REFERENCES "systems"."systems"("system_name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interfaces_address" FOREIGN KEY ("address") REFERENCES "ip"."addresses"("address") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT
DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interface_address_config" FOREIGN KEY ("config") REFERENCES "dhcp"."config_types"("config") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interface_address_class" FOREIGN KEY ("class") REFERENCES "dhcp"."classes"("class") MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "systems"."interface_addresses" ADD CONSTRAINT "fk_systems_interface_addresses_mac" FOREIGN KEY ("mac") REFERENCES "systems"."interfaces"("mac") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "systems"."systems" ADD CONSTRAINT "fk_systems_systems_type" FOREIGN KEY ("type") REFERENCES "systems"."device_types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "systems"."systems" ADD CONSTRAINT "fk_systems_systems_os" FOREIGN KEY ("os_name") REFERENCES "systems"."os"("name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "dhcp"."subnet_options" ADD CONSTRAINT "fk_dhcp_subnet_options_subnet" FOREIGN KEY ("subnet") REFERENCES "ip"."subnets"("subnet") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "systems"."os" ADD CONSTRAINT "fk_systems_os_family" FOREIGN KEY ("family") REFERENCES "systems"."os_family"("family") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "dns"."srv" ADD CONSTRAINT "fk_srv_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."cname" ADD CONSTRAINT "fk_cname_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."mx" ADD CONSTRAINT "fk_mx_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."mx" ADD CONSTRAINT "fk_mx_type" FOREIGN KEY ("type") REFERENCES "dns"."types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "dns"."zones" ADD CONSTRAINT "fk_dns_zones_keyname" FOREIGN KEY ("keyname") REFERENCES "dns"."keys"("keyname") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."txt" ADD CONSTRAINT "fk_txt_fqdn" FOREIGN KEY ("hostname","address","zone") REFERENCES "dns"."a"("hostname","address","zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."zone_txt" ADD CONSTRAINT "fk_zone_txt_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."zone_txt" ADD CONSTRAINT "zone_txt_hostname_zone_text_key" UNIQUE ("hostname","zone","text");

ALTER TABLE "dns"."txt" ADD CONSTRAINT "fk_txt_type" FOREIGN KEY ("type") REFERENCES "dns"."types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "dns"."a" ADD CONSTRAINT "fk_dns_a_address" FOREIGN KEY ("address") REFERENCES "systems"."interface_addresses"("address") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."a" ADD CONSTRAINT "fk_a_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."a" ADD CONSTRAINT "fk_a_type" FOREIGN KEY ("type") REFERENCES "dns"."types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "systems"."interfaces" ADD CONSTRAINT "fk_systems_interfaces_system_name" FOREIGN KEY ("system_name") REFERENCES "systems"."systems"("system_name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dhcp"."range_options" ADD CONSTRAINT "fk_range_options_name" FOREIGN KEY ("name") REFERENCES "ip"."ranges"("name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "documentation"."rules" ADD CONSTRAINT "fk_rules_specific_name" FOREIGN KEY ("specific_name") REFERENCES "documentation"."functions"("specific_name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "documentation"."arguments" ADD CONSTRAINT "fk_arguments_specific_name" FOREIGN KEY ("specific_name") REFERENCES "documentation"."functions"("specific_name") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "network"."switchport_history" ADD CONSTRAINT "fk_switchport_history_system_name_port_name" FOREIGN KEY ("port_name","system_name") REFERENCES "network"."switchports"("port_name","system_name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "network"."switchport_macs" ADD CONSTRAINT "fk_switchport_macs_switchport" FOREIGN KEY ("port_name","system_name") REFERENCES "network"."switchports"("port_name","system_name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "network"."switchport_states" ADD CONSTRAINT "fk_switchport_states_port_system" FOREIGN KEY ("port_name","system_name") REFERENCES "network"."switchports"("port_name","system_name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "network"."switchview" ADD CONSTRAINT "fk_switchview_system" FOREIGN KEY ("system_name") REFERENCES "systems"."systems"("system_name") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "systems"."device_types" ADD CONSTRAINT "fk_device_types_family" FOREIGN KEY ("family") REFERENCES "systems"."type_family"("family") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE "dns"."soa" ADD CONSTRAINT "fk_soa_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."zone_a" ADD CONSTRAINT "fk_dns_zone_a_address" FOREIGN KEY ("address") REFERENCES "systems"."interface_addresses"("address") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."zone_a" ADD CONSTRAINT "fk_zone_a_zone" FOREIGN KEY ("zone") REFERENCES "dns"."zones"("zone") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "dns"."zone_a" ADD CONSTRAINT "fk_zone_a_type" FOREIGN KEY ("type") REFERENCES "dns"."types"("type") MATCH SIMPLE ON UPDATE RESTRICT ON DELETE RESTRICT;
