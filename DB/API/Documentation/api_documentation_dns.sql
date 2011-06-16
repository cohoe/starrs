/* create_dns_key */
UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dns_key('example_key','oi0idf0sajfke9ur93',NULL,'example.com zone key');$$, "comment" = 'Create a new DNS key. ', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_key(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The name of the key to create'
WHERE "argument" = 'input_keyname'
AND "specific_name" ~* '^create_dns_key(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The string that is the key'
WHERE "argument" = 'input_key'
AND "specific_name" ~* '^create_dns_key(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The owner of the key (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_key(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the key (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_dns_key(_)+([0-9])+$';

/* create_dns_zone */
UPDATE "documentation"."arguments"
SET "comment" = 'The domain to create'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The DNS key to use for updates'
WHERE "argument" = 'input_keyname'
AND "specific_name" ~* '^create_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Is this a forward or reverse zone'
WHERE "argument" = 'input_forward'
AND "specific_name" ~* '^create_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Can other uses create records in this zone'
WHERE "argument" = 'input_shared'
AND "specific_name" ~* '^create_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The owning username (or NULL for current)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'A comment on the zone (or NULL for no comment)'
WHERE "argument" = 'input_comment'
AND "specific_name" ~* '^create_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$EXAMPLE api.create_dns_zone('example.com','example_key',TRUE,TRUE,NULL,'example.com domain');$$, "comment" = 'Create a new DNS zone', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_zone(_)+([0-9])+$';

/* create_dns_address */
UPDATE "documentation"."arguments"
SET "comment" = 'The IP address of this record'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^create_dns_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The specific hostname that owns the record'
WHERE "argument" = 'input_hostname'
AND "specific_name" ~* '^create_dns_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The DNS domain the record is for'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_dns_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Time to Live (or NULL for the default value)'
WHERE "argument" = 'input_ttl'
AND "specific_name" ~* '^create_dns_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The username who owns this resource'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_address(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dns_address('10.0.0.1', 'hostname', 'example.com', NULL, 'john.doe');$$, "comment" = 'Register a new host address record', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_address(_)+([0-9])+$';

/* create_dns_mailserver */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the mailserver (from "dns"."a")'
WHERE "argument" = 'input_hostname'
AND "specific_name" ~* '^create_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The domain of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The preference level of the record (lower is more)'
WHERE "argument" = 'input_preference'
AND "specific_name" ~* '^create_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Time to Live (or NULL for default)'
WHERE "argument" = 'input_ttl'
AND "specific_name" ~* '^create_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Owner of the record (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dns_mailserver('mail','example.com',10,36500,'root');$$, "comment" = 'Create a new MX record for a mailserver', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_mailserver(_)+([0-9])+$';

/* create_dns_nameserver */
UPDATE "documentation"."arguments"
SET "comment" = 'Name of the nameserver'
WHERE "argument" = 'input_hostname'
AND "specific_name" ~* '^create_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Is this the primary nameserver for the zone'
WHERE "argument" = 'input_isprimary'
AND "specific_name" ~* '^create_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Time to Live (or NULL for default)'
WHERE "argument" = 'input_ttl'
AND "specific_name" ~* '^create_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Owner of the record (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dns_nameserver('ns1','example.com',TRUE,NULL,NULL);$$, "comment" = 'Creata a new NS record for a nameserver', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_nameserver(_)+([0-9])+$';

/* create_dns_srv */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of this record'
WHERE "argument" = 'input_alias'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The target A or AAAA of this record'
WHERE "argument" = 'input_target'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of this record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'SRV priority (lower is more)'
WHERE "argument" = 'input_priority'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'SRV weight (higher is more)'
WHERE "argument" = 'input_weight'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The port of the service'
WHERE "argument" = 'input_port'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Time to Live (or NULL for default)'
WHERE "argument" = 'input_ttl'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Owner of the record (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dns_srv('_ldap._tcp','ldap','example.com',0,0,389,NULL,'root');$$, "comment" = 'Create a DNS service record. This does not provide syntax checking of your record, so you must ensure that the alias behaves the way you expected. ', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_srv(_)+([0-9])+$';

/* create_dns_cname */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the new record'
WHERE "argument" = 'input_alias'
AND "specific_name" ~* '^create_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The target of this pointer'
WHERE "argument" = 'input_target'
AND "specific_name" ~* '^create_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Time to Live (or NULL for default)'
WHERE "argument" = 'input_ttl'
AND "specific_name" ~* '^create_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Owner of the record (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dns_cname('www','webserver','example.com',NULL);$$, "comment" = 'Create a new alias name record', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_cname(_)+([0-9])+$';

/* create_dns_txt */
UPDATE "documentation"."arguments"
SET "comment" = 'The hostname of the record'
WHERE "argument" = 'input_hostname'
AND "specific_name" ~* '^create_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^create_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The text to be placed in the record'
WHERE "argument" = 'input_text'
AND "specific_name" ~* '^create_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'TXT or SPF (subtle differences)'
WHERE "argument" = 'input_type'
AND "specific_name" ~* '^create_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Time to Live (or NULL for default)'
WHERE "argument" = 'input_ttl'
AND "specific_name" ~* '^create_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Owner of the record (or NULL for current user)'
WHERE "argument" = 'input_owner'
AND "specific_name" ~* '^create_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.create_dns_txt('webserver','example.com','located in a black hole','TXT',NULL,NULL);$$, "comment" = 'Create a new TXT or SPF record', "schema" = 'dns'
WHERE "specific_name" ~* '^create_dns_txt(_)+([0-9])+$';

/* remove_dns_key */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the key to remove'
WHERE "argument" = 'input_keyname'
AND "specific_name" ~* '^remove_dns_key(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_key('example_key');$$, "comment" = 'Remove a DNS key from use', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_key(_)+([0-9])+$';

/* remove_dns_zone */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the zone to remove'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^remove_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_zone('example.com');$$, "comment" = 'Remove a DNS zone from the database', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_zone(_)+([0-9])+$';

/* remove_dns_address */
UPDATE "documentation"."arguments"
SET "comment" = 'The address of the record to remove'
WHERE "argument" = 'input_address'
AND "specific_name" ~* '^remove_dns_address(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_address('10.0.0.1');$$, "comment" = 'Remove a host address record', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_address(_)+([0-9])+$';

/* remove_dns_mailserver */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the mailserver'
WHERE "argument" = 'input_hostname'
AND "specific_name" ~* '^remove_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^remove_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_mailserver('mail','example.com');$$, "comment" = 'Remove a MX record for a mailserver', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_mailserver(_)+([0-9])+$';

/* remove_dns_nameserver */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the nameserver'
WHERE "argument" = 'input_hostname'
AND "specific_name" ~* '^remove_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^remove_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_nameserver('ns1','example.com');$$, "comment" = 'Remove a NS nameserver record', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_nameserver(_)+([0-9])+$';

/* remove_dns_srv */
UPDATE "documentation"."arguments"
SET "comment" = 'The alias of the record'
WHERE "argument" = 'input_alias'
AND "specific_name" ~* '^remove_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The target of the record'
WHERE "argument" = 'input_target'
AND "specific_name" ~* '^remove_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^remove_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_srv('_ldap._tcp','ldap','example.com');$$, "comment" = 'Remove a service record', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_srv(_)+([0-9])+$';

/* remove_dns_cname */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the record'
WHERE "argument" = 'input_alias'
AND "specific_name" ~* '^remove_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The target of the pointer'
WHERE "argument" = 'input_target'
AND "specific_name" ~* '^remove_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^remove_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_cname('www','webserver','example.com');$$, "comment" = 'Remove an alias name record', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_cname(_)+([0-9])+$';

/* remove_dns_txt */
UPDATE "documentation"."arguments"
SET "comment" = 'Hostname of the record to remove'
WHERE "argument" = 'input_hostname'
AND "specific_name" ~* '^remove_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Zone of the record'
WHERE "argument" = 'input_zone'
AND "specific_name" ~* '^remove_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Type of record to remove'
WHERE "argument" = 'input_type'
AND "specific_name" ~* '^remove_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.remove_dns_txt('webserver','example.com','TXT');$$, "comment" = 'Remove a TXT or SPF record', "schema" = 'dns'
WHERE "specific_name" ~* '^remove_dns_txt(_)+([0-9])+$';

/* get_reverse_domain */
UPDATE "documentation"."arguments"
SET "comment" = 'An IP address (either v4 or v6)'
WHERE "argument" = '$1'
AND "specific_name" ~* '^get_reverse_domain(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.get_reverse_domain('2001:db0::dead:beef:cafe');$$, "comment" = 'Generate the reverse DNS string from a given IP address. This uses an external Perl module to easily return the reverse string.', "schema" = 'dns'
WHERE "specific_name" ~* '^get_reverse_domain(_)+([0-9])+$';

/* validate_domain */
UPDATE "documentation"."arguments"
SET "comment" = 'Hostname to check (or NULL for Domain check only)'
WHERE "argument" = 'hostname'
AND "specific_name" ~* '^validate_domain(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'Domain to checl (or NULL for Hostname check only)'
WHERE "argument" = 'domain'
AND "specific_name" ~* '^validate_domain(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.validate_domain('server','example.com');$$, "comment" = 'Validate a DNS hostname or domain. Can take either a hostname, domain, or FQDN. ', "schema" = 'dns'
WHERE "specific_name" ~* '^validate_domain(_)+([0-9])+$';

/* api.validate_srv */
UPDATE "documentation"."arguments"
SET "comment" = 'SRV record to validate'
WHERE "argument" = '$1'
AND "specific_name" ~* '^validate_srv(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.validate_srv('_ldap._tcp');$$, "comment" = 'Validate a DNS SRV record against known rules. ', "schema" = 'dns'
WHERE "specific_name" ~* '^validate_srv(_)+([0-9])+$';

/* api.modify_dns_address */
UPDATE "documentation"."arguments"
SET "comment" = 'The IP address of the record'
WHERE "argument" = 'input_old_address'
AND "specific_name" ~* '^modify_dns_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_address(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_address(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_address('10.0.0.1','hostname','server2');$$, "comment" = 'Modify a DNS address record', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_address(_)+([0-9])+$';

/* api.modify_dns_cname */
UPDATE "documentation"."arguments"
SET "comment" = 'The old alias name'
WHERE "argument" = 'input_old_alias'
AND "specific_name" ~* '^modify_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_old_zone'
AND "specific_name" ~* '^modify_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_cname(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_cname('www','example.com','hostname','webserver2');$$, "comment" = 'Modify a DNS CNAME pointer record', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_cname(_)+([0-9])+$';

/* api.modify_dns_key */
UPDATE "documentation"."arguments"
SET "comment" = 'The name of the key to modify'
WHERE "argument" = 'input_old_keyname'
AND "specific_name" ~* '^modify_dns_key(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_key(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_key(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_key('examplekey','keyname','subexamplekey');$$, "comment" = 'Modify a DNS key', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_key(_)+([0-9])+$';

/* api.modify_dns_mailserver */
UPDATE "documentation"."arguments"
SET "comment" = 'The hostname of the record'
WHERE "argument" = 'input_old_hostname'
AND "specific_name" ~* '^modify_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_old_zone'
AND "specific_name" ~* '^modify_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_mailserver(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_mailserver('mail','example.com','preference','20');$$, "comment" = 'Modify a DNS MX record', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_mailserver(_)+([0-9])+$';

/* api.modify_dns_nameserver */
UPDATE "documentation"."arguments"
SET "comment" = 'The hostname of the record'
WHERE "argument" = 'input_old_hostname'
AND "specific_name" ~* '^modify_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_old_zone'
AND "specific_name" ~* '^modify_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_nameserver(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_nameserver('mail','example.com','preference','20');$$, "comment" = 'Modify a DNS NS record', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_nameserver(_)+([0-9])+$';

/* api.modify_dns_srv */
UPDATE "documentation"."arguments"
SET "comment" = 'The old alias record'
WHERE "argument" = 'input_old_alias'
AND "specific_name" ~* '^modify_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_old_zone'
AND "specific_name" ~* '^modify_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_srv(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_srv('_ldap._tcp','example.com','hostname','ldap2');$$, "comment" = 'Modify a DNS SRV record within a zone', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_srv(_)+([0-9])+$';

/* api.modify_dns_txt */
UPDATE "documentation"."arguments"
SET "comment" = 'The hostname of the record'
WHERE "argument" = 'input_old_hostname'
AND "specific_name" ~* '^modify_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The zone of the record'
WHERE "argument" = 'input_old_zone'
AND "specific_name" ~* '^modify_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_txt(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_txt('tron','example.com','text','fights for the users');$$, "comment" = 'Modify a DNS TXT entry for a record', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_txt(_)+([0-9])+$';

/* api.modify_dns_zone */
UPDATE "documentation"."arguments"
SET "comment" = 'The zone to modify'
WHERE "argument" = 'input_old_zone'
AND "specific_name" ~* '^modify_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The field to modify'
WHERE "argument" = 'input_field'
AND "specific_name" ~* '^modify_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."arguments"
SET "comment" = 'The value of the new field'
WHERE "argument" = 'input_new_value'
AND "specific_name" ~* '^modify_dns_zone(_)+([0-9])+$';

UPDATE "documentation"."functions"
SET "example" = $$SELECT api.modify_dns_zone('example.com','zone','example.biz');$$, "comment" = 'Modify a DNS zone', "schema" = 'dns'
WHERE "specific_name" ~* '^modify_dns_zone(_)+([0-9])+$';