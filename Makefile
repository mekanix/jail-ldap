SERVICE = ldap
REGGAE_PATH = /usr/local/share/reggae
PORTS = 389

post_setup_ansible:
	@echo "ldap_domain: ${FQDN}" >>ansible/group_vars/all

.include <${REGGAE_PATH}/mk/service.mk>
