#!/bin/bash
# 
# check all certificates matching the given glob(s).
# If certs are found which will expire soon, then a new CSR is generated and
# the user gets some information what to do to get a new certificate.
#
# e.g.
#   check_certs.sh /etc/apache2/ssl/*.crt
#
# OPTIONS --request ... on expiring certs, issue CSR. Without this option,
#                       the user only gets notified about the expiring cert status,
#                       but nothing else happens
#



# check for expiry within the next $DAYS days
DAYS=20

if [ "$1" == "--request" ] ; then
	REQUEST=1
	shift # remove option parameter
fi

function printUsage() {
	echo "Usage:"
	echo "  check_certs.sh [ --request ] file(s)"
	echo
	echo "Parameters:"
	echo "  file(s) ... files or file glob patterns specifying the "
	echo "              certificate files to be checked"
	echo 
	echo "If the option --request is given, then a new CSR will be issued automatically on "
	echo "expiring certs. Without this option, the script only displays information about"
	echo "the expiring certs, but nothing else happens."
}

if [ "$1" == "" ] ; then
	echo "ERROR: file (patterns) of certificate files to be checked missing"
	printUsage
	exit 1
fi


for file ; do

	if [ -f $file ] ; then

		# check if it is a cert file at all
		if openssl x509 -noout -in $file 2>/dev/null ; then
			if ! openssl x509 -checkend $(( 86400 * $DAYS )) -noout -in $file ; then
				if ! openssl x509 -checkend 0 -noout -in $file ; then
					echo "Certificate $file has expired."
				else
					echo "Certificate $file will expire within the next $DAYS days."
				fi
				echo "You can create a new CSR using the following command  (the script"
				echo "will show additional instructions):"
				echo "   create_new_csr.sh $file"
				
				if [[ $REQUEST ]] ; then
					create_new_csr.sh $file
				fi
				
			fi
		else
			echo "$file is no x509 certificate file"
		fi
	elif [ -r $file ] ; then
		echo "ERROR $file is no file"
	else
		echo "ERROR: could not find $file"
	fi
done
