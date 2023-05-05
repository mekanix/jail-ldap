.if exists(rid.mk)
.include <rid.mk>
.endif

SERVICE = ldap${RID}
REGGAE_PATH = /usr/local/share/reggae
BACKEND != reggae get-config BACKEND
BASE_WORKDIR != reggae get-config BASE_WORKDIR
CBSD_WORKDIR != sysrc -n cbsd_workdir 2>/dev/null || true
DOMAIN != reggae get-config DOMAIN
PORTS = 389

post_setup_ansible:
	@echo "ldap_domain: ${FQDN}" >>ansible/group_vars/all
.if defined(RID)
	@echo "rid: ${RID}" >>ansible/group_vars/all
.endif

.include <${REGGAE_PATH}/mk/service.mk>
