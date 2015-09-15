#!/bin/bash
#
# check all certificates matching the given glob
# e.g.
#   check_certs.sh /etc/apache2/ssl/*.crt



# check for expiry within the next $DAYS days
DAYS=20

for i ; do
        if openssl x509 -checkend $(( 86400 * $DAYS )) -noout -in $i ; then
                echo "Certificate $i is good for another $DAYS days"
        else
                echo "Certificate $i has expired or will do so within the next $DAYS days!"
                echo "  (or is invalid/not found)"
        fi
done
