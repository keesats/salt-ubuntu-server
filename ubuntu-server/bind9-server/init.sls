bind9:
  pkg.installed:
    - name: bind9

bind9utils:
  pkg.installed:
    - name: bind9utils

bind9-server:
  service.running:
    - name: bind9
    - enable: True
    - reload: True
    - watch:
      - file: /etc/bind/named.conf
      - file: /etc/bind/named.conf.options
      - file: /etc/bind/blockeddomains.db

/etc/bind/named.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/bind/named.conf
    - require:
      - pkg: bind9

/etc/bind/named.conf.options:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/bind/named.conf.options
    - require:
      - pkg: bind9

/etc/bind/blockeddomains.db:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/bind/blockeddomains.db
    - require:
      - pkg: bind9

/root/BH-DNS/bh-dns.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 700
    - source: salt://ubuntu-server/files/root/BH-DNS/bh-dns.sh
    - require:
      - pkg: bind9
