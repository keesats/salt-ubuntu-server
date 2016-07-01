# IPTables Config

/etc/iptables.sh:
  file.managed:
    - name: /etc/iptables.sh
    - source: salt://ubuntu-server/files/etc/iptables.sh
    - user: root
    - group: root
    - mode: 744

iptables_enforce:
   cmd.run:
     - name: cd /etc/ && ./iptables.sh
     - unless: ipset list | grep /24
     - require:
       - file: /etc/iptables.sh
