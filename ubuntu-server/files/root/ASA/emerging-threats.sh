#!/bin/bash
#
# <--Managed by SaltStack-->
# ASA-5505-Emerging-Threats
#

# Variables
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

# NOTE: Script should be ran from TFTP server
# NOTE: Passwords with $ characters must be double escaped. Ex: Pa\\\$sword for Pa$sword
TFTPSERV=$(head -n 1 /root/asa_tftp)
FWIP=$(head -n 1 /root/asa_info)
FWUSERNAME=$(head -n 1 /root/asa_creds)
PASSWORD=$(tail -1 /root/asa_creds)
ENPASSWORD=""
FWHOSTNAME=$(tail -1 /root/asa_info)
BASEPATH="/root/ASA/"
DATESTAMP=$(/bin/date +%Y.%m.%d.at.%H.%M.%S)

# Blacklist Revisions
touch $BASEPATH/emerging-PIX-ALL.rev
Rev_Current="$(cat $BASEPATH/emerging-PIX-ALL.rev)"
Rev_Latest="$(lynx --source http://rules.emergingthreats.net/fwrules/FWrev)"

# Make sure expect is installed.
EXP="$(which expect)"

if [ $? -ne 0 ] ; then
  echo "Expect binary not found, exiting"
  exit 1
elif [ -e "$EXP" ] ; then
  echo "Expect binary found, running"
fi

# Check list revision number
if [ -s $BASEPATH/emerging-PIX-ALL.rev ] ; then
  if [ $Rev_Current -ge $Rev_Latest ] ; then
    echo "Current revision $Rev_Current matches last revision processed $Rev_Latest, Exiting"
    exit 0
  else
    echo "Current revision $Rev_Latest is newer than last revision processed $Rev_Current, Working"
  fi
else
  echo "No existing blacklist revision number. Possible file errors. Starting from scratch with $Rev_Latest"
  echo "Snagging most current list:"
  wget http://rules.emergingthreats.net/fwrules/emerging-PIX-ALL.rules -O $BASEPATH/emerging-PIX-ALL.rules

  # Update revision now so script won't re-run in case of some random failure:
  awk '/Rev/ {print $3}' $BASEPATH/emerging-PIX-ALL.rules > $BASEPATH/emerging-PIX-ALL.rev

  # Rules rewrite
  echo "Rewriting rules for ASA compatability"
  sed 's/ET-all/ET-cc/g' $BASEPATH/emerging-PIX-ALL.rules | egrep "^access-list ET-cc deny" \
    | sed 's/access-list ET-cc deny ip/address/g;s/host //g;s/any/255.255.255.255/g' | \
     awk '{print $1,$2,$3}' > $BASEPATH/emerging-PIX-ALL.rules.pix

  # Can't verify current version, remove all old entries and apply current list.
  # This will be a temporary list, preserving raw list so diffs don't break next time
  echo "no dynamic-filter blacklist" > $BASEPATH/emerging-PIX-ALL.rules.pix.tmp
  echo "dynamic-filter blacklist" >> $BASEPATH/emerging-PIX-ALL.rules.pix.tmp
  cat $BASEPATH/emerging-PIX-ALL.rules.pix >> $BASEPATH/emerging-PIX-ALL.rules.pix.tmp

  chmod 777 $BASEPATH/emerging-PIX-ALL.rules.pix.tmp
  chown nobody $BASEPATH/emerging-PIX-ALL.rules.pix.tmp

  echo "Moving files to TFTP root:"
  echo "emerging-PIX-ALL.rules.pix..."
  mv $BASEPATH/emerging-PIX-ALL.rules.pix.tmp /tftpboot

  $EXP - << EndMark
  spawn ssh -l $FWUSERNAME $FWIP -oKexAlgorithms=+diffie-hellman-group1-sha1

  expect "*assword:"
    exp_send -- "$PASSWORD\r"
  expect "$FWHOSTNAME>"
    exp_send -- "enable\r"
  expect "*assword:"
    exp_send -- "$ENPASSWORD\r"
  expect "$FWHOSTNAME#"
    exp_send -- "
    copy /noconfirm tftp://$TFTPSERV/emerging-PIX-ALL.rules.pix.tmp running-config\r"
  expect "$FWHOSTNAME#"
    exp_send -- "exit\r"
  interact
EndMark

exit 0
fi

echo ""
echo ""
echo ""
# If old revision exists but the list is missing, script will diff against an
# empty file and just use whole current list. ASA silently dismisses
# duplication of existing address entries, so this is not harmful.
if [ -e $BASEPATH/emerging-PIX-ALL.rules.pix ] ; then
  mv $BASEPATH/emerging-PIX-ALL.rules.pix $BASEPATH/emerging-PIX-ALL.rules.pix.old
else
  echo "Revision file exists, but last blacklist file missing. Will apply whole list."
  touch $BASEPATH/emerging-PIX-ALL.rules.pix.old
fi

# Clean up
echo "" > $BASEPATH/emerging-PIX-ALL.rules.egress.pix

# Grab current list
echo "Snagging most current list:"
wget http://rules.emergingthreats.net/fwrules/emerging-PIX-ALL.rules -O $BASEPATH/emerging-PIX-ALL.rules

# Update local revision number
echo "Updating revision"
awk '/Rev/ {print $3}' $BASEPATH/emerging-PIX-ALL.rules > $BASEPATH/emerging-PIX-ALL.rev

# Rules rewrite
echo "Rewriting rules for ASA compatability"
sed 's/ET-all/ET-cc/g' $BASEPATH/emerging-PIX-ALL.rules | egrep "^access-list ET-cc deny" \
  | sed 's/access-list ET-cc deny ip/address/g;s/host //g;s/any/255.255.255.255/g' | \
  awk '{print $1,$2,$3}' >> $BASEPATH/emerging-PIX-ALL.rules.pix

echo "Processing blacklist diffs"
diff $BASEPATH/emerging-PIX-ALL.rules.pix $BASEPATH/emerging-PIX-ALL.rules.pix.old | grep ^\< | \
  sed 's/\< //g' > $BASEPATH/emerging-PIX-ALL.rules.ingress
diff $BASEPATH/emerging-PIX-ALL.rules.pix $BASEPATH/emerging-PIX-ALL.rules.pix.old | grep ^\> | \
  sed 's/\> //g' > $BASEPATH/emerging-PIX-ALL.rules.egress

# Check for errors in processing
echo "" > $BASEPATH/ingress.exceptions
echo "" > $BASEPATH/egress.exceptions

echo "Blacklist diff errors:"
echo ""

awk '{print $2}' $BASEPATH/emerging-PIX-ALL.rules.egress | while read LINE ; do
  grep $LINE $BASEPATH/emerging-PIX-ALL.rules.ingress > $BASEPATH/ingress.exceptions
done
echo "$BASEPATH/emerging-PIX-ALL.rules.ingress:"
cat $BASEPATH/ingress.exceptions

awk '{print $2}' $BASEPATH/emerging-PIX-ALL.rules.ingress | while read LINE; do
  grep $LINE $BASEPATH/emerging-PIX-ALL.rules.egress > $BASEPATH/egress.exceptions
done

echo "$BASEPATH/emerging-PIX-ALL.rules.egress:"
cat $BASEPATH/egress.exceptions

# Finish and put in /tftproot
echo "Combining diffs"

echo "dynamic-filter blacklist" > $BASEPATH/emerging-PIX-ALL.rules.diff.pix

sed 's/^/no\ /g' < $BASEPATH/emerging-PIX-ALL.rules.egress >> $BASEPATH/emerging-PIX-ALL.rules.egress.pix
cat $BASEPATH/emerging-PIX-ALL.rules.egress.pix $BASEPATH/emerging-PIX-ALL.rules.ingress >> \
  $BASEPATH/emerging-PIX-ALL.rules.diff.pix

# Ensure file will be accessible via TFTP
chmod 777 $BASEPATH/emerging-PIX-ALL.rules.diff.pix
chown nobody $BASEPATH/emerging-PIX-ALL.rules.diff.pix

chmod 777 $BASEPATH/emerging-PIX-ALL.rules.pix
chown nobody $BASEPATH/emerging-PIX-ALL.rules.pix

echo "Sending files to /tftproot/"
echo "emerging-PIX-ALL.rules.pix..."
mv $BASEPATH/emerging-PIX-ALL.rules.pix /tftpboot

echo "emerging-PIX-ALL.rules.diff.pix..."
mv $BASEPATH/emerging-PIX-ALL.rules.diff.pix /tftpboot

$EXP - << EndMark
spawn ssh -l $FWUSERNAME $FWIP -oKexAlgorithms=+diffie-hellman-group1-sha1

expect "*assword:"
  exp_send -- "$PASSWORD\r"
expect "$FWHOSTNAME>"
  exp_send -- "enable\r"
expect "*assword:"
  exp_send -- "$ENPASSWORD\r"
expect "$FWHOSTNAME#"
  exp_send -- "
  copy /noconfirm tftp://$TFTPSERV/emerging-PIX-ALL.rules.diff.pix running-config\r"
expect "$FWHOSTNAME#"
  exp_send -- "exit\r"
interact
EndMark

exit 0
