kind: autotools

sources:
- kind: tar
  url: github_files:OpenPrinting/system-config-printer/releases/download/v1.5.15/system-config-printer-1.5.15.tar.xz

  ref: fbd226ce215bf014213dded81b43b9d4d90470524f5bf7cd21ecc71d4aefa689
build-depends:
- components/intltool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/xmlto.bst

depends:
- components/gtk+-3.bst
- components/pygobject.bst
- components/pycups.bst
- freedesktop-sdk.bst:components/cups-daemon.bst
- freedesktop-sdk.bst:components/python3-dbus.bst
- freedesktop-sdk.bst:components/python3-requests.bst
- freedesktop-sdk.bst:components/systemd.bst

config:
  install-commands:
    (>):
    - cd %{install-root}%{bindir} && rm system-config-printer system-config-printer-applet
    - cd %{install-root}%{sysconfdir} && rm -r xdg
    - cd %{install-root}%{datadir} && rm -r applications locale man
    - cd %{install-root}%{datadir}/system-config-printer && rm -r icons/ troubleshoot/
      ui/ xml/ && rm applet.py check-device-ids.py HIG.py install-printerdriver.py
      SearchCriterion.py serversettings.py system-config-printer.py timedops.py ToolbarSearchEntry.py
      userdefault.py
