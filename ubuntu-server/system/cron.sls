# <--Managed by SaltStack-->

# Apply root crontab
root_crontab:
  cron.file:
    - name: salt://ubuntu-server/files/root_crontab
    - user: root
