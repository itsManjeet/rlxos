kind: import

config:
  sources: /
  target: "%{datadir}/waydroid-extra/images"

sources:
- kind: zip
  base-dir: ''
  url: sourceforge_project:waydroid/files/images/system/lineage/waydroid_x86_64/lineage-18.1-20230422-VANILLA-waydroid_x86_64-system.zip

  ref: 8bc82f766bd5f836fd41a073cf4378d8e574c60cf30894deb9521213a2b18416
  
- kind: zip
  url: sourceforge_project:waydroid/files/images/vendor/waydroid_x86_64/lineage-18.1-20230422-MAINLINE-waydroid_x86_64-vendor.zip
  base-dir: ''
  
  ref: c97fd8f569baf1a5a4a91ca0d2db2d21b911daf0c29b8966f7640d37aa130de8
