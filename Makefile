.if exists(rid.mk)
.include <rid.mk>
.endif

SERVICE = ldap${RID}
REGGAE_PATH = /usr/local/share/reggae
BACKEND != reggae get-config BACKEND
BASE_WORKDIR != reggae get-config BASE_WORKDIR
CBSD_WORKDIR != sysrc -n cbsd_workdir
DOMAIN != reggae get-config DOMAIN
PORTS = 389

post_setup_ansible:
	@echo "ldap_domain: ${FQDN}" >>ansible/group_vars/all
.if defined(RID)
	@echo "rid: ${RID}" >>ansible/group_vars/all
.endif

set_fake_dns:
	@sudo sed -i "" -e "s/FQDN/${SERVICE}.${FQDN}/g" -e "s/IPV6/${IPV6}/g" -e "s/IP/${IP}/g" /var/unbound/zones/ldap.zone

fake_dns:
	@sudo cp templates/conf.tpl /var/unbound/conf.d/ldap.conf
	@sudo cp templates/zone.tpl /var/unbound/zones/ldap.zone
	@sudo sed -i "" -e "s/FQDN/${SERVICE}.${FQDN}/g" /var/unbound/conf.d/ldap.conf
	@${MAKE} ${MAKEFLAGS} IPV6=`sudo jexec ldap ifconfig eth0 | grep 'inet6 ' | grep -v 'fe80' | cut -f 2 -d ' '` IP=`drill ${SERVICE}.${DOMAIN} | grep ^${SERVICE}.${DOMAIN} | awk '{print $$5}'` set_fake_dns
	@sudo service local_unbound restart

unfake_dns:
	@sudo rm -f /var/unbound/conf.d/ldap.conf /var/unbound/zones/ldap.zone
	@sudo service local_unbound restart

.include <${REGGAE_PATH}/mk/service.mk>
