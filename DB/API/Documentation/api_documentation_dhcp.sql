UPDATE "documentation"."arguments"
SET "comment" = 'The name of the class to be created'
WHERE "argument" = 'input_class'
AND "specific_name" ~* '^create_dhcp_class(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the class (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_dhcp_class(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dhcp_class('netboot','Anthonys boot server project');$$, "comment" = 'Create a new DHCP class in the database', "schema" = 'dhcp'
WHERE "specific_name" ~* '^create_dhcp_class(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the class to assign to'
WHERE "argument" = 'input_class'
AND "specific_name" ~* '^create_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The option declaration to insert'
WHERE "argument" = 'input_option'
AND "specific_name" ~* '^create_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the option'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^create_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dhcp_class_option('netboot','next-server','"10.0.0.1"');$$, "comment" = 'Assign an option to a given DHCP class', "schema" = 'dhcp'
WHERE "specific_name" ~* '^create_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to assign the option to'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^create_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The option declaration to insert'
WHERE "argument" = 'input_option'
AND "specific_name" ~* '^create_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the option'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^create_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dhcp_subnet_option('10.0.0.0/24','option-routers','"10.0.0.254"');$$, "comment" = 'Assign a DHCP option to a subnet. Useful for routers, DNS servers, etc', "schema" = 'dhcp'
WHERE "specific_name" ~* '^create_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to apply to'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^create_dhcp_subnet_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The setting definition'
WHERE "argument" = 'input_setting'
AND "specific_name" ~* '^create_dhcp_subnet_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the setting'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^create_dhcp_subnet_setting(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dhcp_subnet_setting('10.0.0.0/24','max-lease-time','3600');$$, "comment" = 'Create a DHCP subnet setting. These are different than options in that only one directive can be made per subnet', "schema" = 'dhcp'
WHERE "specific_name" ~* '^create_dhcp_subnet_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Range name to create the setting on'
WHERE "argument" = 'input_range'
AND "specific_name" ~* '^create_dhcp_range_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The setting to create'
WHERE "argument" = 'input_setting'
AND "specific_name" ~* '^create_dhcp_range_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the setting'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^create_dhcp_range_setting(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dhcp_range_setting('Dynamic pool','option domain-name','"example.com"');$$, "comment" = 'Create a DHCP setting for a dynamic pool. ', "schema" = 'dhcp'
WHERE "specific_name" ~* '^create_dhcp_range_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the class to be removed'
WHERE "argument" = 'input_class'
AND "specific_name" ~* '^remove_dhcp_class(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dhcp_class('netboot');$$, "comment" = 'Remove a DHCP class from the database', "schema" = 'dhcp'
WHERE "specific_name" ~* '^remove_dhcp_class(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the class'
WHERE "argument" = 'input_class'
AND "specific_name" ~* '^remove_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The option declaration to remove'
WHERE "argument" = 'input_option'
AND "specific_name" ~* '^remove_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the option to remove'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^remove_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dhcp_class_option('netboot','next-server','"10.0.0.1"');$$, "comment" = 'Remove a configured class option from the database', "schema" = 'dhcp'
WHERE "specific_name" ~* '^remove_dhcp_class_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to remove the option/value from'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^remove_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The option declaration to remove'
WHERE "argument" = 'input_option'
AND "specific_name" ~* '^remove_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the option to remove'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^remove_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dhcp_subnet_option('10.0.0.0/24','option-routers','"10.0.0.254"'); $$, "comment" = 'Remove a configured subnet option from the database', "schema" = 'dhcp'
WHERE "specific_name" ~* '^remove_dhcp_subnet_option(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to remove the setting from'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^remove_dhcp_subnet_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The setting definition to remove'
WHERE "argument" = 'input_setting'
AND "specific_name" ~* '^remove_dhcp_subnet_setting(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dhcp_subnet_setting('10.0.0.0/24','max-lease-time');$$, "comment" = 'Remove a DHCP subnet setting (settings != options)', "schema" = 'dhcp'
WHERE "specific_name" ~* '^remove_dhcp_subnet_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The range to remove the setting from'
WHERE "argument" = 'input_range'
AND "specific_name" ~* '^remove_dhcp_range_setting(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The setting to remove'
WHERE "argument" = 'input_setting'
AND "specific_name" ~* '^remove_dhcp_range_setting(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dhcp_range_setting('Dynamic Pool','allow unknown');$$, "comment" = 'Remove a DHCP range setting', "schema" = 'dhcp'
WHERE "specific_name" ~* '^remove_dhcp_range_setting(_)+([0-9])+$';

/* api.get_dhcpd_static_hosts */
UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_static_hosts();$$, "comment" = 'Get all the IPv4 DHCP hosts with a configured address. These are not "static" registrations in the technical sense, but they are hosts that receive their information via DHCP but get the same address every time.', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_static_hosts(_)+([0-9])+$';

/* api.get_dhcpd_dynamic_hosts */
UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_dynamic_hosts();$$, "comment" = 'Get all the IPv4 DHCP hosts that are set to receive an address from the dynamic pools', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_dynamic_hosts(_)+([0-9])+$';

/* api.get_dhcpd_subnets */
UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_subnets();$$, "comment" = 'Get all of the IPv4 DHCP-enabled subnets', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_subnets(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to get the options from'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^get_dhcpd_subnet_options(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_subnet_options('10.0.0.0/24');$$, "comment" = 'Get all DHCP options of a configured subnet', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_subnet_options(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to get the settings from'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^get_dhcpd_subnet_settings(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_subnet_settings('10.0.0.0/24');$$, "comment" = 'Get all DHCP settings of a configured subnet', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_subnet_settings(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the range to get the options of'
WHERE "argument" = 'input_range'
AND "specific_name" ~* '^get_dhcpd_range_options(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_range_options('Dynamic Pool');$$, "comment" = 'Get all DHCP options of a configured range', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_range_options(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the range to get the options of'
WHERE "argument" = 'input_range'
AND "specific_name" ~* '^get_dhcpd_range_settings(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_range_settings('Dynamic Pool');$$, "comment" = 'Get all DHCP settings of a configured range', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_range_settings(_)+([0-9])+$';

/* api.get_dhcpd_subnet_ranges */
UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to search for'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^get_dhcpd_subnet_ranges(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_dhcpd_subnet_ranges('10.0.0.0/24');$$, "comment" = 'Get DHCP information on all the dynamic ranges from a subnet', "schema" = 'dhcp'
WHERE "specific_name" ~* '^get_dhcpd_subnet_ranges(_)+([0-9])+$';