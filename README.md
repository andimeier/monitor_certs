check-certs
============

check_certs.sh is a bash script to be called via crond. It checks the specified certificates for expiry and reports the certifactes which are expired or are about to expire within the next 20 days (configurable in script).

If run in auto-request mode, not only will expiring certificates be reported, but also a new private key is generated and a certificate signing request (CSR) is issued, then root gets notified via mail, for each expiring cert.

Check out `crontab.txt` for an example how to use the script in a crontab

Usage
-----

    check_certs.sh --request /etc/apache2/ssl/*.crt

This will check all certificate files in Apache's cert directory and generate new CSRs in case of expiring certs.

Note that the tool does not remember which CSR have been generated. Thus, in case of an expiring cert, each time the script is called, a new CSR for the cert will be issued (overwriting the previous one). This will only end when the new cert has finally be installed.

*Be sure to check* if the script `create_new_csr.sh` can be called correctly by the cron daemon. Remember that only a default environment is loaded under cron, so something like ./create_new_csr.sh might not work. You might have to manually provide the complete path to the script in the source code of `check_certs.sh`.
