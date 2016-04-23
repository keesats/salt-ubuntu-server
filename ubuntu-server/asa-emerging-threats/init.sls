tftpd-hpa:
  pkg.installed:
    - name: tftpd-hpa

/etc/default/tftpd-hpa:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/default/tftpd-hpa
    - require:
      - pkg: tftpd-hpa

expect:
  pkg.installed:
    - name: expect

lynx:
  pkg.installed:
    - name: lynx

tftpd-hpa-service:
  service.running:
    - name: tftpd-hpa
    - enable: True
    - reload: True
    - watch:
      - file: /etc/default/tftpd-hpa

/root/ASA/emerging-threats.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 700
    - source: salt://ubuntu-server/files/root/ASA/emerging-threats.sh
    - require:
      - pkg: tftpd-hpa
      - pkg: expect
