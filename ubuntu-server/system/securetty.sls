# SecureTTY Config

/etc/securetty:
  file.managed:
    - name: /etc/securetty
    - source: salt://ubuntu-server/files/etc/securetty
    - user: root
    - group: root
    - mode: 644
