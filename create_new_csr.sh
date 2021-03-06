#!/bin/bash

# directory in which the key and csr files will be generated
TMP_DIR=/tmp

CRT=$1

function printUsage() {
	echo "Usage:"
	echo "  create_new_CSR.sh WHAT"
	echo
	echo "Parameters:"
	echo "  WHAT ... CRT (or PEM) file to be newly generated"
}

if [ "$CRT" == "" ] ; then
	printUsage
	exit 1
fi

CERT_DIR=$( dirname $CRT )
CERT_NAME=$( basename $CRT )
CERT_BASE_NAME=${CERT_NAME%.*} # cut away extension
CERT_EXTENSION=${CERT_NAME##*.} # remember extension

case $CERT_BASE_NAME in
	'eck-zimmer.at'|'owncloud'|'timetracker'|'reminder')
		cn=eck-zimmer.at
		;;
	'test')
		cn=eck-zimmer.at
		;;
	*)
		echo "ERROR: unknown certificate name of [$CERT_BASE_NAME]"
		echo "Call without parameters for usage help"
		exit 1
esac

keyfile=${TMP_DIR}/${CERT_BASE_NAME}.key
csrfile=${TMP_DIR}/${CERT_BASE_NAME}.csr
certfile=${CERT_DIR}/${CERT_BASE_NAME}.${CERT_EXTENSION}

openssl req -nodes -newkey rsa:2048 -nodes -keyout $keyfile -out $csrfile -subj "/C=AT/ST=Styria/L=Graz/O=Alexander Eck-Zimmer/CN=${cn}"
chmod 600 $keyfile

CSR="$( cat ${csrfile} )"

TEXT="A new CSR has been generated for ${CERT_BASE_NAME}:\n
   key: ${keyfile}\n
   CSR: ${csrfile}\n
\n
To do:\n
  (1) Paste the following CSR to StartSSL Certification Wizard:\n
\n
`cat ${csrfile}`\n
\n
  (2) wait for the certificate to be generated by StartSSL and download it to:\n
      ${certfile}\n
\n
or:\n
$CSR
\n
  (3) Put keyfile into ${CERT_DIR}:\n
  mv ${keyfile} ${CERT_DIR}/\n
\n
  (4) ensure that the key file is fmode 600\n
\n
  (5) reload Apache config:\n
      service apache2 reload\n
\n
That's it. Check it out in your browser!\n
"

echo -e $TEXT

echo -e $TEXT | mutt -a "${csrfile}" -s "StartSSL: neues Server-Zerti erzeugen fuer ${CERT_BASE_NAME}. Key und CSR liegen hier: [$TMP_DIR]" -- root

exit 0
