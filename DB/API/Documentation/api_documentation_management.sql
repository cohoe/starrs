UPDATE "documentation"."arguments"
SET "comment" = 'Where the message is coming from'
WHERE "argument" = 'input_source'
AND "specific_name" ~* '^create_log_entry(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Severity for viewing purposes'
WHERE "argument" = 'input_severity'
AND "specific_name" ~* '^create_log_entry(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The message to log'
WHERE "argument" = 'input_message'
AND "specific_name" ~* '^create_log_entry(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_log_entry('CLI','DEBUG','Doing something');$$, "comment" = 'Record an entry in the master log', "schema" = 'management'
WHERE "specific_name" ~* '^create_log_entry(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Directive to create'
WHERE "argument" = 'input_directive'
AND "specific_name" ~* '^create_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Value to assign to the new directive'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^create_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_site_configuration('EXAMPLE_OPTION','something');$$, "comment" = 'Enter a new site configuration directive in the table', "schema" = 'management'
WHERE "specific_name" ~* '^create_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Directive to remove'
WHERE "argument" = 'input_directive'
AND "specific_name" ~* '^remove_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_site_configuration('EXAMPLE_OPTION');$$, "comment" = 'Remove an existing site configuration directive', "schema" = 'management'
WHERE "specific_name" ~* '^remove_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Directive to modify'
WHERE "argument" = 'input_directive'
AND "specific_name" ~* '^modify_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'New value to set'
WHERE "argument" = 'input_value'
AND "specific_name" ~* '^modify_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_site_configuration('DNS_DEFAULT_ZONE','example.com');$$, "comment" = 'Modify an existing site configuration directive', "schema" = 'management'
WHERE "specific_name" ~* '^modify_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_current_user();$$, "comment" = 'Get the current authenticated user (who the application thinks you are)', "schema" = 'management'
WHERE "specific_name" ~* '^get_current_user(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_current_user_level();        $$, "comment" = 'Return the current privilege level of the user', "schema" = 'management'
WHERE "specific_name" ~* '^get_current_user_level(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The username to query for'
WHERE "argument" = '$1'
AND "specific_name" ~* '^get_ldap_user_level(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$$$, "comment" = 'Query the configured LDAP server to determine the access rights of the current user. They can either be an ADMIN, a USER, or a PROGRAM. Note: The word PROGRAM was chosen rather than SERVICE because a message can be printed "Greetings Program!". I love Tron. ', "schema" = 'management'
WHERE "specific_name" ~* '^get_ldap_user_level(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Directive to get the value of'
WHERE "argument" = 'input_directive'
AND "specific_name" ~* '^get_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_site_configuration('DNS_DEFAULT_ZONE');$$, "comment" = 'Get the value of a configured site directive', "schema" = 'management'
WHERE "specific_name" ~* '^get_site_configuration(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'String to parse'
WHERE "argument" = 'input'
AND "specific_name" ~* '^validate_nospecial(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.sanitize_general('This string has &*@!&$*#&');$$, "comment" = 'Validation with no special characters allowed. A-Z, 0-9 only.', "schema" = 'management'
WHERE "specific_name" ~* '^validate_nospecial(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'String to parse'
WHERE "argument" = 'input'
AND "specific_name" ~* '^validate_name(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.validate_name('This string has &*@!&$*#&');$$, "comment" = 'Validation with characters allowed for resource names. ', "schema" = 'management'
WHERE "specific_name" ~* '^validate_name(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the system to renew'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^renew_system(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.renew_system('server1');$$, "comment" = 'Systems must be renewed every year or they and all their records expire and are removed. ', "schema" = 'management'
WHERE "specific_name" ~* '^renew_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the process'
WHERE "argument" = 'input_process'
AND "specific_name" ~* '^lock_process(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.lock_process('NSUPDATE');$$, "comment" = 'Lock a process for an output job run', "schema" = 'management'
WHERE "specific_name" ~* '^lock_process(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the process'
WHERE "argument" = 'input_process'
AND "specific_name" ~* '^unlock_process(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.unlock_process('NSUPDATE');$$, "comment" = 'Unlock a job process', "schema" = 'management'
WHERE "specific_name" ~* '^unlock_process(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The user who is logging in'
WHERE "argument" = 'input_username'
AND "specific_name" ~* '^initialize(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.initialize('john.doe');$$, "comment" = 'Load all user privileges and set username in the database permissioning system. This function must be called at the start of every database connection. ', "schema" = 'management'
WHERE "specific_name" ~* '^initialize(_)+([0-9])+$';

/* api.deinitialize */
UPDATE "documentation"."functions"
SET "example" = $$SELECT api.deinitialize();$$, "comment" = 'Remove all user privileges for reset to a different user', "schema" = 'management'
WHERE "specific_name" ~* '^deinitialize(_)+([0-9])+$';