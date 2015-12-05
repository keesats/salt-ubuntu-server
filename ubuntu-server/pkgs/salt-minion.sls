# Add SaltStack Signing Key
saltstack.key:
   cmd:
    - run
    - name: 'wget -O - https://repo.saltstack.com/apt/ubuntu/ubuntu14/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -'
    - unless: apt-key list | grep "SaltStack Packaging Team"

# Add SaltStack Repo
/etc/apt/sources.list.d/saltstack.list:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/apt/sources.list.d/saltstack.list
    - require:
      - cmd: saltstack.key

# Install Salt-Minion
salt-minion:
  pkg.latest:
    - name: salt-minion
    - require:
      - file: /etc/apt/sources.list.d/saltstack.list

# Ensure salt-minion config file is in place
/etc/salt/minion:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://ubuntu-server/files/etc/salt/minion
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: salt-minion

# Ensure service is stopped since masterless
salt-minion-service:
  service.disabled:
  - name: salt-minion
  - require:
    - pkg: salt-minion
