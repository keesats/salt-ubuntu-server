# Salt Top Config

base:

  '*':
    # Packages
    - ubuntu-server.pkgs

    # Packages Removed
    - ubuntu-server.pkgs_removed

    # System Config
    - ubuntu-server.system
