/* api_documentation_dhcp.sql */

/* create_dhcp_class */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the class to be created'
WHERE "argument" = 'input_class'
AND "specific_name" ~* '^create_dhcp_class(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the class (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_dhcp_class(_)+([0-9])+$';

/* create_dhcp_class_option */
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

/* create_dhcp_subnet_option */
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

/* create_dhcp_subnet_setting */
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

/* create_dhcp_range_setting */
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