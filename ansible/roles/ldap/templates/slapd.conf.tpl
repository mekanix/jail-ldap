#
# See slapd.conf(5) for details on configuration options.
# This file should NOT be world readable.
#
include		/usr/local/etc/openldap/schema/core.schema
include		/usr/local/etc/openldap/schema/cosine.schema
include		/usr/local/etc/openldap/schema/inetorgperson.schema
include		/usr/local/etc/openldap/schema/nis.schema
include		/usr/local/etc/openldap/schema/opendkim.schema
include		/usr/local/etc/openldap/schema/idnext.schema
include		/usr/local/etc/openldap/schema/pmi.schema


# Define global ACLs to disable default read access.

# Do not enable referrals until AFTER you have a working directory
# service AND an understanding of referrals.
#referral	ldap://root.openldap.org

pidfile		/var/run/openldap/slapd.pid
argsfile	/var/run/openldap/slapd.args

# Load dynamic backend modules:
modulepath	/usr/local/libexec/openldap
moduleload	back_mdb
moduleload	memberof
# moduleload	refint
# moduleload	back_ldap

overlay			memberof
memberof-group-oc	groupOfUniqueNames
memberof-member-ad	uniqueMember
memberof-memberof-ad	memberOf
#memberof-refint		TRUE

#overlay			refint
#refint_attributes	memberOf uniqueMember

TLSCACertificateFile /usr/local/etc/openldap/certs/chain.pem
TLSCertificateFile /usr/local/etc/openldap/certs/fullchain.pem
TLSCertificateKeyFile /usr/local/etc/openldap/certs/privkey.pem

# Sample security restrictions
#	Require integrity protection (prevent hijacking)
#	Require 112-bit (3DES or better) encryption for updates
#	Require 63-bit encryption for simple bind
# security ssf=1 update_ssf=112 simple_bind=64
security ssf=128 tls=1

include		/usr/local/etc/openldap/slapd-acl.conf

#######################################################################
# MDB database definitions
#######################################################################

database config
rootdn "cn=root,cn=config"
include		/usr/local/etc/openldap/slapd-secret.conf

database	mdb
suffix		"dc=ldap"
rootdn		"cn=root,dc=ldap"
# Cleartext passwords, especially for the rootdn, should
# be avoid.  See slappasswd(8) and slapd.conf(5) for details.
# Use of strong authentication encouraged.
# The database directory MUST exist prior to running slapd AND
# should only be accessible by the slapd and slap tools.
# Mode 700 recommended.
directory	/var/db/openldap-data
# Indices to maintain
index	objectClass,mail,uidNumber,gidNumber,cn,uid	eq
include		/usr/local/etc/openldap/slapd-secret.conf
include		/usr/local/etc/openldap/slapd-multimaster.conf
