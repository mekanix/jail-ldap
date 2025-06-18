include		/usr/local/etc/openldap/schema/core.schema
include		/usr/local/etc/openldap/schema/cosine.schema
include		/usr/local/etc/openldap/schema/inetorgperson.schema
include		/usr/local/etc/openldap/schema/nis.schema
include		/usr/local/etc/openldap/schema/opendkim.schema
include		/usr/local/etc/openldap/schema/idnext.schema
include		/usr/local/etc/openldap/schema/pmi.schema


pidfile		/var/run/openldap/slapd.pid
argsfile	/var/run/openldap/slapd.args

modulepath	/usr/local/libexec/openldap
moduleload	back_mdb
moduleload	memberof
moduleload	refint

TLSCACertificateFile /usr/local/etc/openldap/certs/chain.pem
TLSCertificateFile /usr/local/etc/openldap/certs/fullchain.pem
TLSCertificateKeyFile /usr/local/etc/openldap/certs/privkey.pem

security ssf=128 tls=1

include		/usr/local/etc/openldap/slapd-acl.conf

database	config
rootdn		"cn=root,cn=config"
include		/usr/local/etc/openldap/slapd-secret.conf

database	mdb
suffix		"dc=ldap"
rootdn		"cn=root,dc=ldap"
directory	/var/db/openldap-data
index		objectClass,mail,uidNumber,gidNumber,cn,uid	eq
include		/usr/local/etc/openldap/slapd-secret.conf
include		/usr/local/etc/openldap/slapd-multimaster.conf

overlay			memberof
memberof-group-oc	groupOfUniqueNames
memberof-member-ad	uniqueMember
memberof-memberof-ad	memberOf
memberof-refint		TRUE

overlay			refint
refint_attributes	memberOf uniqueMember
