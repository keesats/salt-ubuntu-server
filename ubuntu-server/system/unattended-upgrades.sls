# Ensure unattended-upgrades package is installed
unattended-upgrades:
  pkg.installed:
    - name: unattended-upgrades

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
    - require:
      - pkg: unattended-upgrades
