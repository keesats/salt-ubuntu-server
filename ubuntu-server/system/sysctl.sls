# SysCtl Config

/etc/sysctl.conf:
  file.managed:
    - name: /etc/sysctl.conf
    - source: salt://ubuntu-server/files/etc/sysctl.conf
    - user: root
    - group: root
    - mode: 644
sysctl_reload:
  cmd.wait:
    - name: sysctl -p
    - watch:
      - file: /etc/sysctl.conf
