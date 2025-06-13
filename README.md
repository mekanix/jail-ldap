# OpenLDAP

## Config
Upon successful provision this jail will contain OpenLDAP server capable of 
multi-master setup (disabled by default). It will also configure 
`cn=root,dc=ldap` to be admin of the whole database and set its initial 
password to `Sekrit`. It is written to 
`/usr/local/etc/openldap/slapd-secret.conf` and should be changed to something
secure. Please not that the same password is used for replication in 
`slapd-multimaster.conf`. To load initial data take a look at `examples` 
directory. This schema is used in dependent services like Postfix, Dovecot, 
Ejabberd, etc.

## Multimaster

If you're creating LDAP cluster, there are few things you should be aware of.
First, you need to uncomment everything under `slapd-multimaster.conf` and set
IDs properly. Ansible will generate initial IDs, but it is better to use some
kind of convention. For example this is a two node cluster configuration:

```
ServerID        1
moduleload      syncprov
overlay         syncprov
syncprov-checkpoint     10 1
syncprov-sessionlog     100
syncrepl        rid=12
                provider="ldap://ldap2.example.com"
                type=refreshAndPersist
                schemachecking=on
                retry="5 10 30 +"
                searchbase="dc=ldap"
                bindmethod=simple
                binddn="cn=root,dc=ldap"
                credentials="Sekrit"
                starttls=yes
                tls_cacert=/etc/ssl/cert.pem
                tls_cert=/usr/local/etc/openldap/certs/fullchain.pem
                tls_key=/usr/local/etc/openldap/certs/privkey.pem
MirrorMode on
```

Of course, on ldap2 jail we need to have similar configuration. Please not 
`ServerID` and `rid` values. The convention is that `rid` is starting with a
digit which is `ServerID` and second digit is the `ServerID` of second server,
hence 2. This way if you have in your config `rid=11` or `rid=22` you know it's 
wrong.

The jail will add `ldap.example.com` to local_unbound as well as 
`ldap.<server>.example.com`. That way all services should just use 
`ldap.example.com` to connect, while replication uses record in DNS pointing 
to another server.

Certificates are going to be refreshed via `letsencrypt` jail and cron on host
will put certificates in proper directories.

To search LDAP directory without being asked for password:

```
ldapsearch -x -Z -w `cut -f 2 -d '"' /usr/local/etc/openldap/slapd-secret.conf` -D cn=root,dc=ldap
```

When adding new account, generate uid/gid number by getting current value of
uidNumber:

```
ldapsearch -x -Z -w `cut -f 2 -d '"' /usr/local/etc/openldap/slapd-secret.conf` -D cn=root,dc=ldap -LLL '(objectClass=uidNext)' uidNumber
```

Then create increment.ldif:

```ldap
dn: cn=uidnext,dc=ldap
changetype: modify
increment: uidNumber
uidNumber: 1
```

And finally apply it with

```
ldapmodify -x -Z -w `cut -f 2 -d '"' /usr/local/etc/openldap/slapd-secret.conf` -D cn=root,dc=ldap -f increment.ldif

```
