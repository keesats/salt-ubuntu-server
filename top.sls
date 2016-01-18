base:
  '*':
    - ubuntu-server.pkgs.installed # Installed pkgs
    - ubuntu-server.pkgs.removed # Removed pkgs
    - ubuntu-server.pkgs.repos # Added repos
    - ubuntu-client.system.cron # Cron settings
    - ubuntu-client.system.privacy # Privacy settings
    - ubuntu-client.system.security # Security settings
