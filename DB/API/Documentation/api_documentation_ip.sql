UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_subnet('10.0.0.0/24','Servers','All servers',TRUE,TRUE,'example.com','root');$$, "comment" = 'Create a new subnet to manage', "schema" = 'ip'
WHERE "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet in CIDR notation'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of this subnet'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the subnet (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Autopopulate the IP addresses table (advanced use only)'
WHERE "argument" = 'input_autogen'
AND "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TRUE to allow this subnet for DHCP, FALSE for not'
WHERE "argument" = 'input_dhcp'
AND "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'DNS zone to associate with this subnet'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The owner of the subnet (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the range'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The first IP address of the range'
WHERE "argument" = 'input_first_ip'
AND "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The last IP address of the range'
WHERE "argument" = 'input_last_ip'
AND "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet containing the range'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A use (see documentation for uses)'
WHERE "argument" = 'input_use'
AND "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The DHCP class of the range. '
WHERE "argument" = 'input_class'
AND "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the range (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_ip_range('Rack 1','10.0.0.1','10.0.0.20','10.0.0.0/24','UREG','default','All rack 1 machines');$$, "comment" = 'Create a range of addresses.', "schema" = 'ip'
WHERE "specific_name" ~* '^create_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'First address of the range'
WHERE "argument" = 'input_first_ip'
AND "specific_name" ~* '^create_address_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Last address of the range'
WHERE "argument" = 'input_last_ip'
AND "specific_name" ~* '^create_address_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Subnet containign the range'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^create_address_range(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_address_range('2001:db0::1','2001:db0::ff','2001:db0::/64');$$, "comment" = 'Create all addresses within a range for a non-autogenerating subnet. The intention is to use this with DHCPv6 subnets since IPv6 can have millions of addresses.', "schema" = 'ip'
WHERE "specific_name" ~* '^create_address_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to remove in CIDR notation'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^remove_subnet(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_subnet('10.0.0.0/24');$$, "comment" = 'Remove a subnet from the network', "schema" = 'ip'
WHERE "specific_name" ~* '^remove_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the range to remove'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^remove_ip_range(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_ip_range('Rack 1');$$, "comment" = 'Remove an IP range from the database', "schema" = 'ip'
WHERE "specific_name" ~* '^remove_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the range to obtain an address from'
WHERE "argument" = 'input_range_name'
AND "specific_name" ~* '^get_address_from_range(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT pi.get_address_from_range('Rack 1');    $$, "comment" = 'Given a range, return the first available IP address within that range', "schema" = 'ip'
WHERE "specific_name" ~* '^get_address_from_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Subnet to parse'
WHERE "argument" = 'input_$1'
AND "specific_name" ~* '^get_subnet_addresses(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_subnet_addresses('10.0.0.0/24');$$, "comment" = 'Get a list of all allowed addresses within a subnet', "schema" = 'ip'
WHERE "specific_name" ~* '^get_subnet_addresses(_)+([0-9])+$';

/* api.get_range_addresses */
UPDATE "documentation"."arguments"
SET "comment" = 'First address of the range'
WHERE "argument" = '$1'
AND "specific_name" ~* '^get_range_addresses(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Last address of the range'
WHERE "argument" = '$2'
AND "specific_name" ~* '^get_range_addresses(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_range_addresses('10.0.0.1', '10.0.0.254');$$, "comment" = 'Get a list of all addresses within a range (useful for DHCPv6)', "schema" = 'ip'
WHERE "specific_name" ~* '^get_range_addresses(_)+([0-9])+$';

/* api.get_subnet_utilization */
UPDATE "documentation"."arguments"
SET "comment" = 'Subnet to analyze'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^get_subnet_utilization(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_subnet_utilization('10.0.0.1');$$, "comment" = 'Get a percentage usage of a subnet', "schema" = 'ip'
WHERE "specific_name" ~* '^get_subnet_utilization(_)+([0-9])+$';

/* api.modify_ip_range */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the range to modify'
WHERE "argument" = 'input_old_name'
AND "specific_name" ~* '^modify_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_ip_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_ip_range(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_ip_range('Servers','first_ip','10.0.0.10');$$, "comment" = 'Modify an IP range', "schema" = 'ip'
WHERE "specific_name" ~* '^modify_ip_range(_)+([0-9])+$';

/* api.modify_ip_subnet */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the subnet to modify'
WHERE "argument" = 'input_old_subnet'
AND "specific_name" ~* '^modify_ip_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_ip_subnet(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_ip_subnet(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_ip_subnet('10.0.0.0/24','owner','admin');$$, "comment" = 'Modify an IP subnet', "schema" = 'ip'
WHERE "specific_name" ~* '^modify_ip_subnet(_)+([0-9])+$';

