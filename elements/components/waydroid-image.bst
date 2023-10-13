kind: import

config:
  target: "%{datadir}/waydroid-extra/images"

sources:
- kind: zip
  base-dir: ''
  url: 
    sourceforge_project:waydroid/files/images/system/lineage/waydroid_x86_64/lineage-18.1-20231007-VANILLA-waydroid_x86_64-system.zip

  ref: 19ae5b09c66a79a607484c52a8e36f689ab189cb12443837720af845a0f4f798

- kind: zip
  url: 
    sourceforge_project:waydroid/files/images/vendor/waydroid_x86_64/lineage-18.1-20231007-MAINLINE-waydroid_x86_64-vendor.zip
  base-dir: ''
  ref: 96341f437261cd477b52bdcbddcd9ae69bcacf93ac480c89ce474587d9494478
