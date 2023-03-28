kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-tour/43/gnome-tour-43.0.tar.xz
  ref: 1351e419627fbd7c771932a6ef1ad80c0bf2e6828c4948a062068984ddb3cc88
- kind: cargo

  ref:
  - name: aho-corasick
    version: 0.7.19
    sha: b4f55bd91a0978cbfd91c457a164bab8b4001c833b7f323132c0a4e1922dd44e
  - name: anyhow
    version: 1.0.65
    sha: 98161a4e3e2184da77bb14f02184cdd111e83bbbcc9979dfee3c44b9a85f5602
  - name: atty
    version: 0.2.14
    sha: d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8
  - name: autocfg
    version: 1.1.0
    sha: d468802bab17cbc0cc575e9b053f41e72aa36bfa6b7f55e3529ffa43161b97fa
  - name: bitflags
    version: 1.3.2
    sha: bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a
  - name: block
    version: 0.1.6
    sha: 0d8c1fef690941d3e7788d328517591fecc684c084084702d6ff1641e993699a
  - name: cairo-rs
    version: 0.15.12
    sha: c76ee391b03d35510d9fa917357c7f1855bd9a6659c95a1b392e33f49b3369bc
  - name: cairo-sys-rs
    version: 0.15.1
    sha: 3c55d429bef56ac9172d25fecb85dc8068307d17acd74b377866b7a1ef25d3c8
  - name: cc
    version: 1.0.73
    sha: 2fff2a6927b3bb87f9595d67196a70493f627687a71d87a0d692242c33f58c11
  - name: cfg-expr
    version: 0.10.3
    sha: 0aacacf4d96c24b2ad6eb8ee6df040e4f27b0d0b39a5710c30091baa830485db
  - name: cfg-if
    version: 1.0.0
    sha: baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd
  - name: env_logger
    version: 0.7.1
    sha: 44533bbbb3bb3c1fa17d9f2e4e38bbbaf8396ba82193c4cb1b6445d711445d36
  - name: field-offset
    version: 0.3.4
    sha: 1e1c54951450cbd39f3dbcf1005ac413b49487dabf18a720ad2383eccfeffb92
  - name: futures-channel
    version: 0.3.24
    sha: 30bdd20c28fadd505d0fd6712cdfcb0d4b5648baf45faef7f852afb2399bb050
  - name: futures-core
    version: 0.3.24
    sha: 4e5aa3de05362c3fb88de6531e6296e85cde7739cccad4b9dfeeb7f6ebce56bf
  - name: futures-executor
    version: 0.3.24
    sha: 9ff63c23854bee61b6e9cd331d523909f238fc7636290b96826e9cfa5faa00ab
  - name: futures-io
    version: 0.3.24
    sha: bbf4d2a7a308fd4578637c0b17c7e1c7ba127b8f6ba00b29f717e9655d85eb68
  - name: futures-task
    version: 0.3.24
    sha: a6508c467c73851293f390476d4491cf4d227dbabcd4170f3bb6044959b294f1
  - name: futures-util
    version: 0.3.24
    sha: 44fb6cb1be61cc1d2e43b262516aafcf63b241cffdb1d3fa115f91d9c7b09c90
  - name: gdk-pixbuf
    version: 0.15.11
    sha: ad38dd9cc8b099cceecdf41375bb6d481b1b5a7cd5cd603e10a69a9383f8619a
  - name: gdk-pixbuf-sys
    version: 0.15.10
    sha: 140b2f5378256527150350a8346dbdb08fadc13453a7a2d73aecd5fab3c402a7
  - name: gdk4
    version: 0.4.8
    sha: 4fabb7cf843c26b085a5d68abb95d0c0bf27a9ae2eeff9c4adb503a1eb580876
  - name: gdk4-sys
    version: 0.4.8
    sha: efe7dcb44f5c00aeabff3f69abfc5673de46559070f89bd3fbb7b66485d9cef2
  - name: gettext-rs
    version: 0.7.0
    sha: e49ea8a8fad198aaa1f9655a2524b64b70eb06b2f3ff37da407566c93054f364
  - name: gettext-sys
    version: 0.21.3
    sha: c63ce2e00f56a206778276704bbe38564c8695249fdc8f354b4ef71c57c3839d
  - name: gio
    version: 0.15.12
    sha: 68fdbc90312d462781a395f7a16d96a2b379bb6ef8cd6310a2df272771c4283b
  - name: gio-sys
    version: 0.15.10
    sha: 32157a475271e2c4a023382e9cab31c4584ee30a97da41d3c4e9fdd605abcf8d
  - name: glib
    version: 0.15.12
    sha: edb0306fbad0ab5428b0ca674a23893db909a98582969c9b537be4ced78c505d
  - name: glib-macros
    version: 0.15.11
    sha: 25a68131a662b04931e71891fb14aaf65ee4b44d08e8abc10f49e77418c86c64
  - name: glib-sys
    version: 0.15.10
    sha: ef4b192f8e65e9cf76cbf4ea71fa8e3be4a0e18ffe3d68b8da6836974cc5bad4
  - name: gobject-sys
    version: 0.15.10
    sha: 0d57ce44246becd17153bd035ab4d32cfee096a657fc01f2231c9278378d1e0a
  - name: graphene-rs
    version: 0.15.1
    sha: 7c54f9fbbeefdb62c99f892dfca35f83991e2cb5b46a8dc2a715e58612f85570
  - name: graphene-sys
    version: 0.15.10
    sha: fa691fc7337ba1df599afb55c3bcb85c04f1b3f17362570e9bb0ff0d1bc3028a
  - name: gsk4
    version: 0.4.8
    sha: 05e9020d333280b3aa38d496495bfa9b50712eebf1ad63f0ec5bcddb5eb61be4
  - name: gsk4-sys
    version: 0.4.8
    sha: 7add39ccf60078508c838643a2dcc91f045c46ed63b5ea6ab701b2e25bda3fea
  - name: gtk4
    version: 0.4.8
    sha: c64f0c2a3d80e899dc3febddad5bac193ffcf74a0fd7e31037f30dd34d6f7396
  - name: gtk4-macros
    version: 0.4.8
    sha: fafbcc920af4eb677d7d164853e7040b9de5a22379c596f570190c675d45f7a7
  - name: gtk4-sys
    version: 0.4.8
    sha: 5bc8006eea634b7c72da3ff79e24606e45f21b3b832a3c5a1f543f5f97eb0f63
  - name: heck
    version: 0.4.0
    sha: 2540771e65fc8cb83cd6e8a237f70c319bd5c29f78ed1084ba5d50eeac86f7f9
  - name: hermit-abi
    version: 0.1.19
    sha: 62b467343b94ba476dcb2500d242dadbb39557df889310ac77c5d99100aaac33
  - name: humantime
    version: 1.3.0
    sha: df004cfca50ef23c36850aaaa59ad52cc70d0e90243c3c7737a4dd32dc7a3c4f
  - name: lazy_static
    version: 1.4.0
    sha: e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646
  - name: libadwaita
    version: 0.1.1
    sha: f2ae453d28e3b91f03749f02b1531e8cfe315a1d0762b77a61797d2ab80bb87d
  - name: libadwaita-sys
    version: 0.1.0
    sha: f18b6ac4cadd252a89f5cba0a5a4e99836131795d6fad37b859ac79e8cb7d2c8
  - name: libc
    version: 0.2.133
    sha: c0f80d65747a3e43d1596c7c5492d95d5edddaabd45a7fcdb02b95f644164966
  - name: locale_config
    version: 0.3.0
    sha: 08d2c35b16f4483f6c26f0e4e9550717a2f6575bcd6f12a53ff0c490a94a6934
  - name: log
    version: 0.4.17
    sha: abb12e687cfb44aa40f41fc3978ef76448f9b6038cad6aef4259d3c095a2382e
  - name: malloc_buf
    version: 0.0.6
    sha: 62bb907fe88d54d8d9ce32a3cceab4218ed2f6b7d35617cafe9adf84e43919cb
  - name: memchr
    version: 2.5.0
    sha: 2dffe52ecf27772e601905b7522cb4ef790d2cc203488bbd0e2fe85fcb74566d
  - name: memoffset
    version: 0.6.5
    sha: 5aa361d4faea93603064a027415f07bd8e1d5c88c9fbf68bf56a285428fd79ce
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
    version: 1.14.0
    sha: 2f7254b99e31cad77da24b08ebf628882739a608578bb1bcdfc1f9c21260d7c0
  - name: pango
    version: 0.15.10
    sha: 22e4045548659aee5313bde6c582b0d83a627b7904dd20dc2d9ef0895d414e4f
  - name: pango-sys
    version: 0.15.10
    sha: d2a00081cde4661982ed91d80ef437c20eacaf6aa1a5962c0279ae194662c3aa
  - name: pest
    version: 2.3.1
    sha: cb779fcf4bb850fbbb0edc96ff6cf34fd90c4b1a112ce042653280d9a7364048
  - name: pin-project-lite
    version: 0.2.9
    sha: e0a7ae3ac2f1173085d398531c705756c94a4c56843785df85a60c1a0afac116
  - name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - name: pkg-config
    version: 0.3.25
    sha: 1df8c4ec4b0627e53bdf214615ad287367e482558cf84b109250b37464dc03ae
  - name: pretty_env_logger
    version: 0.4.0
    sha: 926d36b9553851b8b0005f1275891b392ee4d2d833852c417ed025477350fb9d
  - name: proc-macro-crate
    version: 1.2.1
    sha: eda0fc3b0fb7c975631757e14d9049da17374063edb6ebbcbc54d880d4fe94e9
  - name: proc-macro-error
    version: 1.0.4
    sha: da25490ff9892aab3fcf7c36f08cfb902dd3e71ca0f9f9517bea02a73a5ce38c
  - name: proc-macro-error-attr
    version: 1.0.4
    sha: a1be40180e52ecc98ad80b184934baf3d0d29f979574e439af5a55274b35f869
  - name: proc-macro2
    version: 1.0.43
    sha: 0a2ca2c61bc9f3d74d2886294ab7b9853abd9c1ad903a3ac7815c58989bb7bab
  - name: quick-error
    version: 1.2.3
    sha: a1d01941d82fa2ab50be1e79e6714289dd7cde78eba4c074bc5a4374f650dfe0
  - name: quick-xml
    version: 0.22.0
    sha: 8533f14c8382aaad0d592c812ac3b826162128b65662331e1127b45c3d18536b
  - name: quote
    version: 1.0.21
    sha: bbe448f377a7d6961e30f5955f9b8d106c3f5e449d493ee1b125c1d43c2b5179
  - name: regex
    version: 1.6.0
    sha: 4c4eb3267174b8c6c2f654116623910a0fef09c4753f8dd83db29c48a0df988b
  - name: regex-syntax
    version: 0.6.27
    sha: a3f87b73ce11b1619a3c6332f45341e0047173771e8b8b73f87bfeefb7b56244
  - name: rustc_version
    version: 0.3.3
    sha: f0dfe2087c51c460008730de8b57e6a320782fbfb312e1f4d520e6c6fae155ee
  - name: semver
    version: 0.11.0
    sha: f301af10236f6df4160f7c3f04eec6dbc70ace82d23326abad5edee88801c6b6
  - name: semver-parser
    version: 0.10.2
    sha: 00b0bef5b7f9e0df16536d3961cfb6e84331c065b4066afb39768d0e319411f7
  - name: serde
    version: 1.0.144
    sha: 0f747710de3dcd43b88c9168773254e809d8ddbdf9653b84e2554ab219f17860
  - name: slab
    version: 0.4.7
    sha: 4614a76b2a8be0058caa9dbbaf66d988527d86d003c11a94fbd335d7661edcef
  - name: smallvec
    version: 1.9.0
    sha: 2fd0db749597d91ff862fd1d55ea87f7855a744a8425a64695b6fca237d1dad1
  - name: syn
    version: 1.0.100
    sha: 52205623b1b0f064a4e71182c3b18ae902267282930c6d5462c91b859668426e
  - name: system-deps
    version: 6.0.2
    sha: a1a45a1c4c9015217e12347f2a411b57ce2c4fc543913b14b6fe40483328e709
  - name: temp-dir
    version: 0.1.11
    sha: af547b166dd1ea4b472165569fc456cfb6818116f854690b0ff205e636523dab
  - name: termcolor
    version: 1.1.3
    sha: bab24d30b911b2376f3a13cc2cd443142f0c81dda04c118693e35b3835757755
  - name: thiserror
    version: 1.0.35
    sha: c53f98874615aea268107765aa1ed8f6116782501d18e53d08b471733bea6c85
  - name: thiserror-impl
    version: 1.0.35
    sha: f8b463991b4eab2d801e724172285ec4195c650e8ec79b149e6c2a8e6dd3f783
  - name: toml
    version: 0.5.9
    sha: 8d82e1a7758622a465f8cee077614c73484dac5b836c02ff6a40d5d1010324d7
  - name: ucd-trie
    version: 0.1.5
    sha: 9e79c4d996edb816c91e4308506774452e55e95c3c9de07b6729e17e15a5ef81
  - name: unicode-ident
    version: 1.0.4
    sha: dcc811dc4066ac62f84f11307873c4850cb653bfa9b1719cee2bd2204a4bc5dd
  - name: version-compare
    version: 0.1.0
    sha: fe88247b92c1df6b6de80ddc290f3976dbdf2f5f5d3fd049a9fb598c6dd5ca73
  - name: version_check
    version: 0.9.4
    sha: 49874b5167b65d7193b8aba1567f5c7d93d001cafc34600cee003eda787e483f
  - name: winapi
    version: 0.3.9
    sha: 5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419
  - name: winapi-i686-pc-windows-gnu
    version: 0.4.0
    sha: ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6
  - name: winapi-util
    version: 0.1.5
    sha: 70ec6ce85bb158151cae5e5c87f95a8e97d2c0c4b001223f33a334e3ce5de178
  - name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
- kind: patch
  path: patches/gnome-tour/0001-rlxos-specific-changes.patch
- kind: patch
  path: patches/gnome-tour/0002-update-interface.patch

  ref:
  - name: aho-corasick
    version: 0.7.19
    sha: b4f55bd91a0978cbfd91c457a164bab8b4001c833b7f323132c0a4e1922dd44e
  - name: anyhow
    version: 1.0.65
    sha: 98161a4e3e2184da77bb14f02184cdd111e83bbbcc9979dfee3c44b9a85f5602
  - name: atty
    version: 0.2.14
    sha: d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8
  - name: autocfg
    version: 1.1.0
    sha: d468802bab17cbc0cc575e9b053f41e72aa36bfa6b7f55e3529ffa43161b97fa
  - name: bitflags
    version: 1.3.2
    sha: bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a
  - name: block
    version: 0.1.6
    sha: 0d8c1fef690941d3e7788d328517591fecc684c084084702d6ff1641e993699a
  - name: cairo-rs
    version: 0.15.12
    sha: c76ee391b03d35510d9fa917357c7f1855bd9a6659c95a1b392e33f49b3369bc
  - name: cairo-sys-rs
    version: 0.15.1
    sha: 3c55d429bef56ac9172d25fecb85dc8068307d17acd74b377866b7a1ef25d3c8
  - name: cc
    version: 1.0.73
    sha: 2fff2a6927b3bb87f9595d67196a70493f627687a71d87a0d692242c33f58c11
  - name: cfg-expr
    version: 0.10.3
    sha: 0aacacf4d96c24b2ad6eb8ee6df040e4f27b0d0b39a5710c30091baa830485db
  - name: cfg-if
    version: 1.0.0
    sha: baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd
  - name: env_logger
    version: 0.7.1
    sha: 44533bbbb3bb3c1fa17d9f2e4e38bbbaf8396ba82193c4cb1b6445d711445d36
  - name: field-offset
    version: 0.3.4
    sha: 1e1c54951450cbd39f3dbcf1005ac413b49487dabf18a720ad2383eccfeffb92
  - name: futures-channel
    version: 0.3.24
    sha: 30bdd20c28fadd505d0fd6712cdfcb0d4b5648baf45faef7f852afb2399bb050
  - name: futures-core
    version: 0.3.24
    sha: 4e5aa3de05362c3fb88de6531e6296e85cde7739cccad4b9dfeeb7f6ebce56bf
  - name: futures-executor
    version: 0.3.24
    sha: 9ff63c23854bee61b6e9cd331d523909f238fc7636290b96826e9cfa5faa00ab
  - name: futures-io
    version: 0.3.24
    sha: bbf4d2a7a308fd4578637c0b17c7e1c7ba127b8f6ba00b29f717e9655d85eb68
  - name: futures-task
    version: 0.3.24
    sha: a6508c467c73851293f390476d4491cf4d227dbabcd4170f3bb6044959b294f1
  - name: futures-util
    version: 0.3.24
    sha: 44fb6cb1be61cc1d2e43b262516aafcf63b241cffdb1d3fa115f91d9c7b09c90
  - name: gdk-pixbuf
    version: 0.15.11
    sha: ad38dd9cc8b099cceecdf41375bb6d481b1b5a7cd5cd603e10a69a9383f8619a
  - name: gdk-pixbuf-sys
    version: 0.15.10
    sha: 140b2f5378256527150350a8346dbdb08fadc13453a7a2d73aecd5fab3c402a7
  - name: gdk4
    version: 0.4.8
    sha: 4fabb7cf843c26b085a5d68abb95d0c0bf27a9ae2eeff9c4adb503a1eb580876
  - name: gdk4-sys
    version: 0.4.8
    sha: efe7dcb44f5c00aeabff3f69abfc5673de46559070f89bd3fbb7b66485d9cef2
  - name: gettext-rs
    version: 0.7.0
    sha: e49ea8a8fad198aaa1f9655a2524b64b70eb06b2f3ff37da407566c93054f364
  - name: gettext-sys
    version: 0.21.3
    sha: c63ce2e00f56a206778276704bbe38564c8695249fdc8f354b4ef71c57c3839d
  - name: gio
    version: 0.15.12
    sha: 68fdbc90312d462781a395f7a16d96a2b379bb6ef8cd6310a2df272771c4283b
  - name: gio-sys
    version: 0.15.10
    sha: 32157a475271e2c4a023382e9cab31c4584ee30a97da41d3c4e9fdd605abcf8d
  - name: glib
    version: 0.15.12
    sha: edb0306fbad0ab5428b0ca674a23893db909a98582969c9b537be4ced78c505d
  - name: glib-macros
    version: 0.15.11
    sha: 25a68131a662b04931e71891fb14aaf65ee4b44d08e8abc10f49e77418c86c64
  - name: glib-sys
    version: 0.15.10
    sha: ef4b192f8e65e9cf76cbf4ea71fa8e3be4a0e18ffe3d68b8da6836974cc5bad4
  - name: gobject-sys
    version: 0.15.10
    sha: 0d57ce44246becd17153bd035ab4d32cfee096a657fc01f2231c9278378d1e0a
  - name: graphene-rs
    version: 0.15.1
    sha: 7c54f9fbbeefdb62c99f892dfca35f83991e2cb5b46a8dc2a715e58612f85570
  - name: graphene-sys
    version: 0.15.10
    sha: fa691fc7337ba1df599afb55c3bcb85c04f1b3f17362570e9bb0ff0d1bc3028a
  - name: gsk4
    version: 0.4.8
    sha: 05e9020d333280b3aa38d496495bfa9b50712eebf1ad63f0ec5bcddb5eb61be4
  - name: gsk4-sys
    version: 0.4.8
    sha: 7add39ccf60078508c838643a2dcc91f045c46ed63b5ea6ab701b2e25bda3fea
  - name: gtk4
    version: 0.4.8
    sha: c64f0c2a3d80e899dc3febddad5bac193ffcf74a0fd7e31037f30dd34d6f7396
  - name: gtk4-macros
    version: 0.4.8
    sha: fafbcc920af4eb677d7d164853e7040b9de5a22379c596f570190c675d45f7a7
  - name: gtk4-sys
    version: 0.4.8
    sha: 5bc8006eea634b7c72da3ff79e24606e45f21b3b832a3c5a1f543f5f97eb0f63
  - name: heck
    version: 0.4.0
    sha: 2540771e65fc8cb83cd6e8a237f70c319bd5c29f78ed1084ba5d50eeac86f7f9
  - name: hermit-abi
    version: 0.1.19
    sha: 62b467343b94ba476dcb2500d242dadbb39557df889310ac77c5d99100aaac33
  - name: humantime
    version: 1.3.0
    sha: df004cfca50ef23c36850aaaa59ad52cc70d0e90243c3c7737a4dd32dc7a3c4f
  - name: lazy_static
    version: 1.4.0
    sha: e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646
  - name: libadwaita
    version: 0.1.1
    sha: f2ae453d28e3b91f03749f02b1531e8cfe315a1d0762b77a61797d2ab80bb87d
  - name: libadwaita-sys
    version: 0.1.0
    sha: f18b6ac4cadd252a89f5cba0a5a4e99836131795d6fad37b859ac79e8cb7d2c8
  - name: libc
    version: 0.2.133
    sha: c0f80d65747a3e43d1596c7c5492d95d5edddaabd45a7fcdb02b95f644164966
  - name: locale_config
    version: 0.3.0
    sha: 08d2c35b16f4483f6c26f0e4e9550717a2f6575bcd6f12a53ff0c490a94a6934
  - name: log
    version: 0.4.17
    sha: abb12e687cfb44aa40f41fc3978ef76448f9b6038cad6aef4259d3c095a2382e
  - name: malloc_buf
    version: 0.0.6
    sha: 62bb907fe88d54d8d9ce32a3cceab4218ed2f6b7d35617cafe9adf84e43919cb
  - name: memchr
    version: 2.5.0
    sha: 2dffe52ecf27772e601905b7522cb4ef790d2cc203488bbd0e2fe85fcb74566d
  - name: memoffset
    version: 0.6.5
    sha: 5aa361d4faea93603064a027415f07bd8e1d5c88c9fbf68bf56a285428fd79ce
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
    version: 1.14.0
    sha: 2f7254b99e31cad77da24b08ebf628882739a608578bb1bcdfc1f9c21260d7c0
  - name: pango
    version: 0.15.10
    sha: 22e4045548659aee5313bde6c582b0d83a627b7904dd20dc2d9ef0895d414e4f
  - name: pango-sys
    version: 0.15.10
    sha: d2a00081cde4661982ed91d80ef437c20eacaf6aa1a5962c0279ae194662c3aa
  - name: pest
    version: 2.3.1
    sha: cb779fcf4bb850fbbb0edc96ff6cf34fd90c4b1a112ce042653280d9a7364048
  - name: pin-project-lite
    version: 0.2.9
    sha: e0a7ae3ac2f1173085d398531c705756c94a4c56843785df85a60c1a0afac116
  - name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - name: pkg-config
    version: 0.3.25
    sha: 1df8c4ec4b0627e53bdf214615ad287367e482558cf84b109250b37464dc03ae
  - name: pretty_env_logger
    version: 0.4.0
    sha: 926d36b9553851b8b0005f1275891b392ee4d2d833852c417ed025477350fb9d
  - name: proc-macro-crate
    version: 1.2.1
    sha: eda0fc3b0fb7c975631757e14d9049da17374063edb6ebbcbc54d880d4fe94e9
  - name: proc-macro-error
    version: 1.0.4
    sha: da25490ff9892aab3fcf7c36f08cfb902dd3e71ca0f9f9517bea02a73a5ce38c
  - name: proc-macro-error-attr
    version: 1.0.4
    sha: a1be40180e52ecc98ad80b184934baf3d0d29f979574e439af5a55274b35f869
  - name: proc-macro2
    version: 1.0.43
    sha: 0a2ca2c61bc9f3d74d2886294ab7b9853abd9c1ad903a3ac7815c58989bb7bab
  - name: quick-error
    version: 1.2.3
    sha: a1d01941d82fa2ab50be1e79e6714289dd7cde78eba4c074bc5a4374f650dfe0
  - name: quick-xml
    version: 0.22.0
    sha: 8533f14c8382aaad0d592c812ac3b826162128b65662331e1127b45c3d18536b
  - name: quote
    version: 1.0.21
    sha: bbe448f377a7d6961e30f5955f9b8d106c3f5e449d493ee1b125c1d43c2b5179
  - name: regex
    version: 1.6.0
    sha: 4c4eb3267174b8c6c2f654116623910a0fef09c4753f8dd83db29c48a0df988b
  - name: regex-syntax
    version: 0.6.27
    sha: a3f87b73ce11b1619a3c6332f45341e0047173771e8b8b73f87bfeefb7b56244
  - name: rustc_version
    version: 0.3.3
    sha: f0dfe2087c51c460008730de8b57e6a320782fbfb312e1f4d520e6c6fae155ee
  - name: semver
    version: 0.11.0
    sha: f301af10236f6df4160f7c3f04eec6dbc70ace82d23326abad5edee88801c6b6
  - name: semver-parser
    version: 0.10.2
    sha: 00b0bef5b7f9e0df16536d3961cfb6e84331c065b4066afb39768d0e319411f7
  - name: serde
    version: 1.0.144
    sha: 0f747710de3dcd43b88c9168773254e809d8ddbdf9653b84e2554ab219f17860
  - name: slab
    version: 0.4.7
    sha: 4614a76b2a8be0058caa9dbbaf66d988527d86d003c11a94fbd335d7661edcef
  - name: smallvec
    version: 1.9.0
    sha: 2fd0db749597d91ff862fd1d55ea87f7855a744a8425a64695b6fca237d1dad1
  - name: syn
    version: 1.0.100
    sha: 52205623b1b0f064a4e71182c3b18ae902267282930c6d5462c91b859668426e
  - name: system-deps
    version: 6.0.2
    sha: a1a45a1c4c9015217e12347f2a411b57ce2c4fc543913b14b6fe40483328e709
  - name: temp-dir
    version: 0.1.11
    sha: af547b166dd1ea4b472165569fc456cfb6818116f854690b0ff205e636523dab
  - name: termcolor
    version: 1.1.3
    sha: bab24d30b911b2376f3a13cc2cd443142f0c81dda04c118693e35b3835757755
  - name: thiserror
    version: 1.0.35
    sha: c53f98874615aea268107765aa1ed8f6116782501d18e53d08b471733bea6c85
  - name: thiserror-impl
    version: 1.0.35
    sha: f8b463991b4eab2d801e724172285ec4195c650e8ec79b149e6c2a8e6dd3f783
  - name: toml
    version: 0.5.9
    sha: 8d82e1a7758622a465f8cee077614c73484dac5b836c02ff6a40d5d1010324d7
  - name: ucd-trie
    version: 0.1.5
    sha: 9e79c4d996edb816c91e4308506774452e55e95c3c9de07b6729e17e15a5ef81
  - name: unicode-ident
    version: 1.0.4
    sha: dcc811dc4066ac62f84f11307873c4850cb653bfa9b1719cee2bd2204a4bc5dd
  - name: version-compare
    version: 0.1.0
    sha: fe88247b92c1df6b6de80ddc290f3976dbdf2f5f5d3fd049a9fb598c6dd5ca73
  - name: version_check
    version: 0.9.4
    sha: 49874b5167b65d7193b8aba1567f5c7d93d001cafc34600cee003eda787e483f
  - name: winapi
    version: 0.3.9
    sha: 5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419
  - name: winapi-i686-pc-windows-gnu
    version: 0.4.0
    sha: ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6
  - name: winapi-util
    version: 0.1.5
    sha: 70ec6ce85bb158151cae5e5c87f95a8e97d2c0c4b001223f33a334e3ce5de178
  - name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/zenity.bst
depends:
- components/adwaita-icon-theme.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
