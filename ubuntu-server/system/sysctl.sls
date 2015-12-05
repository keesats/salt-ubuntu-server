# <--Managed by SaltStack-->
# Written by Bradley Lankford

# Ensure sysctl config file is in place
/etc/sysctl.conf:
  file.managed:
    - name: /etc/sysctl.conf
    - source: salt://ubuntu-server/files/etc/sysctl.conf
    - user: root
    - group: root
    - mode: 644

# Reload sysctl if config file changes
sysctl_reload:
  cmd.wait:
    - name: sysctl -p
    - watch:
      - file: /etc/sysctl.conf
