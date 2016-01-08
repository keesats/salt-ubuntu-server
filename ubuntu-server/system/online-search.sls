# Disable Unity Online Search
disable-online-search:
   cmd:
    - run
    - name: gsettings set com.canonical.Unity.Lenses remote-content-search 'none'
    - unless: gsettings get com.canonical.Unity.Lenses remote-content-search | grep none
