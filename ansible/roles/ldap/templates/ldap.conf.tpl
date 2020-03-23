#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

TLS_REQCERT never
TLSCACertificateFile /usr/local/etc/openldap/certs/chain.pem
BASE	dc=ldap
URI	ldap://{{ service }}.{{ ldap_domain }}

#SIZELIMIT	12
#TIMELIMIT	15
#DEREF		never
