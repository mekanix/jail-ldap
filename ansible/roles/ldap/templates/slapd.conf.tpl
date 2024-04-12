#
# See slapd.conf(5) for details on configuration options.
# This file should NOT be world readable.
#
include		/usr/local/etc/openldap/schema/core.schema
include		/usr/local/etc/openldap/schema/cosine.schema
include		/usr/local/etc/openldap/schema/inetorgperson.schema
include		/usr/local/etc/openldap/schema/nis.schema
include		/usr/local/etc/openldap/schema/opendkim.schema
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
# moduleload	back_ldap

overlay		memberof
memberof-refint	TRUE

TLSCACertificateFile /usr/local/etc/openldap/certs/chain.pem
TLSCertificateFile /usr/local/etc/openldap/certs/fullchain.pem
TLSCertificateKeyFile /usr/local/etc/openldap/certs/privkey.pem

# Sample security restrictions
#	Require integrity protection (prevent hijacking)
#	Require 112-bit (3DES or better) encryption for updates
#	Require 63-bit encryption for simple bind
# security ssf=1 update_ssf=112 simple_bind=64
security ssf=128 tls=1

# Sample access control policy:
#	Root DSE: allow anyone to read it
#	Subschema (sub)entry DSE: allow anyone to read it
#	Other DSEs:
#		Allow self write access
#		Allow authenticated users read access
#		Allow anonymous users to authenticate
#	Directives needed to implement policy:
# access to dn.base="" by * read
# access to dn.base="cn=Subschema" by * read
access to attrs=userPassword
  by self write
  by anonymous auth

access to *
  by self write
  by users read
  by anonymous read

# if no access controls are present, the default policy
# allows anyone and everyone to read anything but restricts
# updates to rootdn.  (e.g., "access to * by * read")
#
# rootdn can always read and write EVERYTHING!

#######################################################################
# MDB database definitions
#######################################################################

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
index	objectClass,mail	eq
include		/usr/local/etc/openldap/slapd-secret.conf
include		/usr/local/etc/openldap/slapd-multimaster.conf
