motd_header:
  file.managed:
    - name: /etc/update-motd.d/00-header
    - source: salt://ubuntu-server/files/etc/update-motd.d/00-header
    - user: root
    - group: root
    - mode: 755

motd_text:
  file.managed:
    - name: /etc/update-motd.d/10-help-text
    - source: salt://ubuntu-server/files/etc/update-motd.d/10-help-text
    - user: root
    - group: root
    - mode: 755
