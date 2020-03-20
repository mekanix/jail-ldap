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
  chown unbound:unbound ${CONF_FILE}
fi

/usr/bin/sed -i "" "/^.* *A *${IP}$/d" "${ZONE_FILE}"
/usr/bin/sed -i "" "/^@ *A *.*$/d" "${ZONE_FILE}"
/bin/echo "@    A   ${IP}" >>"${ZONE_FILE}"
service local_unbound restart
