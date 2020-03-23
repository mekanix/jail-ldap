#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

TLSCACertificateFile /usr/local/etc/openldap/certs/chain.pem
TLSCertificateFile /usr/local/etc/openldap/certs/fullchain.pem
TLSCertificateKeyFile /usr/local/etc/openldap/certs/privkey.pem
BASE	dc=ldap
URI	ldap://{{ service }}.{{ ldap_domain }}

#SIZELIMIT	12
#TIMELIMIT	15
#DEREF		never
