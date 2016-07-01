base:
  '*':
#    - ubuntu-server.asa-emerging-threats #Off by default
#    - ubuntu-server.bind9-server #Off by default
    - ubuntu-server.pkgs.installed
    - ubuntu-server.pkgs.removed
    - ubuntu-server.repos.saltstack
    - ubuntu-server.system.cron
    - ubuntu-server.system.iptables
    - ubuntu-server.system.motd
    - ubuntu-server.system.securetty
    - ubuntu-server.system.sysctl
