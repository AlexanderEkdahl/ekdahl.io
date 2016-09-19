apt-get install -y strongswan strongswan-plugin-af-alg strongswan-plugin-agent strongswan-plugin-certexpire strongswan-plugin-coupling strongswan-plugin-curl strongswan-plugin-dhcp strongswan-plugin-duplicheck strongswan-plugin-eap-aka strongswan-plugin-eap-aka-3gpp2 strongswan-plugin-eap-dynamic strongswan-plugin-eap-gtc strongswan-plugin-eap-mschapv2 strongswan-plugin-eap-peap strongswan-plugin-eap-radius strongswan-plugin-eap-tls strongswan-plugin-eap-ttls strongswan-plugin-error-notify strongswan-plugin-farp strongswan-plugin-fips-prf strongswan-plugin-gcrypt strongswan-plugin-gmp strongswan-plugin-ipseckey strongswan-plugin-kernel-libipsec strongswan-plugin-ldap strongswan-plugin-led strongswan-plugin-load-tester strongswan-plugin-lookip strongswan-plugin-ntru strongswan-plugin-pgp strongswan-plugin-pkcs11 strongswan-plugin-pubkey strongswan-plugin-radattr strongswan-plugin-sshkey strongswan-plugin-systime-fix strongswan-plugin-whitelist strongswan-plugin-xauth-eap strongswan-plugin-xauth-generic strongswan-plugin-xauth-noauth strongswan-plugin-xauth-pam strongswan-pt-tls-client 

apt-get install -y haveged

ipsec pki --pub --in private/vpnHostKey.der --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/strongswanCert.der --cakey private/strongswanKey.der --dn "C=NL, O=Example Company, CN=178.62.234.89" --san 178.62.234.89  --san @178.62.234.89 --flag serverAuth --flag ikeIntermediate --outform der > certs/vpnHostCert.der

ipsec pki --pub --in private/JohnKey.der --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/strongswanCert.der --cakey private/strongswanKey.der --dn "C=NL, O=Example Company, CN=john@example.org" --san "john@example.org" --san "john@example.net" --san "john@178.62.234.89" --outform der > certs/JohnCert.der

# for ISAKMP (handling of security associations)
iptables -A INPUT -p udp --dport 500 --j ACCEPT
# for NAT-T (handling of IPsec between natted devices)
iptables -A INPUT -p udp --dport 4500 --j ACCEPT
# for ESP payload (the encrypted data packets)
iptables -A INPUT -p esp -j ACCEPT
# for the routing of packets on the server
iptables -t nat -A POSTROUTING -j SNAT --to-source 178.62.234.89 -o eth+

for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
iptables -t nat -A POSTROUTING -j SNAT --to-source 178.62.234.89 -o eth+
iptables -A INPUT -p udp --dport 500 --j ACCEPT
iptables -A INPUT -p udp --dport 4500 --j ACCEPT
iptables -A INPUT -p esp -j ACCEPT
