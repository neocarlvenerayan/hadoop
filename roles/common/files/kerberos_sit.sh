#!/bin/bash
yum install krb5-server krb5-devel krb5-workstation krb5-libs rng-tools -y

service rngd start

# create -template
echo '[libdefaults]
  renew_lifetime = 7d
  forwardable = true
  default_realm = TEST015.ORG
  ticket_lifetime = 24h
  dns_lookup_realm = false
  dns_lookup_kdc = false
  default_ccache_name = /tmp/krb5cc_%{uid}
  #default_tgs_enctypes = aes des3-cbc-sha1 rc4 des-cbc-md5
  #default_tkt_enctypes = aes des3-cbc-sha1 rc4 des-cbc-md5

[domain_realm]
  TEST015.org = TEST015.ORG

[logging]
  default = FILE:/var/log/krb5kdc.log
  admin_server = FILE:/var/log/kadmind.log
  kdc = FILE:/var/log/krb5kdc.log

[realms]
  TEST015.ORG = {
    admin_server = dcsit.TEST015.org
    kdc = dcsit.TEST015.org
  }
'> /etc/krb5.conf

# no need for this? or change the admin?
kdb5_util create -P admin -s

echo '*/admin@TEST015.ORG  *' > /var/kerberos/krb5kdc/kadm5.acl
kadmin.local -q "addprinc -pw admin admin/admin"

# add user keyadmin for Ranger KMS
kadmin.local -q 'addprinc -pw keyadmin keyadmin'

# add user nn for Ranger KMS
adduser nn
kadmin.local -q 'addprinc -randkey nn'

service krb5kdc start
service kadmin start
