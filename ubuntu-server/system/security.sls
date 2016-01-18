# Enable automatic security updates
/etc/apt/apt.conf.d/50unattended-upgrades:
  file.managed:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - source: salt://ubuntu-server/files/etc/apt/apt.conf.d/50unattended-upgrades
    - user: root
    - group: root
    - mode: 644
/etc/apt/apt.conf.d/20auto-upgrades:
  file.managed:
    - name: /etc/apt/apt.conf.d/20auto-upgrades
    - source: salt://ubuntu-server/files/etc/apt/apt.conf.d/20auto-upgrades
    - user: root
    - group: root
    - mode: 644

# IPTables Setup
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

# LightDM Config
/usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf:
  file.managed:
    - name: /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
    - source: salt://ubuntu-server/files/usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
    - user: root
    - group: root
    - mode: 644
/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf:
  file.managed:
    - name: /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
    - source: salt://ubuntu-server/files/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
    - user: root
    - group: root
    - mode: 644

# MOTD Config
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

# SecureTTY Config
/etc/securetty:
  file.managed:
    - name: /etc/securetty
    - source: salt://ubuntu-server/files/etc/securetty
    - user: root
    - group: root
    - mode: 644

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
