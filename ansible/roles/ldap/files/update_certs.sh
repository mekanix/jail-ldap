#!/bin/sh

DOMAIN="$1"
if [ -z "${DOMAIN}" ]; then
  echo "Usage $0 <domain>" >&2
  exit 1
fi

PRIVKEY=/usr/local/etc/openldap/certs/privkey.pem
SHOULD_UPDATE=no
CERT_DIFF="dummy"

if [ -e ${PRIVKEY} ]; then
  CERT_DIFF=`diff /etc/certs/${DOMAIN}/privkey.pem ${PRIVKEY}`
fi


if [ ! -z "${CERT_DIFF}" ]; then
  cat /etc/certs/${DOMAIN}/privkey.pem >/usr/local/etc/openldap/certs/privkey.pem
  cat /etc/certs/${DOMAIN}/chain.pem >/usr/local/etc/openldap/certs/chain.pem
  cat /etc/certs/${DOMAIN}/fullchain.pem >/usr/local/etc/openldap/certs/fullchain.pem
  chown ldap:ldap /usr/local/etc/openldap/certs/*.pem
  chmod 600 /usr/local/etc/openldap/certs/*.pem
  service slapd restart
fi
exit 0
