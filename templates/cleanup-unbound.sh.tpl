#!/bin/sh


UNBOUND_ROOT="/var/unbound"
ZONE_FILE="${UNBOUND_ROOT}/zones/${jname}.zone"
CONF_FILE="${UNBOUND_ROOT}/conf.d/${jname}.conf"

rm "${ZONE_FILE}" "${CONF_FILE}"
if [ "${jname}" != "ldap" ]; then
    ZONE_FILE="${UNBOUND_ROOT}/zones/ldap.zone"
    rm "${ZONE_FILE}"
fi

service local_unbound restart
