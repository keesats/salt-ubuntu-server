# Hide user and password when logging in
/usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf:
  file.managed:
    - name: /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
    - source: salt://ubuntu-server/files/usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
    - user: root
    - group: root
    - mode: 644

# Disable guest sessions
/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf:
  file.managed:
    - name: /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
    - source: salt://ubuntu-server/files/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
    - user: root
    - group: root
    - mode: 644
