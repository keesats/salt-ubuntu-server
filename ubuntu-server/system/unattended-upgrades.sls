# <--Managed by SaltStack-->

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
