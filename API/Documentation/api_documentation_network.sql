UPDATE "documentation"."arguments"
SET "comment" = 'Name of the port to create'
WHERE "argument" = 'input_port_name'
AND "specific_name" ~* '^create_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the system to create the port on'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^create_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Type of port (access, uplink, trunk, etc)'
WHERE "argument" = 'input_port_type'
AND "specific_name" ~* '^create_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A description of the port'
WHERE "argument" = 'input_description'
AND "specific_name" ~* '^create_switchport(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_switchport('Gi0/1','Head Switch','Uplink','Master Uplink');$$, "comment" = 'Create a switchport on a network device', "schema" = 'network'
WHERE "specific_name" ~* '^create_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name prefix for ports'
WHERE "argument" = 'input_prefix'
AND "specific_name" ~* '^create_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'First port identifier'
WHERE "argument" = 'first_port'
AND "specific_name" ~* '^create_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Last port identifer'
WHERE "argument" = 'last_port'
AND "specific_name" ~* '^create_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the system to create on'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^create_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Type of the ports'
WHERE "argument" = 'input_port_type'
AND "specific_name" ~* '^create_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Description of all ports'
WHERE "argument" = 'input_description'
AND "specific_name" ~* '^create_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_switchport_range('Gi0/',1,48,'switch1','access','All machine ports');$$, "comment" = 'Create a large amount of ports between two number identifiers', "schema" = 'network'
WHERE "specific_name" ~* '^create_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the port to remove'
WHERE "argument" = 'input_port_name'
AND "specific_name" ~* '^remove_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the system to remove the port from'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^remove_switchport(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_switchport('Gi0/1','Head Switch');$$, "comment" = 'Remove a switchport from a system', "schema" = 'network'
WHERE "specific_name" ~* '^remove_switchport(_)+([0-9])+$';

/* api.remove_switchport_range */
UPDATE "documentation"."arguments"
SET "comment" = 'Prefix of the ports'
WHERE "argument" = 'input_prefix'
AND "specific_name" ~* '^remove_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'First port # to remove'
WHERE "argument" = 'first_port'
AND "specific_name" ~* '^remove_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Last port # to remove'
WHERE "argument" = 'last_port'
AND "specific_name" ~* '^remove_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'System to remove from'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^remove_switchport_range(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_switchport_range('Gi0/',1,48,'Head Switch');$$, "comment" = 'Remove a range of switchports from a system', "schema" = 'network'
WHERE "specific_name" ~* '^remove_switchport_range(_)+([0-9])+$';

/* api.modify_network_switchport */
UPDATE "documentation"."arguments"
SET "comment" = 'The system to use'
WHERE "argument" = 'input_old_system'
AND "specific_name" ~* '^modify_network_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The port to modify'
WHERE "argument" = 'input_old_port'
AND "specific_name" ~* '^modify_network_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_network_switchport(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_network_switchport(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_network_switchport('Switch1','Gi0/1','type','access');$$, "comment" = 'Modify a switchport on a network device', "schema" = 'network'
WHERE "specific_name" ~* '^modify_network_switchport(_)+([0-9])+$';