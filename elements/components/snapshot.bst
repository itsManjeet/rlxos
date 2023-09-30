kind: meson

sources:
- kind: tar
  url: gnome_downloads:snapshot/45/snapshot-45.0.tar.xz
  ref: ee478ee090731a0b0824b66bb1746bd800dcbfe87ac8358499449af39cfcdb67
- kind: cargo

  ref:
  - name: aho-corasick
    version: 1.0.5
    sha: 0c378d78423fdad8089616f827526ee33c19f2fddbd5de1629152c9593ba4783
  - name: android-tzdata
    version: 0.1.1
    sha: e999941b234f3131b00bc13c22d06e8c5ff726d1b6318ac7eb276997bbb4fef0
  - name: android_system_properties
    version: 0.1.5
    sha: 819e7219dbd41043ac279b19830f2efc897156490d7fd6ea916720117ee66311
  - name: anyhow
    version: 1.0.75
    sha: a4668cab20f66d8d020e1fbc0ebe47217433c1b6c8f2040faf858554e394ace6
  - name: ashpd
    version: 0.6.2
    sha: f3affe251686bd936a0afb74b9693e8bf2f193d51da1b9a45d3f1303a9bd2cc7
  - name: async-broadcast
    version: 0.5.1
    sha: 7c48ccdbf6ca6b121e0f586cbc0e73ae440e56c67c30fa0873b4e110d9c26d2b
  - name: async-channel
    version: 1.9.0
    sha: 81953c529336010edd6d8e358f886d9581267795c61b19475b71314bffa46d35
  - name: async-executor
    version: 1.5.1
    sha: 6fa3dc5f2a8564f07759c008b9109dc0d39de92a88d5588b8a5036d286383afb
  - name: async-fs
    version: 1.6.0
    sha: 279cf904654eeebfa37ac9bb1598880884924aab82e290aa65c9e77a0e142e06
  - name: async-global-executor
    version: 2.3.1
    sha: f1b6f5d7df27bd294849f8eec66ecfc63d11814df7a4f5d74168a2394467b776
  - name: async-io
    version: 1.13.0
    sha: 0fc5b45d93ef0529756f812ca52e44c221b35341892d3dcc34132ac02f3dd2af
  - name: async-lock
    version: 2.8.0
    sha: 287272293e9d8c41773cec55e365490fe034813a2f172f502d6ddcf75b2f582b
  - name: async-process
    version: 1.7.0
    sha: 7a9d28b1d97e08915212e2e45310d47854eafa69600756fc735fb788f75199c9
  - name: async-recursion
    version: 1.0.5
    sha: 5fd55a5ba1179988837d24ab4c7cc8ed6efdeff578ede0416b4225a5fca35bd0
  - name: async-std
    version: 1.12.0
    sha: 62565bb4402e926b29953c785397c6dc0391b7b446e45008b0049eb43cec6f5d
  - name: async-task
    version: 4.4.0
    sha: ecc7ab41815b3c653ccd2978ec3255c81349336702dfdf62ee6f7069b12a3aae
  - name: async-trait
    version: 0.1.73
    sha: bc00ceb34980c03614e35a3a4e218276a0a824e911d07651cd0d858a51e8c0f0
  - name: atomic-waker
    version: 1.1.1
    sha: 1181e1e0d1fce796a03db1ae795d67167da795f9cf4a39c37589e85ef57f26d3
  - name: atomic_refcell
    version: 0.1.11
    sha: 112ef6b3f6cb3cb6fc5b6b494ef7a848492cff1ab0ef4de10b0f7d572861c905
  - name: autocfg
    version: 1.1.0
    sha: d468802bab17cbc0cc575e9b053f41e72aa36bfa6b7f55e3529ffa43161b97fa
  - name: bitflags
    version: 1.3.2
    sha: bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a
  - name: bitflags
    version: 2.4.0
    sha: b4682ae6287fcf752ecaabbfcc7b6f9b72aa33933dc23a554d853aea8eea8635
  - name: block
    version: 0.1.6
    sha: 0d8c1fef690941d3e7788d328517591fecc684c084084702d6ff1641e993699a
  - name: block-buffer
    version: 0.10.4
    sha: 3078c7629b62d3f0439517fa394996acacc5cbc91c5a20d8c658e77abd503a71
  - name: blocking
    version: 1.3.1
    sha: 77231a1c8f801696fc0123ec6150ce92cffb8e164a02afb9c8ddee0e9b65ad65
  - name: bumpalo
    version: 3.14.0
    sha: 7f30e7476521f6f8af1a1c4c0b8cc94f0bee37d91763d0ca2665f299b6cd8aec
  - name: byteorder
    version: 1.4.3
    sha: 14c189c53d098945499cdfa7ecc63567cf3886b3332b312a5b4585d8d3a6a610
  - name: cairo-rs
    version: 0.18.2
    sha: 1c0466dfa8c0ee78deef390c274ad756801e0a6dbb86c5ef0924a298c5761c4d
  - name: cairo-sys-rs
    version: 0.18.2
    sha: 685c9fa8e590b8b3d678873528d83411db17242a73fccaed827770ea0fedda51
  - name: cc
    version: 1.0.83
    sha: f1174fb0b6ec23863f8b971027804a42614e347eafb0a95bf0b12cdae21fc4d0
  - name: cfg-expr
    version: 0.15.5
    sha: 03915af431787e6ffdcc74c645077518c6b6e01f80b761e0fbbfa288536311b3
  - name: cfg-if
    version: 1.0.0
    sha: baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd
  - name: chrono
    version: 0.4.31
    sha: 7f2c685bad3eb3d45a01354cedb7d5faa66194d1d58ba6e267a8de788f79db38
  - name: concurrent-queue
    version: 2.2.0
    sha: 62ec6771ecfa0762d24683ee5a32ad78487a3d3afdc0fb8cae19d2c5deb50b7c
  - name: core-foundation-sys
    version: 0.8.4
    sha: e496a50fda8aacccc86d7529e2c1e0892dbd0f898a6b5645b5561b89c3210efa
  - name: cpufeatures
    version: 0.2.9
    sha: a17b76ff3a4162b0b27f354a0c87015ddad39d35f9c0c36607a3bdd175dde1f1
  - name: crossbeam-utils
    version: 0.8.16
    sha: 5a22b2d63d4d1dc0b7f1b6b2747dd0088008a9be28b6ddf0b1e7d335e3037294
  - name: crypto-common
    version: 0.1.6
    sha: 1bfb12502f3fc46cca1bb51ac28df9d618d813cdc3d2f25b9fe775a34af26bb3
  - name: derivative
    version: 2.2.0
    sha: fcc3dd5e9e9c0b295d6e1e4d811fb6f157d5ffd784b8d202fc62eac8035a770b
  - name: digest
    version: 0.10.7
    sha: 9ed9a281f7bc9b7576e61468ba615a66a5c8cfdff42420a70aa82701a3b1e292
  - name: either
    version: 1.9.0
    sha: a26ae43d7bcc3b814de94796a5e736d4029efb0ee900c12e2d54c993ad1a1e07
  - name: enumflags2
    version: 0.7.8
    sha: 5998b4f30320c9d93aed72f63af821bfdac50465b75428fce77b48ec482c3939
  - name: enumflags2_derive
    version: 0.7.8
    sha: f95e2801cd355d4a1a3e3953ce6ee5ae9603a5c833455343a8bfe3f44d418246
  - name: equivalent
    version: 1.0.1
    sha: 5443807d6dff69373d433ab9ef5378ad8df50ca6298caf15de6e52e24aaf54d5
  - name: errno
    version: 0.3.3
    sha: 136526188508e25c6fef639d7927dfb3e0e3084488bf202267829cf7fc23dbdd
  - name: errno-dragonfly
    version: 0.1.2
    sha: aa68f1b12764fab894d2755d2518754e71b4fd80ecfb822714a1206c2aab39bf
  - name: event-listener
    version: 2.5.3
    sha: 0206175f82b8d6bf6652ff7d71a1e27fd2e4efde587fd368662814d6ec1d9ce0
  - name: fastrand
    version: 1.9.0
    sha: e51093e27b0797c359783294ca4f0a911c270184cb10f85783b118614a1501be
  - name: fastrand
    version: 2.0.0
    sha: 6999dc1837253364c2ebb0704ba97994bd874e8f195d665c50b7548f6ea92764
  - name: field-offset
    version: 0.3.6
    sha: 38e2275cc4e4fc009b0669731a1e5ab7ebf11f469eaede2bab9309a5b4d6057f
  - name: form_urlencoded
    version: 1.2.0
    sha: a62bc1cf6f830c2ec14a513a9fb124d0a213a629668a4186f329db21fe045652
  - name: futures-channel
    version: 0.3.28
    sha: 955518d47e09b25bbebc7a18df10b81f0c766eaf4c4f1cccef2fca5f2a4fb5f2
  - name: futures-core
    version: 0.3.28
    sha: 4bca583b7e26f571124fe5b7561d49cb2868d79116cfa0eefce955557c6fee8c
  - name: futures-executor
    version: 0.3.28
    sha: ccecee823288125bd88b4d7f565c9e58e41858e47ab72e8ea2d64e93624386e0
  - name: futures-io
    version: 0.3.28
    sha: 4fff74096e71ed47f8e023204cfd0aa1289cd54ae5430a9523be060cdb849964
  - name: futures-lite
    version: 1.13.0
    sha: 49a9d51ce47660b1e808d3c990b4709f2f415d928835a17dfd16991515c46bce
  - name: futures-macro
    version: 0.3.28
    sha: 89ca545a94061b6365f2c7355b4b32bd20df3ff95f02da9329b34ccc3bd6ee72
  - name: futures-sink
    version: 0.3.28
    sha: f43be4fe21a13b9781a69afa4985b0f6ee0e1afab2c6f454a8cf30e2b2237b6e
  - name: futures-task
    version: 0.3.28
    sha: 76d3d132be6c0e6aa1534069c705a74a5997a356c0dc2f86a47765e5617c5b65
  - name: futures-util
    version: 0.3.28
    sha: 26b01e40b772d54cf6c6d721c1d1abd0647a0106a12ecaa1c186273392a69533
  - name: gdk-pixbuf
    version: 0.18.0
    sha: bbc9c2ed73a81d556b65d08879ba4ee58808a6b1927ce915262185d6d547c6f3
  - name: gdk-pixbuf-sys
    version: 0.18.0
    sha: 3f9839ea644ed9c97a34d129ad56d38a25e6756f99f3a88e15cd39c20629caf7
  - name: gdk4
    version: 0.7.2
    sha: 6982d9815ed6ac95b0467b189e81f29dea26d08a732926ec113e65744ed3f96c
  - name: gdk4-sys
    version: 0.7.2
    sha: dbab43f332a3cf1df9974da690b5bb0e26720ed09a228178ce52175372dcfef0
  - name: gdk4-wayland
    version: 0.7.2
    sha: 0db9102ff11e55bd65e153c1192abc21ddfa45ede90622e423d4e4a0e5d5f313
  - name: gdk4-wayland-sys
    version: 0.7.2
    sha: d48159be256ae0212d5a2b9884627197d08082c7168b28775b53a0f9885d5624
  - name: gdk4-win32
    version: 0.7.2
    sha: fe66650c41f64e41ada9f85c4bdb96e5549c669e594892240dfb147a63256057
  - name: gdk4-win32-sys
    version: 0.7.2
    sha: 4b5c187546cd3ad9f1787b46c66272d8fcdf8197bfe4f6e2647fe910c39e396d
  - name: gdk4-x11
    version: 0.7.2
    sha: 28c9bbf8ea1ea8469e74c3fdfafc142c9e14810a27f89ddb01b5e9076a60a450
  - name: gdk4-x11-sys
    version: 0.7.2
    sha: a3de1709370758192369f5329aa593847797f1c693c95e8a261e9b2e06a5f125
  - name: generic-array
    version: 0.14.7
    sha: 85649ca51fd72272d7821adaf274ad91c288277713d9c18820d8499a7ff69e9a
  - name: getrandom
    version: 0.2.10
    sha: be4136b2a15dd319360be1c07d9933517ccf0be8f16bf62a3bee4f0d618df427
  - name: gettext-rs
    version: 0.7.0
    sha: e49ea8a8fad198aaa1f9655a2524b64b70eb06b2f3ff37da407566c93054f364
  - name: gettext-sys
    version: 0.21.3
    sha: c63ce2e00f56a206778276704bbe38564c8695249fdc8f354b4ef71c57c3839d
  - name: gio
    version: 0.18.2
    sha: 57052f84e8e5999b258e8adf8f5f2af0ac69033864936b8b6838321db2f759b1
  - name: gio-sys
    version: 0.18.1
    sha: 37566df850baf5e4cb0dfb78af2e4b9898d817ed9263d1090a2df958c64737d2
  - name: glib
    version: 0.18.2
    sha: 1c316afb01ce8067c5eaab1fc4f2cd47dc21ce7b6296358605e2ffab23ccbd19
  - name: glib-macros
    version: 0.18.2
    sha: f8da903822b136d42360518653fcf154455defc437d3e7a81475bf9a95ff1e47
  - name: glib-sys
    version: 0.18.1
    sha: 063ce2eb6a8d0ea93d2bf8ba1957e78dbab6be1c2220dd3daca57d5a9d869898
  - name: gloo-timers
    version: 0.2.6
    sha: 9b995a66bb87bebce9a0f4a95aed01daca4872c050bfcb21653361c03bc35e5c
  - name: gobject-sys
    version: 0.18.0
    sha: 0850127b514d1c4a4654ead6dedadb18198999985908e6ffe4436f53c785ce44
  - name: graphene-rs
    version: 0.18.1
    sha: 3b2228cda1505613a7a956cca69076892cfbda84fc2b7a62b94a41a272c0c401
  - name: graphene-sys
    version: 0.18.1
    sha: cc4144cee8fc8788f2a9b73dc5f1d4e1189d1f95305c4cb7bd9c1af1cfa31f59
  - name: gsk4
    version: 0.7.2
    sha: cc25855255120f294d874acd6eaf4fbed7ce1cdc550e2d8415ea57fafbe816d5
  - name: gsk4-sys
    version: 0.7.2
    sha: e1ecf3a63bf1223d68f80f72cc896c4d8c80482fbce1c9a12c66d3de7290ee46
  - name: gst-plugin-gtk4
    version: 0.11.0
    sha: c3ee0132150ee059c35642b51c5d663eadb9fa4d21f83a56dd584b03c1c45ffd
  - name: gst-plugin-version-helper
    version: 0.7.5
    sha: 87921209945e5dc809848a100115fad65bd127671896f0206f45e272080cc4c9
  - name: gstreamer
    version: 0.21.0
    sha: f8cdb86791dc39a5443f7d08cf3e7ae9c88a94991aba620d177cb5804838201f
  - name: gstreamer-audio
    version: 0.21.0
    sha: 02343d7fca125d363893744396f4df1af923033a1415ed9b886c32fdd70ae42a
  - name: gstreamer-audio-sys
    version: 0.21.0
    sha: 35814f1ce58c811c642b06c6c21bd82ce18df1dc062640d13ac20438c0626b36
  - name: gstreamer-base
    version: 0.21.0
    sha: 0fe38a6d5c1e516ce3fd6069e972a540d315448ed69fdadad739e6c6c6eb2a01
  - name: gstreamer-base-sys
    version: 0.21.0
    sha: 88b9c029583ed61fa5258076a42df91732dc7f5582044ea7ee66a721641e6af4
  - name: gstreamer-gl
    version: 0.21.0
    sha: e616c363a79424bae3623d85b5f71542ef5cad318da9fe4e887e78992a4239d3
  - name: gstreamer-gl-egl
    version: 0.21.0
    sha: e69e5a572616ea36387b39dcfec370d35d3c0e29efeb41e5da91540d9f163cec
  - name: gstreamer-gl-egl-sys
    version: 0.21.0
    sha: d8fc720bf2e17be334c70def3be390b549a390608234d06e70e7f7a373e7dbd2
  - name: gstreamer-gl-sys
    version: 0.21.0
    sha: a5e3e2f33ecd2d4e410a63ccad18d0e3692dac69b9752286e66a006fa57c952d
  - name: gstreamer-gl-wayland
    version: 0.21.0
    sha: 7850180c0021d690073697b22a6f1492dcba0ddccd2111d5ae043f6a65f9e9f3
  - name: gstreamer-gl-wayland-sys
    version: 0.21.0
    sha: 2f4abcee01a58ddfa299360fd9bc1b3f96a02fee2f81149c6f3129b3258a03cc
  - name: gstreamer-gl-x11
    version: 0.21.0
    sha: 6d62204eaef32be3228b8749dcf3d18e350910308fc84c05c416a6f29b80df34
  - name: gstreamer-gl-x11-sys
    version: 0.21.0
    sha: 2e472da0b77e877765d171e2d151cd5b4b8865d44bb18cedc61409dbe0ca5f1b
  - name: gstreamer-pbutils
    version: 0.21.0
    sha: a1e5eabfea8ac22256724f6093927dfd2148018175239036d4721e1dfc59c7d7
  - name: gstreamer-pbutils-sys
    version: 0.21.0
    sha: 6faae6e3454bc8ca5986d7ef6477fc44b809bfc952a8680eaedb4f2e001f9d69
  - name: gstreamer-sys
    version: 0.21.0
    sha: a70e3a99118bcd1221f8a62d7a905bae5e5cc2cda678bb46bf3cd36e0f899d33
  - name: gstreamer-video
    version: 0.21.0
    sha: 0db8adfc000cd58f8ece0fe6b4beb79e19e4a6135cfb81138fdb016b603f7d60
  - name: gstreamer-video-sys
    version: 0.21.0
    sha: e0284250a09fa824b21df1a21967eef4a5d85b5e0c1e335ed2ba9b9be1424dae
  - name: gtk4
    version: 0.7.2
    sha: a3b095b26f2a2df70be1805d3590eeb9d7a05ecb5be9649b82defc72dc56228c
  - name: gtk4-macros
    version: 0.7.2
    sha: d57ec49cf9b657f69a05bca8027cff0a8dfd0c49e812be026fc7311f2163832f
  - name: gtk4-sys
    version: 0.7.2
    sha: 7b0bdde87c50317b4f355bcbb4a9c2c414ece1b7c824fb4ad4ba8f3bdb2c6603
  - name: hashbrown
    version: 0.14.0
    sha: 2c6201b9ff9fd90a5a3bac2e56a830d0caa509576f0e503818ee82c181b3437a
  - name: heck
    version: 0.4.1
    sha: 95505c38b4572b2d910cecb0281560f54b440a19336cbbcb27bf6ce6adc6f5a8
  - name: hermit-abi
    version: 0.3.2
    sha: 443144c8cdadd93ebf52ddb4056d257f5b52c04d3c804e657d19eb73fc33668b
  - name: hex
    version: 0.4.3
    sha: 7f24254aa9a54b5c858eaee2f5bccdb46aaf0e486a595ed5fd8f86ba55232a70
  - name: iana-time-zone
    version: 0.1.57
    sha: 2fad5b825842d2b38bd206f3e81d6957625fd7f0a361e345c30e01a0ae2dd613
  - name: iana-time-zone-haiku
    version: 0.1.2
    sha: f31827a206f56af32e590ba56d5d2d085f558508192593743f16b2306495269f
  - name: idna
    version: 0.4.0
    sha: 7d20d6b07bfbc108882d88ed8e37d39636dcc260e15e30c45e6ba089610b917c
  - name: indexmap
    version: 2.0.0
    sha: d5477fe2230a79769d8dc68e0eabf5437907c0457a5614a9e8dddb67f65eb65d
  - name: instant
    version: 0.1.12
    sha: 7a5bbe824c507c5da5956355e86a746d82e0e1464f65d862cc5e71da70e94b2c
  - name: io-lifetimes
    version: 1.0.11
    sha: eae7b9aee968036d54dce06cebaefd919e4472e753296daccd6d344e3e2df0c2
  - name: itertools
    version: 0.11.0
    sha: b1c173a5686ce8bfa551b3563d0c2170bf24ca44da99c7ca4bfdab5418c3fe57
  - name: js-sys
    version: 0.3.64
    sha: c5f195fe497f702db0f318b07fdd68edb16955aed830df8363d837542f8f935a
  - name: kv-log-macro
    version: 1.0.7
    sha: 0de8b303297635ad57c9f5059fd9cee7a47f8e8daa09df0fcd07dd39fb22977f
  - name: lazy_static
    version: 1.4.0
    sha: e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646
  - name: libadwaita
    version: 0.5.2
    sha: 06444f4ca05a60693da6e9e2b591bd40a298e65a118a8d5e830771718b3e0253
  - name: libadwaita-sys
    version: 0.5.2
    sha: 021cfe3d1fcfa82411765a791f7e9b32f35dd98ce88d2e3fa10e7320f5cc8ce7
  - name: libc
    version: 0.2.148
    sha: 9cdc71e17332e86d2e1d38c1f99edcb6288ee11b815fb1a4b049eaa2114d369b
  - name: linux-raw-sys
    version: 0.3.8
    sha: ef53942eb7bf7ff43a617b3e2c1c4a5ecf5944a7c1bc12d7ee39bbb15e5c1519
  - name: linux-raw-sys
    version: 0.4.7
    sha: 1a9bad9f94746442c783ca431b22403b519cd7fbeed0533fdd6328b2f2212128
  - name: locale_config
    version: 0.3.0
    sha: 08d2c35b16f4483f6c26f0e4e9550717a2f6575bcd6f12a53ff0c490a94a6934
  - name: log
    version: 0.4.20
    sha: b5e6163cb8c49088c2c36f57875e58ccd8c87c7427f7fbd50ea6710b2f3f2e8f
  - name: malloc_buf
    version: 0.0.6
    sha: 62bb907fe88d54d8d9ce32a3cceab4218ed2f6b7d35617cafe9adf84e43919cb
  - name: memchr
    version: 2.6.3
    sha: 8f232d6ef707e1956a43342693d2a31e72989554d58299d7a88738cc95b0d35c
  - name: memoffset
    version: 0.7.1
    sha: 5de893c32cde5f383baa4c04c5d6dbdd735cfd4a794b0debdb2bb1b421da5ff4
  - name: memoffset
    version: 0.9.0
    sha: 5a634b1c61a95585bd15607c6ab0c4e5b226e695ff2800ba0cdccddf208c406c
  - name: muldiv
    version: 1.0.1
    sha: 956787520e75e9bd233246045d19f42fb73242759cc57fba9611d940ae96d4b0
  - name: nix
    version: 0.26.4
    sha: 598beaf3cc6fdd9a5dfb1630c2800c7acd31df7aaf0f565796fba2b53ca1af1b
  - name: nu-ansi-term
    version: 0.46.0
    sha: 77a8165726e8236064dbb45459242600304b42a5ea24ee2948e18e023bf7ba84
  - name: num-integer
    version: 0.1.45
    sha: 225d3389fb3509a24c93f5c29eb6bde2586b98d9f016636dff58d7c6f7569cd9
  - name: num-rational
    version: 0.4.1
    sha: 0638a1c9d0a3c0914158145bc76cff373a75a627e6ecbfb71cbe6f453a5a19b0
  - name: num-traits
    version: 0.2.16
    sha: f30b0abd723be7e2ffca1272140fac1a2f084c77ec3e123c192b66af1ee9e6c2
  - name: objc
    version: 0.2.7
    sha: 915b1b472bc21c53464d6c8461c9d3af805ba1ef837e1cac254428f4a77177b1
  - name: objc-foundation
    version: 0.1.1
    sha: 1add1b659e36c9607c7aab864a76c7a4c2760cd0cd2e120f3fb8b952c7e22bf9
  - name: objc_id
    version: 0.1.1
    sha: c92d4ddb4bd7b50d730c215ff871754d0da6b2178849f8a2a2ab69712d0c073b
  - name: once_cell
    version: 1.18.0
    sha: dd8b5dd2ae5ed71462c540258bedcb51965123ad7e7ccf4b9a8cafaa4a63576d
  - name: option-operations
    version: 0.5.0
    sha: 7c26d27bb1aeab65138e4bf7666045169d1717febcc9ff870166be8348b223d0
  - name: ordered-stream
    version: 0.2.0
    sha: 9aa2b01e1d916879f73a53d01d1d6cee68adbb31d6d9177a8cfce093cced1d50
  - name: overload
    version: 0.1.1
    sha: b15813163c1d831bf4a13c3610c05c0d03b39feb07f7e09fa234dac9b15aaf39
  - name: pango
    version: 0.18.0
    sha: 06a9e54b831d033206160096b825f2070cf5fda7e35167b1c01e9e774f9202d1
  - name: pango-sys
    version: 0.18.0
    sha: 436737e391a843e5933d6d9aa102cb126d501e815b83601365a948a518555dc5
  - name: parking
    version: 2.1.0
    sha: 14f2252c834a40ed9bb5422029649578e63aa341ac401f74e719dd1afda8394e
  - name: paste
    version: 1.0.14
    sha: de3145af08024dea9fa9914f381a17b8fc6034dfb00f3a84013f7ff43f29ed4c
  - name: percent-encoding
    version: 2.3.0
    sha: 9b2a4787296e9989611394c33f193f676704af1686e70b8f8033ab5ba9a35a94
  - name: pin-project-lite
    version: 0.2.13
    sha: 8afb450f006bf6385ca15ef45d71d2288452bc3683ce2e2cacc0d18e4be60b58
  - name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - name: pkg-config
    version: 0.3.27
    sha: 26072860ba924cbfa98ea39c8c19b4dd6a4a25423dbdf219c1eca91aa0cf6964
  - name: polling
    version: 2.8.0
    sha: 4b2d323e8ca7996b3e23126511a523f7e62924d93ecd5ae73b333815b0eb3dce
  - name: ppv-lite86
    version: 0.2.17
    sha: 5b40af805b3121feab8a3c29f04d8ad262fa8e0561883e7653e024ae4479e6de
  - name: pretty-hex
    version: 0.3.0
    sha: c6fa0831dd7cc608c38a5e323422a0077678fa5744aa2be4ad91c4ece8eec8d5
  - name: proc-macro-crate
    version: 1.3.1
    sha: 7f4c021e1093a56626774e81216a4ce732a735e5bad4868a03f3ed65ca0c3919
  - name: proc-macro-error
    version: 1.0.4
    sha: da25490ff9892aab3fcf7c36f08cfb902dd3e71ca0f9f9517bea02a73a5ce38c
  - name: proc-macro-error-attr
    version: 1.0.4
    sha: a1be40180e52ecc98ad80b184934baf3d0d29f979574e439af5a55274b35f869
  - name: proc-macro2
    version: 1.0.67
    sha: 3d433d9f1a3e8c1263d9456598b16fec66f4acc9a74dacffd35c7bb09b3a1328
  - name: quote
    version: 1.0.33
    sha: 5267fca4496028628a95160fc423a33e8b2e6af8a5302579e322e4b520293cae
  - name: rand
    version: 0.8.5
    sha: 34af8d1a0e25924bc5b7c43c079c942339d8f0a8b57c39049bef581b46327404
  - name: rand_chacha
    version: 0.3.1
    sha: e6c10a63a0fa32252be49d21e7709d4d4baf8d231c2dbce1eaa8141b9b127d88
  - name: rand_core
    version: 0.6.4
    sha: ec0be4795e2f6a28069bec0b5ff3e2ac9bafc99e6a9a7dc3547996c5c816922c
  - name: redox_syscall
    version: 0.3.5
    sha: 567664f262709473930a4bf9e51bf2ebf3348f2e748ccc50dea20646858f8f29
  - name: regex
    version: 1.9.5
    sha: 697061221ea1b4a94a624f67d0ae2bfe4e22b8a17b6a192afb11046542cc8c47
  - name: regex-automata
    version: 0.3.8
    sha: c2f401f4955220693b56f8ec66ee9c78abffd8d1c4f23dc41a23839eb88f0795
  - name: regex-syntax
    version: 0.7.5
    sha: dbb5fb1acd8a1a18b3dd5be62d25485eb770e05afb408a9627d14d451bae12da
  - name: rustc_version
    version: 0.4.0
    sha: bfa0f585226d2e68097d4f95d113b15b83a82e819ab25717ec0590d9584ef366
  - name: rustix
    version: 0.37.23
    sha: 4d69718bf81c6127a49dc64e44a742e8bb9213c0ff8869a22c308f84c1d4ab06
  - name: rustix
    version: 0.38.13
    sha: d7db8590df6dfcd144d22afd1b83b36c21a18d7cbc1dc4bb5295a8712e9eb662
  - name: semver
    version: 1.0.18
    sha: b0293b4b29daaf487284529cc2f5675b8e57c61f70167ba415a463651fd6a918
  - name: serde
    version: 1.0.188
    sha: cf9e0fcba69a370eed61bcf2b728575f726b50b55cba78064753d708ddc7549e
  - name: serde_derive
    version: 1.0.188
    sha: 4eca7ac642d82aa35b60049a6eccb4be6be75e599bd2e9adb5f875a737654af2
  - name: serde_repr
    version: 0.1.16
    sha: 8725e1dfadb3a50f7e5ce0b1a540466f6ed3fe7a0fca2ac2b8b831d31316bd00
  - name: serde_spanned
    version: 0.6.3
    sha: 96426c9936fd7a0124915f9185ea1d20aa9445cc9821142f0a73bc9207a2e186
  - name: sha1
    version: 0.10.5
    sha: f04293dc80c3993519f2d7f6f511707ee7094fe0c6d3406feb330cdb3540eba3
  - name: sharded-slab
    version: 0.1.4
    sha: 900fba806f70c630b0a382d0d825e17a0f19fcd059a2ade1ff237bcddf446b31
  - name: signal-hook
    version: 0.3.17
    sha: 8621587d4798caf8eb44879d42e56b9a93ea5dcd315a6487c357130095b62801
  - name: signal-hook-registry
    version: 1.4.1
    sha: d8229b473baa5980ac72ef434c4415e70c4b5e71b423043adb4ba059f89c99a1
  - name: slab
    version: 0.4.9
    sha: 8f92a496fb766b417c996b9c5e57daf2f7ad3b0bebe1ccfca4856390e3d3bb67
  - name: smallvec
    version: 1.11.0
    sha: 62bb4feee49fdd9f707ef802e22365a35de4b7b299de4763d44bfea899442ff9
  - name: socket2
    version: 0.4.9
    sha: 64a4a911eed85daf18834cfaa86a79b7d266ff93ff5ba14005426219480ed662
  - name: static_assertions
    version: 1.1.0
    sha: a2eb9349b6444b326872e140eb1cf5e7c522154d69e7a0ffb0fb81c06b37543f
  - name: syn
    version: 1.0.109
    sha: 72b64191b275b66ffe2469e8af2c1cfe3bafa67b529ead792a6d0160888b4237
  - name: syn
    version: 2.0.35
    sha: 59bf04c28bee9043ed9ea1e41afc0552288d3aba9c6efdd78903b802926f4879
  - name: system-deps
    version: 6.1.1
    sha: 30c2de8a4d8f4b823d634affc9cd2a74ec98c53a756f317e529a48046cbf71f3
  - name: target-lexicon
    version: 0.12.11
    sha: 9d0e916b1148c8e263850e1ebcbd046f333e0683c724876bb0da63ea4373dc8a
  - name: temp-dir
    version: 0.1.11
    sha: af547b166dd1ea4b472165569fc456cfb6818116f854690b0ff205e636523dab
  - name: tempfile
    version: 3.8.0
    sha: cb94d2f3cc536af71caac6b6fcebf65860b347e7ce0cc9ebe8f70d3e521054ef
  - name: thiserror
    version: 1.0.48
    sha: 9d6d7a740b8a666a7e828dd00da9c0dc290dff53154ea77ac109281de90589b7
  - name: thiserror-impl
    version: 1.0.48
    sha: 49922ecae66cc8a249b77e68d1d0623c1b2c514f0060c27cdc68bd62a1219d35
  - name: thread_local
    version: 1.1.7
    sha: 3fdd6f064ccff2d6567adcb3873ca630700f00b5ad3f060c25b5dcfd9a4ce152
  - name: tinyvec
    version: 1.6.0
    sha: 87cc5ceb3875bb20c2890005a4e226a4651264a5c75edb2421b52861a0a0cb50
  - name: tinyvec_macros
    version: 0.1.1
    sha: 1f3ccbac311fea05f86f61904b462b55fb3df8837a366dfc601a0161d0532f20
  - name: toml
    version: 0.7.8
    sha: dd79e69d3b627db300ff956027cc6c3798cef26d22526befdfcd12feeb6d2257
  - name: toml_datetime
    version: 0.6.3
    sha: 7cda73e2f1397b1262d6dfdcef8aafae14d1de7748d66822d3bfeeb6d03e5e4b
  - name: toml_edit
    version: 0.19.15
    sha: 1b5bb770da30e5cbfde35a2d7b9b8a2c4b8ef89548a7a6aeab5c9a576e3e7421
  - name: tracing
    version: 0.1.37
    sha: 8ce8c33a8d48bd45d624a6e523445fd21ec13d3653cd51f681abf67418f54eb8
  - name: tracing-attributes
    version: 0.1.26
    sha: 5f4f31f56159e98206da9efd823404b79b6ef3143b4a7ab76e67b1751b25a4ab
  - name: tracing-core
    version: 0.1.31
    sha: 0955b8137a1df6f1a2e9a37d8a6656291ff0297c1a97c24e0d8425fe2312f79a
  - name: tracing-log
    version: 0.1.3
    sha: 78ddad33d2d10b1ed7eb9d1f518a5674713876e97e5bb9b7345a7984fbb4f922
  - name: tracing-subscriber
    version: 0.3.17
    sha: 30a651bc37f915e81f087d86e62a18eec5f79550c7faff886f7090b4ea757c77
  - name: typenum
    version: 1.17.0
    sha: 42ff0bf0c66b8238c6f3b578df37d0b7848e55df8577b3f74f92a69acceeb825
  - name: uds_windows
    version: 1.0.2
    sha: ce65604324d3cce9b966701489fbd0cf318cb1f7bd9dd07ac9a4ee6fb791930d
  - name: unicode-bidi
    version: 0.3.13
    sha: 92888ba5573ff080736b3648696b70cafad7d250551175acbaa4e0385b3e1460
  - name: unicode-ident
    version: 1.0.12
    sha: 3354b9ac3fae1ff6755cb6db53683adb661634f67557942dea4facebec0fee4b
  - name: unicode-normalization
    version: 0.1.22
    sha: 5c5713f0fc4b5db668a2ac63cdb7bb4469d8c9fed047b1d0292cc7b0ce2ba921
  - name: url
    version: 2.4.1
    sha: 143b538f18257fac9cad154828a57c6bf5157e1aa604d4816b5995bf6de87ae5
  - name: valuable
    version: 0.1.0
    sha: 830b7e5d4d90034032940e4ace0d9a9a057e7a45cd94e6c007832e39edb82f6d
  - name: value-bag
    version: 1.4.1
    sha: d92ccd67fb88503048c01b59152a04effd0782d035a83a6d256ce6085f08f4a3
  - name: version-compare
    version: 0.1.1
    sha: 579a42fc0b8e0c63b76519a339be31bed574929511fa53c1a3acae26eb258f29
  - name: version_check
    version: 0.9.4
    sha: 49874b5167b65d7193b8aba1567f5c7d93d001cafc34600cee003eda787e483f
  - name: waker-fn
    version: 1.1.0
    sha: 9d5b2c62b4012a3e1eca5a7e077d13b3bf498c4073e33ccd58626607748ceeca
  - name: wasi
    version: 0.11.0+wasi-snapshot-preview1
    sha: 9c8d87e72b64a3b4db28d11ce29237c246188f4f51057d65a7eab63b7987e423
  - name: wasm-bindgen
    version: 0.2.87
    sha: 7706a72ab36d8cb1f80ffbf0e071533974a60d0a308d01a5d0375bf60499a342
  - name: wasm-bindgen-backend
    version: 0.2.87
    sha: 5ef2b6d3c510e9625e5fe6f509ab07d66a760f0885d858736483c32ed7809abd
  - name: wasm-bindgen-futures
    version: 0.4.37
    sha: c02dbc21516f9f1f04f187958890d7e6026df8d16540b7ad9492bc34a67cea03
  - name: wasm-bindgen-macro
    version: 0.2.87
    sha: dee495e55982a3bd48105a7b947fd2a9b4a8ae3010041b9e0faab3f9cd028f1d
  - name: wasm-bindgen-macro-support
    version: 0.2.87
    sha: 54681b18a46765f095758388f2d0cf16eb8d4169b639ab575a8f5693af210c7b
  - name: wasm-bindgen-shared
    version: 0.2.87
    sha: ca6ad05a4870b2bf5fe995117d3728437bd27d7cd5f06f13c17443ef369775a1
  - name: web-sys
    version: 0.3.64
    sha: 9b85cbef8c220a6abc02aefd892dfc0fc23afb1c6a426316ec33253a3877249b
  - name: winapi
    version: 0.3.9
    sha: 5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419
  - name: winapi-i686-pc-windows-gnu
    version: 0.4.0
    sha: ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6
  - name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
  - name: windows
    version: 0.48.0
    sha: e686886bc078bc1b0b600cac0147aadb815089b6e4da64016cbd754b6342700f
  - name: windows-sys
    version: 0.48.0
    sha: 677d2418bec65e3338edb076e806bc1ec15693c5d0104683f2efe857f61056a9
  - name: windows-targets
    version: 0.48.5
    sha: 9a2fa6e2155d7247be68c096456083145c183cbbbc2764150dda45a87197940c
  - name: windows_aarch64_gnullvm
    version: 0.48.5
    sha: 2b38e32f0abccf9987a4e3079dfb67dcd799fb61361e53e2882c3cbaf0d905d8
  - name: windows_aarch64_msvc
    version: 0.48.5
    sha: dc35310971f3b2dbbf3f0690a219f40e2d9afcf64f9ab7cc1be722937c26b4bc
  - name: windows_i686_gnu
    version: 0.48.5
    sha: a75915e7def60c94dcef72200b9a8e58e5091744960da64ec734a6c6e9b3743e
  - name: windows_i686_msvc
    version: 0.48.5
    sha: 8f55c233f70c4b27f66c523580f78f1004e8b5a8b659e05a4eb49d4166cca406
  - name: windows_x86_64_gnu
    version: 0.48.5
    sha: 53d40abd2583d23e4718fddf1ebec84dbff8381c07cae67ff7768bbf19c6718e
  - name: windows_x86_64_gnullvm
    version: 0.48.5
    sha: 0b7b52767868a23d5bab768e390dc5f5c55825b6d30b86c844ff2dc7414044cc
  - name: windows_x86_64_msvc
    version: 0.48.5
    sha: ed94fce61571a4006852b7389a063ab983c02eb1bb37b47f8272ce92d06d9538
  - name: winnow
    version: 0.5.15
    sha: 7c2e3184b9c4e92ad5167ca73039d0c42476302ab603e2fec4487511f38ccefc
  - name: xdg-home
    version: 1.0.0
    sha: 2769203cd13a0c6015d515be729c526d041e9cf2c0cc478d57faee85f40c6dcd
  - name: zbus
    version: 3.14.1
    sha: 31de390a2d872e4cd04edd71b425e29853f786dc99317ed72d73d6fcf5ebb948
  - name: zbus_macros
    version: 3.14.1
    sha: 41d1794a946878c0e807f55a397187c11fc7a038ba5d868e7db4f3bd7760bc9d
  - name: zbus_names
    version: 2.6.0
    sha: fb80bb776dbda6e23d705cf0123c3b95df99c4ebeaec6c2599d4a5419902b4a9
  - name: zvariant
    version: 3.15.0
    sha: 44b291bee0d960c53170780af148dca5fa260a63cdd24f1962fa82e03e53338c
  - name: zvariant_derive
    version: 3.15.0
    sha: 934d7a7dfc310d6ee06c87ffe88ef4eca7d3e37bb251dece2ef93da8f17d8ecd
  - name: zvariant_utils
    version: 1.0.1
    sha: 7234f0d811589db492d16893e3f21e8e2fd282e6d01b0cddee310322062cc200
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/adwaita-icon-theme.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-bad.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-base.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-good.bst
