base:
  '*':
    - ubuntu-server.pkgs.installed # Installed pkgs
    - ubuntu-server.pkgs.removed # Removed pkgs
    - ubuntu-server.pkgs.repos # Added repos
    - ubuntu-server.system.cron # Cron settings
    - ubuntu-server.system.privacy # Privacy settings
    - ubuntu-server.system.security # Security settings
