UPDATE "documentation"."arguments"
SET "comment" = 'Name of the system'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^create_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Owning user (NULL for current authenticated user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Server, Desktop, Laptop, etc'
WHERE "argument" = 'input_type'
AND "specific_name" ~* '^create_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Primary operating system'
WHERE "argument" = 'input_os_name'
AND "specific_name" ~* '^create_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Comment on the system (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_system(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_system('Server1',NULL,'Server','Windows Server 2003','Windows webserver');$$, "comment" = 'Register a new system on the network. There was discussion of allowing multiple operating systems to be associated, however this feature was removed due to unncessesary complexity. ', "schema" = 'systems'
WHERE "specific_name" ~* '^create_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the system to create the interface on'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^create_interface(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'MAC address of the interface'
WHERE "argument" = 'input_mac'
AND "specific_name" ~* '^create_interface(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Comment on the interface (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_interface(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_interface('Server1','00:09:6b:12:34:56',NULL);$$, "comment" = 'Create an interface on a system', "schema" = 'systems'
WHERE "specific_name" ~* '^create_interface(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'MAC address to associate with'
WHERE "argument" = 'input_mac'
AND "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Name of the interface'
WHERE "argument" = 'input_name'
AND "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Address to register'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Configuration type of the address'
WHERE "argument" = 'input_config'
AND "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Class of the configuration (or NULL for default)'
WHERE "argument" = 'input_class'
AND "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Is this address the primary of the interface'
WHERE "argument" = 'input_isprimary'
AND "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Comment on the address (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_interface_address('00:09:6b:12:34:56', 'Local Area Connection','10.0.0.1','DHCP',NULL,TRUE,'Main network');$$, "comment" = 'Associate an address with an interface by specifying the IP address', "schema" = 'systems'
WHERE "specific_name" ~* '^create_interface_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the system to remove'
WHERE "argument" = 'input_system_name'
AND "specific_name" ~* '^remove_system(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_system('Server1');$$, "comment" = 'Remove a system (and all associated records)', "schema" = 'systems'
WHERE "specific_name" ~* '^remove_system(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'MAC address of the interface'
WHERE "argument" = 'input_mac'
AND "specific_name" ~* '^remove_interface(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_interface('00:09:6b:12:34:56');$$, "comment" = 'Remove an interface from a system', "schema" = 'systems'
WHERE "specific_name" ~* '^remove_interface(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'IP address to deregister'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^remove_interface_address(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_interface_address('10.0.0.1');$$, "comment" = 'Remove an associated address from an interface', "schema" = 'systems'
WHERE "specific_name" ~* '^remove_interface_address(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_system_types();$$, "comment" = 'Get a list of all the available system types', "schema" = 'systems'
WHERE "specific_name" ~* '^get_system_types(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_operating_systems();$$, "comment" = 'Get a list of all available operating systems', "schema" = 'systems'
WHERE "specific_name" ~* '^get_operating_systems(_)+([0-9])+$';

/* api.get_interface_address_owner */
UPDATE "documentation"."arguments"
SET "comment" = 'IP address to check'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^get_interface_address_owner(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_interface_address_owner('10.0.0.1');$$, "comment" = 'Get the owner of a configured address', "schema" = 'systems'
WHERE "specific_name" ~* '^get_interface_address_owner(_)+([0-9])+$';