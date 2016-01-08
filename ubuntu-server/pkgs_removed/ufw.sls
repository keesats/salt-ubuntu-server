# Removes ufw since we use iptables
ufw:
  pkg.removed:
    - name: ufw
