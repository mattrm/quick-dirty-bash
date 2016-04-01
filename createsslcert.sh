#!/bin/bash
# Quick and dirty script to create a SSL cert

fqdn=$1

# Make sure that fqdn exists
if [ -z "$fqdn" ]
then
	    echo "Argument not present."
	    echo "Useage $0 [common name]"
	    exit 99
fi

country=GB
state=CHANGEME
locality=CHANGEME
organisation=CHANGEME
orgunit=CHANGEME
email=bob@example.com

# Create a password
PASS=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)

/usr/bin/cd /root
ls
# Generate the key
openssl genrsa -des3 -out $fqdn.key -passout pass:$PASS 2048 

# Generate the CSR
openssl req -new -batch -passin pass:$PASS -subj "/C=$country/ST=$state/L=$locality/O=$organisation/OU=$orgunit/CN=$fqdn" -key $fqdn.key -out $fqdn.csr

/bin/cp $fqdn.key $fqdn.key.org

# Strip the cert of the password
openssl rsa -in $fqdn.key.org -out $fqdn.key -passin pass:$PASS
# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $fqdn.csr -signkey $fqdn.key -out $fqdn.crt
