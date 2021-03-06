.if exists(rid.mk)
.include <rid.mk>
.endif

SERVICE = ldap${RID}
REGGAE_PATH = /usr/local/share/reggae
CBSD_WORKDIR != sysrc -n cbsd_workdir
PORTS = 389

post_setup_ansible:
	@echo "ldap_domain: ${FQDN}" >>ansible/group_vars/all
.if defined(RID)
	@echo "rid: ${RID}" >>ansible/group_vars/all
.endif

post_create:
.if !exists(${CBSD_WORKDIR}/jails-system/${SERVICE}/master_poststart.d/unbound.sh)
	@sed \
		-e "s:DOMAINFQDN:${FQDN}:g" \
		templates/unbound.sh.tpl >/tmp/unbound.sh
	@sudo mv /tmp/unbound.sh ${CBSD_WORKDIR}/jails-system/${SERVICE}/master_poststart.d/unbound.sh
	@sudo chmod 755 ${CBSD_WORKDIR}/jails-system/${SERVICE}/master_poststart.d/unbound.sh
	@sudo chown root:wheel ${CBSD_WORKDIR}/jails-system/${SERVICE}/master_poststart.d/unbound.sh
.endif
.if !exists(${CBSD_WORKDIR}/jails-system/${SERVICE}/remove.d/cleanup-unbound.sh)
	@sudo cp templates/cleanup-unbound.sh.tpl ${CBSD_WORKDIR}/jails-system/${SERVICE}/remove.d/cleanup-unbound.sh
	@sudo chmod 755 ${CBSD_WORKDIR}/jails-system/${SERVICE}/remove.d/cleanup-unbound.sh
.endif

.include <${REGGAE_PATH}/mk/service.mk>
