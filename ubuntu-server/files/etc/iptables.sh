# !/bin/sh
# <--Managed by SaltStack-->

# Flush current rulesets
/sbin/iptables -F

# Allow in and out, but block forward traffic
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -P FORWARD DROP

# Destroy existing IPSet lists, if they exist
/sbin/ipset destroy geoblock

# Create new empty IPSet lists
/sbin/ipset create geoblock hash:net

# List of country codes to block outbound & inbound traffic to.
ISO="af ca cn jp kp kr pl ru so tw"
# AF = Afghanistan
# CA = Canada
# CN = China
# JP = Japan
# KP = South Korea
# KR = North Korea
# PL = Poland
# RU = Russia
# SO = Somalia
# TW = Taiwan

# Add each country's list of IPs to our geoblock IPSet list
for country in $ISO
do
   for IP in $(/usr/bin/wget -O - http://ipdeny.com/ipblocks/data/aggregated/"$country"-aggregated.zone)
      do
         /sbin/ipset add geoblock $IP
      done
done

# Deny inbound & outbound traffic involving blacklisted countries.
/sbin/iptables -I OUTPUT -m set --match-set geoblock dst -j DROP
/sbin/iptables -I INPUT -m set --match-set geoblock src -j DROP
