CREATE LANGUAGE 'plpython2u';

CREATE TYPE "libvirt"."domain_data" AS ("domain" TEXT, "state" TEXT, "definition" TEXT);

DROP FUNCTION api.get_libvirt_domains(text, text);
CREATE OR REPLACE FUNCTION "api"."get_libvirt_domains"(sysuri text, syspassword text) RETURNS SETOF "libvirt"."domain_data" AS $$
	#!/usr/bin/python

	import libvirt
	import sys

	def request_credentials(credentials, data):
		for credential in credentials:
			if credential[0] == libvirt.VIR_CRED_AUTHNAME:
				#credential[4] = sysuser
				return 0
			elif credential[0] == libvirt.VIR_CRED_NOECHOPROMPT:
				credential[4] = syspassword
			else:
				return -1

		return 0

	auth = [[libvirt.VIR_CRED_AUTHNAME, libvirt.VIR_CRED_NOECHOPROMPT], request_credentials, None]
	if syspassword == None:
		conn = libvirt.open(sysuri)
	else:
		conn = libvirt.openAuth(sysuri, auth, 0)

	if conn == None:
		sys.exit("Unable to connect")
	
	state_names = { libvirt.VIR_DOMAIN_RUNNING  : "running",
		libvirt.VIR_DOMAIN_BLOCKED  : "idle",
		libvirt.VIR_DOMAIN_PAUSED   : "paused",
		libvirt.VIR_DOMAIN_SHUTDOWN : "in shutdown",
		libvirt.VIR_DOMAIN_SHUTOFF  : "shut off",
		libvirt.VIR_DOMAIN_CRASHED  : "crashed",
		libvirt.VIR_DOMAIN_NOSTATE  : "no state" }

	domNames = ()
	for domID in conn.listDomainsID():
		domain = conn.lookupByID(domID)
		domNames += ([domain.name(), state_names[domain.info()[0]], domain.XMLDesc(0)],)

	for dom in conn.listDefinedDomains():
		domain = conn.lookupByName(dom)
		domNames += ([domain.name(), state_names[domain.info()[0]], domain.XMLDesc(0)],)
	
	conn.close()
	return domNames
$$ LANGUAGE 'plpython2u';

CREATE OR REPLACE FUNCTION "api"."control_libvirt_domain"(sysuri text, syspassword text, domain text, action text) RETURNS TEXT AS $$
	#!/usr/bin/python
	
	import libvirt
	import sys

	def request_credentials(credentials, data):
		for credential in credentials:
			if credential[0] == libvirt.VIR_CRED_AUTHNAME:
				return 0
			elif credential[0] == libvirt.VIR_CRED_NOECHOPROMPT:
				credential[4] = syspassword
			else:
				return -1

		return 0

	auth = [[libvirt.VIR_CRED_AUTHNAME, libvirt.VIR_CRED_NOECHOPROMPT], request_credentials, None]
	conn = libvirt.openAuth(sysuri, auth, 0)

	dom = conn.lookupByName(domain)
	
	if action == 'destroy':
		dom.destroy()
	elif action == 'shutdown':
		dom.shutdown()
	elif action == 'reboot':
		dom.reboot(0)
	elif action == 'reset':
		dom.reset(0)
	elif action == 'resume':
		dom.resume()
	elif action == 'restore':
		dom.restore()
	elif action == 'suspend':
		dom.suspend()
	elif action == 'save':
		dom.save()
	elif action == 'create':
		dom.create()
	else:
		sys.exit("Invalid action")

	conn.close()
	state_names = { libvirt.VIR_DOMAIN_RUNNING  : "running",
		libvirt.VIR_DOMAIN_BLOCKED  : "idle",
		libvirt.VIR_DOMAIN_PAUSED   : "paused",
		libvirt.VIR_DOMAIN_SHUTDOWN : "in shutdown",
		libvirt.VIR_DOMAIN_SHUTOFF  : "shut off",
		libvirt.VIR_DOMAIN_CRASHED  : "crashed",
		libvirt.VIR_DOMAIN_NOSTATE  : "no state" }
	return state_names[dom.info()[0]]
$$ LANGUAGE 'plpython2u';

CREATE OR REPLACE FUNCTION "api"."get_libvirt_domain_state"(sysuri text, syspassword text, domain text) RETURNS TEXT AS $$
	#!/usr/bin/python
	
	import libvirt
	import sys

	def request_credentials(credentials, data):
		for credential in credentials:
			if credential[0] == libvirt.VIR_CRED_AUTHNAME:
				return 0
			elif credential[0] == libvirt.VIR_CRED_NOECHOPROMPT:
				credential[4] = syspassword
			else:
				return -1

		return 0

	auth = [[libvirt.VIR_CRED_AUTHNAME, libvirt.VIR_CRED_NOECHOPROMPT], request_credentials, None]
	conn = libvirt.openAuth(sysuri, auth, 0)

	dom = conn.lookupByName(domain)

	conn.close()
	state_names = { libvirt.VIR_DOMAIN_RUNNING  : "running",
		libvirt.VIR_DOMAIN_BLOCKED  : "idle",
		libvirt.VIR_DOMAIN_PAUSED   : "paused",
		libvirt.VIR_DOMAIN_SHUTDOWN : "in shutdown",
		libvirt.VIR_DOMAIN_SHUTOFF  : "shut off",
		libvirt.VIR_DOMAIN_CRASHED  : "crashed",
		libvirt.VIR_DOMAIN_NOSTATE  : "no state" }
	return state_names[dom.info()[0]]
$$ LANGUAGE 'plpython2u';
