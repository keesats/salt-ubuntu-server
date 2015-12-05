# <--Managed by SaltStack-->

iptables:
  pkg.installed:
    - name: iptables

ipset:
  pkg.installed:
    - name: ipset

# Ensures the iptables script exists
/etc/iptables.sh:
  file.managed:
    - name: /etc/iptables.sh
    - source: salt://ubuntu-server/files/etc/iptables.sh
    - user: root
    - group: root
    - mode: 744
    - require:
      - pkg: iptables
      - pkg: ipset

# If the script hasn't ran already, run it
iptables_enforce:
   cmd:
    - run
    - name: cd /etc/ && ./iptables.sh
    - unless: ipset list | grep /24
    - require:
      - file: /etc/iptables.sh
