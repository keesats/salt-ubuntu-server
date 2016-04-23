#!/bin/bash
#
# <--Managed by SaltStack-->
# BIND9 - BH-DNS
#

# Variables
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

BASEPATH="/root/BH-DNS/"

# Delete old list
rm $BASEPATH/domains.txt

# Grab current list
echo "Snagging most current list:"
wget http://mirror1.malwaredomains.com/files/domains.txt -O $BASEPATH/domains.txt

# Delete old BIND file
rm /etc/bind/bh-dns.zones

# Rewrite file & export to BIND directory
echo "Rewriting list of domains as BIND9 zone file."
sed -e 's/[2][0][1][3-9][0-9][0-9][0-9][0-9]//g' -e '/^\s*[@#]/ d' domains.txt | awk '{print $1}' | sed -e 's/^/zone "/' -e 's/$/" { type master; file "\/etc\/bind\/blockeddomains.db"; };/' > /etc/bind/bh-dns.zones

# Set file permissions
chmod 644 /etc/bind/bh-dns.zones

# Restart BIND9
service bind9 restart

# Exit
exit 0
