#!/bin/sh


NAME="@"
DOMAIN=`reggae get-config DOMAIN`
JAILFQDN="${jname}.${DOMAIN}"
FQDN="${jname}.DOMAINFQDN"
IP=`/usr/bin/drill ${JAILFQDN} | grep "^${JAILFQDN}\." | awk '{print $5}'`
JAILFQDN=${jname}.LDAPFQDN
UNBOUND_ROOT="/var/unbound"
ZONE_FILE="${UNBOUND_ROOT}/zones/${jname}.zone"
CONF_FILE="${UNBOUND_ROOT}/conf.d/${jname}.conf"

if [ ! -e ${ZONE_FILE} ]; then
    cat >${ZONE_FILE} <<EOF
${FQDN}. SOA ${FQDN}. hostmaster.${FQDN}. (
                  1998092901  ; Serial number
                  60          ; Refresh
                  1800        ; Retry
                  3600        ; Expire
                  1728 )      ; Minimum TTL
${FQDN}.            NS      ${FQDN}.

\$ORIGIN ${FQDN}
EOF
    chown unbound:unbound ${ZONE_FILE}

    cat >${CONF_FILE} <<EOF
auth-zone:
    name: "${FQDN}"
    zonefile: "zones/${jname}.zone"
EOF
    if [ "${jname}" != "ldap" ]; then
        ZONE_FILE="${UNBOUND_ROOT}/zones/ldap.zone"
        cat >>${CONF_FILE} <<EOF

auth-zone:
    name: "ldap.DOMAINFQDN"
    zonefile: "zones/ldap.zone"
EOF
        FQDN="ldap.DOMAINFQDN"
        cat >${ZONE_FILE} <<EOF
${FQDN}. SOA ${FQDN}. hostmaster.${FQDN}. (
                  1998092901  ; Serial number
                  60          ; Refresh
                  1800        ; Retry
                  3600        ; Expire
                  1728 )      ; Minimum TTL
${FQDN}.            NS      ${FQDN}.

\$ORIGIN ${FQDN}
EOF
        chown unbound:unbound ${ZONE_FILE}
    fi
    chown unbound:unbound ${CONF_FILE}
fi

ZONE_FILE="${UNBOUND_ROOT}/zones/${jname}.zone"
CONF_FILE="${UNBOUND_ROOT}/conf.d/${jname}.conf"
/usr/bin/sed -i "" "/^.* *A *${IP}$/d" "${ZONE_FILE}"
/usr/bin/sed -i "" "/^@ *A *.*$/d" "${ZONE_FILE}"
/bin/echo "@    A   ${IP}" >>"${ZONE_FILE}"

if [ "${jname}" != "ldap" ]; then
    ZONE_FILE="${UNBOUND_ROOT}/zones/ldap.zone"
    CONF_FILE="${UNBOUND_ROOT}/conf.d/ldap.conf"
    /usr/bin/sed -i "" "/^.* *A *${IP}$/d" "${ZONE_FILE}"
    /usr/bin/sed -i "" "/^@ *A *.*$/d" "${ZONE_FILE}"
    /bin/echo "@    A   ${IP}" >>"${ZONE_FILE}"
fi

service local_unbound restart
