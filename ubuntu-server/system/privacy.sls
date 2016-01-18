# Whoopsie Config
/etc/whoopsie:
  file.managed:
    - name: /etc/whoopsie
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/whoopsie
/etc/init/whoopsie.override:
  file.managed:
    - name: /etc/init/whoopsie.override
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/init/whoopsie.override
