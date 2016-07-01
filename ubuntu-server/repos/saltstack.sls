# <--SaltStack Repo-->

saltstack.key:
   cmd.run:
     - name: 'wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -'
     - unless: apt-key list | grep "SaltStack Packaging"

/etc/apt/sources.list.d/saltstack.list:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ubuntu-server/files/etc/apt/sources.list.d/saltstack.list
    - require:
      - cmd: saltstack.key
    - require_in:
      - pkg: pkg-installed # Salt-Minion
