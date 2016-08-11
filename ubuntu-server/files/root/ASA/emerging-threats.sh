#!/bin/bash
# <--Managed by SaltStack-->
# ASA - Rule Config
# Downloads known IP sets and rewrites them as ASA config
# configuration in a text file

# Variables
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH
BASEPATH="/srv/salt/scripts/asa-emerging-threats/"
BASETFTP="/tftpboot/"
DATESTAMP=$(/bin/date +%Y.%m.%d.at.%H.%M.%S)

# Delete old lists and rewritten files
rm $BASEPATH/afcu-rules-sorted.txt
rm $BASEPATH/afcu-rules-unsorted.txt
rm $BASEPATH/compromised-ips.txt
rm $BASEPATH/emerging-PIX-ALL.rules
rm $BASEPATH/ransomeware-ips.txt
rm $BASEPATH/zeus-tracker-ips.txt
rm $BASETFTP/afcu-rules-sorted.txt

# Grab current lists
wget https://rules.emergingthreats.net/blockrules/compromised-ips.txt -O $BASEPATH/compromised-ips.txt
wget https://rules.emergingthreats.net/fwrules/emerging-PIX-ALL.rules -O $BASEPATH/emerging-PIX-ALL.rules
wget http://ransomwaretracker.abuse.ch/downloads/RW_IPBL.txt -O $BASEPATH/ransomeware-ips.txt
wget https://zeustracker.abuse.ch/blocklist.php?download=badips -O $BASEPATH/zeus-tracker-ips.txt

# Rewrite emerging-PIX-ALL.rules
sed 's/ET-all/ET-cc/g' $BASEPATH/emerging-PIX-ALL.rules | egrep "^access-list ET-cc deny" \
  | sed 's/access-list ET-cc deny ip/address/g;s/host //g;s/any/255.255.255.255/g' | \
   awk '{print $1,$2,$3}' > $BASEPATH/afcu-rules-unsorted.txt

# Rewrite compromised-ips.txt
sed -e 's/^/address /' -e 's/$/ 255.255.255.255/' \
  $BASEPATH/compromised-ips.txt >> $BASEPATH/afcu-rules-unsorted.txt

# Rewrite ransome-ips.txt
sed '/^#/ d;/^$/d' $BASEPATH/ransomeware-ips.txt >> $BASEPATH/afcu-rules-unsorted.txt

# Rewrite zeus-tracker-ips.txt
sed '/^#/ d;/^$/d' $BASEPATH/zeus-tracker-ips.txt >> $BASEPATH/afcu-rules-unsorted.txt

# Add lines to delete existing blacklist dynamic-filter on the firewall
echo "no dynamic-filter blacklist" > $BASEPATH/afcu-rules-sorted.txt
echo "dynamic-filter blacklist" >> $BASEPATH/afcu-rules-sorted.txt

# Append sorted IP ranges to afcu-rules-sorted.txt
sort -d -r $BASEPATH/afcu-rules-unsorted.txt >> $BASEPATH/afcu-rules-sorted.txt

# Set file permissions for TFTP transfer
chmod 775 $BASEPATH/afcu-rules-sorted.txt
chown nobody $BASEPATH/afcu-rules-sorted.txt

# Transfer file to TFTP root dir
cp $BASEPATH/afcu-rules-sorted.txt $BASETFTP

# Exit
exit 0
