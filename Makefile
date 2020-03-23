.if exists(rid.mk)
.include <rid.mk>
.endif

SERVICE = ldap${RID}
REGGAE_PATH = /usr/local/share/reggae
CBSD_WORKDIR != sysrc -n cbsd_workdir
PORTS = 389

post_setup_ansible:
	@echo "ldap_domain: ${FQDN}" >>ansible/group_vars/all

post_create:
.if !exists(${CBSD_WORKDIR}/jails-system/${SERVICE}/master_poststart.d/unbound.sh)
	@sed \
		-e "s:DOMAINFQDN:${FQDN}:g" \
		templates/unbound.sh.tpl >/tmp/unbound.sh
	@sudo mv /tmp/unbound.sh ${CBSD_WORKDIR}/jails-system/${SERVICE}/master_poststart.d/unbound.sh
	@chmod 755 ${CBSD_WORKDIR}/jails-system/${SERVICE}/master_poststart.d/unbound.sh
.endif

.include <${REGGAE_PATH}/mk/service.mk>
