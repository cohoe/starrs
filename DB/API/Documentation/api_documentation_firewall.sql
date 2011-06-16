UPDATE "documentation"."arguments"
SET "comment" = 'The address to assign'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^create_firewall_metahost_member(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The metahost name to assign the address to'
WHERE "argument" = 'input_metahost'
AND "specific_name" ~* '^create_firewall_metahost_member(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_firewall_metahost_member('10.0.0.1','Servers');$$, "comment" = 'Assign an IP address to a metahost', "schema" = 'firewall'
WHERE "specific_name" ~* '^create_firewall_metahost_member(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the metahost'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^create_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the new metahost (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The owning username (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_firewall_metahost('Servers','All servers on the network',NULL);$$, "comment" = 'Create a new metahost', "schema" = 'firewall'
WHERE "specific_name" ~* '^create_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Metahost name to apply to'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^create_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Port to perform the action on'
WHERE "argument" = 'input_port'
AND "specific_name" ~* '^create_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TCP or UDP or BOTH'
WHERE "argument" = 'input_transport'
AND "specific_name" ~* '^create_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TRUE or FALSE to deny traffic'
WHERE "argument" = 'input_deny'
AND "specific_name" ~* '^create_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The owning username (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the rule'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_firewall_metahost_rule('Servers',22,'TCP',FALSE,'root','Allow SSH traffic');$$, "comment" = 'Create a new rule for a metahost to be applied to all members.', "schema" = 'firewall'
WHERE "specific_name" ~* '^create_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The system name of the firewall'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^create_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The subnet for which this system controls'
WHERE "argument" = 'input_subnet'
AND "specific_name" ~* '^create_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The system software'
WHERE "argument" = 'input_software'
AND "specific_name" ~* '^create_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_firewall_system('Firewall1','10.0.0.0/24','Cisco IOS');$$, "comment" = 'Establish a system as a firewall and specify its software so the proper rule syntax can be used.', "schema" = 'firewall'
WHERE "specific_name" ~* '^create_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Address to apply the rule to'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^create_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Port to perform on'
WHERE "argument" = 'input_port'
AND "specific_name" ~* '^create_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TCP or UDP or BOTH'
WHERE "argument" = 'input_transport'
AND "specific_name" ~* '^create_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TRUE to Deny traffic, FALSE to allow traffic'
WHERE "argument" = 'input_deny'
AND "specific_name" ~* '^create_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The owning username (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the rule (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_firewall_rule('10.0.0.1',22,'TCP',TRUE,NULL,'Block SSH traffic');$$, "comment" = 'Create a new standalone firewall rule', "schema" = 'firewall'
WHERE "specific_name" ~* '^create_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The address to create the rule on'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^create_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the program to act upon'
WHERE "argument" = 'input_program'
AND "specific_name" ~* '^create_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TRUE to deny traffic, FALSE to allow'
WHERE "argument" = 'input_deny'
AND "specific_name" ~* '^create_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The owning username (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_firewall_rule_program('10.0.0.1','SSH',TRUE,'root');$$, "comment" = 'Create a firewall rule from a common program registered in the application', "schema" = 'firewall'
WHERE "specific_name" ~* '^create_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The metahost to create the rule on'
WHERE "argument" = 'input_metahost'
AND "specific_name" ~* '^create_firewall_metahost_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the program to act upon'
WHERE "argument" = 'input_program'
AND "specific_name" ~* '^create_firewall_metahost_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TRUE to deny traffic, FALSE to allow'
WHERE "argument" = 'input_deny'
AND "specific_name" ~* '^create_firewall_metahost_rule_program(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_firewall_metahost_rule_program('Servers','SSH',TRUE);$$, "comment" = 'Create a firewall metahost rule from a common program registered in the application', "schema" = 'firewall'
WHERE "specific_name" ~* '^create_firewall_metahost_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The IP address to remove'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^remove_firewall_metahost_member(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_firewall_metahost_member('10.0.0.1');$$, "comment" = 'Remove an address from any metahost it might be attached to', "schema" = 'firewall'
WHERE "specific_name" ~* '^remove_firewall_metahost_member(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the metahost to remove'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^remove_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_firewall_metahost('Servers');$$, "comment" = 'Remove a metahost from the database. This will also erase all rules associated with its members.', "schema" = 'firewall'
WHERE "specific_name" ~* '^remove_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The metahost name this rule applied to'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^remove_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The port of the rule'
WHERE "argument" = 'input_port'
AND "specific_name" ~* '^remove_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TCP or UDP or BOTH'
WHERE "argument" = 'input_transport'
AND "specific_name" ~* '^remove_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_firewall_metahost_rule('Servers',22,'TCP');$$, "comment" = 'Delete a metahost rule and erase all references to it.', "schema" = 'firewall'
WHERE "specific_name" ~* '^remove_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the firewall system to remove'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^remove_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT pi.remove_firewall_system('Firewall1');$$, "comment" = 'Delete a firewall system from the database', "schema" = 'firewall'
WHERE "specific_name" ~* '^remove_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Address of the rule to remove'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^remove_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Port to affect'
WHERE "argument" = 'input_port'
AND "specific_name" ~* '^remove_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TCP or UDP or BOTH'
WHERE "argument" = 'input_transport'
AND "specific_name" ~* '^remove_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_firewall_rule('10.0.0.1',22,'TCP');$$, "comment" = 'Erase a standalone rule', "schema" = 'firewall'
WHERE "specific_name" ~* '^remove_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The address to remove the rule from'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^remove_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the program to act upon'
WHERE "argument" = 'input_program'
AND "specific_name" ~* '^remove_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_firewall_rule_program('10.0.0.1','SSH');$$, "comment" = 'Remove a firewall rule from a common program registered in the application', "schema" = 'firewall'
WHERE "specific_name" ~* '^remove_firewall_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The metahost name to remove the rule on'
WHERE "argument" = 'input_metahost'
AND "specific_name" ~* '^remove_firewall_metahost_rule_program(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the program to act upon'
WHERE "argument" = 'input_program'
AND "specific_name" ~* '^remove_firewall_metahost_rule_program(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_firewall_metahost_rule_program('Servers','SSH');$$, "comment" = 'Remove a firewall metahost rule from a common program registered in the application', "schema" = 'firewall'
WHERE "specific_name" ~* '^remove_firewall_metahost_rule_program(_)+([0-9])+$';

/* api.modify_firewall_default */
UPDATE "documentation"."arguments"
SET "comment" = 'The address to edit'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^modify_firewall_default(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Deny (TRUE) or allow (FALSE)'
WHERE "argument" = 'input_action'
AND "specific_name" ~* '^modify_firewall_default(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_firewall_default('10.0.0.1','TRUE');$$, "comment" = 'Modify the default firewall action', "schema" = 'firewall'
WHERE "specific_name" ~* '^modify_firewall_default(_)+([0-9])+$';

/* api.modify_firewall_metahost */

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the metahost to modify'
WHERE "argument" = 'input_old_name'
AND "specific_name" ~* '^modify_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_firewall_metahost(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_firewall_metahost('Servers','name','Server Cluster 1');$$, "comment" = 'Modify a firewall metahost', "schema" = 'firewall'
WHERE "specific_name" ~* '^modify_firewall_metahost(_)+([0-9])+$';

/* api.modify_firewall_metahost_rule */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the metahost'
WHERE "argument" = 'input_old_metahost'
AND "specific_name" ~* '^modify_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The port of the rule'
WHERE "argument" = 'input_old_port'
AND "specific_name" ~* '^modify_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The transport of the rule'
WHERE "argument" = 'input_old_transport'
AND "specific_name" ~* '^modify_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_firewall_metahost_rule(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_firewall_metahost_rule('Servers',22,'TCP','deny','false');$$, "comment" = 'Modify a firewall metahost rule', "schema" = 'firewall'
WHERE "specific_name" ~* '^modify_firewall_metahost_rule(_)+([0-9])+$';

/* api.modify_firewall_rule */
UPDATE "documentation"."arguments"
SET "comment" = 'The address of the host to modify'
WHERE "argument" = 'input_old_address'
AND "specific_name" ~* '^modify_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The port of the rule'
WHERE "argument" = 'input_old_port'
AND "specific_name" ~* '^modify_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The transport of the rule'
WHERE "argument" = 'input_old_transport'
AND "specific_name" ~* '^modify_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_firewall_rule(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_firewall_rule('10.0.0.1',22,'TCP','deny','false');$$, "comment" = 'Modify a standalone firewall rule', "schema" = 'firewall'
WHERE "specific_name" ~* '^modify_firewall_rule(_)+([0-9])+$';

/* api.modify_firewall_system */
UPDATE "documentation"."arguments"
SET "comment" = 'The subnet to get the firewall from'
WHERE "argument" = 'input_old_subnet'
AND "specific_name" ~* '^modify_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_firewall_system(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_firewall_system('10.0.0.0/24','software','Cisco IOS');$$, "comment" = 'Modify a firewall system', "schema" = 'firewall'
WHERE "specific_name" ~* '^modify_firewall_system(_)+([0-9])+$';

