kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-tour/44/gnome-tour-44.0.tar.xz
  ref: 06de7677dd1c590d0ea33a032c9ccf4c37c62bc56215b823c879e42ee630c2b6
- kind: cargo

  ref:
  - name: aho-corasick
    version: 0.7.20
    sha: cc936419f96fa211c1b9166887b38e5e40b19958e5b895be7c1f93adec7071ac
  - name: anyhow
    version: 1.0.70
    sha: 7de8ce5e0f9f8d88245311066a578d72b7af3e7088f32783804676302df237e4
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
    version: 0.17.0
    sha: a8af54f5d48af1226928adc1f57edd22f5df1349e7da1fc96ae15cf43db0e871
  - name: cairo-sys-rs
    version: 0.17.0
    sha: f55382a01d30e5e53f185eee269124f5e21ab526595b872751278dfbb463594e
  - name: cc
    version: 1.0.79
    sha: 50d30906286121d95be3d479533b458f87493b30a4b5f79a607db8f5d11aa91f
  - name: cfg-expr
    version: 0.11.0
    sha: b0357a6402b295ca3a86bc148e84df46c02e41f41fef186bda662557ef6328aa
  - name: cfg-if
    version: 1.0.0
    sha: baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd
  - name: env_logger
    version: 0.7.1
    sha: 44533bbbb3bb3c1fa17d9f2e4e38bbbaf8396ba82193c4cb1b6445d711445d36
  - name: field-offset
    version: 0.3.5
    sha: a3cf3a800ff6e860c863ca6d4b16fd999db8b752819c1606884047b73e468535
  - name: futures-channel
    version: 0.3.27
    sha: 164713a5a0dcc3e7b4b1ed7d3b433cabc18025386f9339346e8daf15963cf7ac
  - name: futures-core
    version: 0.3.27
    sha: 86d7a0c1aa76363dac491de0ee99faf6941128376f1cf96f07db7603b7de69dd
  - name: futures-executor
    version: 0.3.27
    sha: 1997dd9df74cdac935c76252744c1ed5794fac083242ea4fe77ef3ed60ba0f83
  - name: futures-io
    version: 0.3.27
    sha: 89d422fa3cbe3b40dca574ab087abb5bc98258ea57eea3fd6f1fa7162c778b91
  - name: futures-macro
    version: 0.3.27
    sha: 3eb14ed937631bd8b8b8977f2c198443447a8355b6e3ca599f38c975e5a963b6
  - name: futures-task
    version: 0.3.27
    sha: fd65540d33b37b16542a0438c12e6aeead10d4ac5d05bd3f805b8f35ab592879
  - name: futures-util
    version: 0.3.27
    sha: 3ef6b17e481503ec85211fed8f39d1970f128935ca1f814cd32ac4a6842e84ab
  - name: gdk-pixbuf
    version: 0.17.0
    sha: b023fbe0c6b407bd3d9805d107d9800da3829dc5a676653210f1d5f16d7f59bf
  - name: gdk-pixbuf-sys
    version: 0.17.0
    sha: 7b41bd2b44ed49d99277d3925652a163038bd5ed943ec9809338ffb2f4391e3b
  - name: gdk4
    version: 0.6.3
    sha: c3abf96408a26e3eddf881a7f893a1e111767137136e347745e8ea6ed12731ff
  - name: gdk4-sys
    version: 0.6.3
    sha: 1bc92aa1608c089c49393d014c38ac0390d01e4841e1fedaa75dbcef77aaed64
  - name: gettext-rs
    version: 0.7.0
    sha: e49ea8a8fad198aaa1f9655a2524b64b70eb06b2f3ff37da407566c93054f364
  - name: gettext-sys
    version: 0.21.3
    sha: c63ce2e00f56a206778276704bbe38564c8695249fdc8f354b4ef71c57c3839d
  - name: gio
    version: 0.17.4
    sha: 2261a3b4e922ec676d1c27ac466218c38cf5dcb49a759129e54bb5046e442125
  - name: gio-sys
    version: 0.17.4
    sha: 6b1d43b0d7968b48455244ecafe41192871257f5740aa6b095eb19db78e362a5
  - name: glib
    version: 0.17.5
    sha: cfb53061756195d76969292c2d2e329e01259276524a9bae6c9b73af62854773
  - name: glib-macros
    version: 0.17.5
    sha: 454924cafe58d9174dc32972261fe271d6cd3c10f5e9ff505522a28dcf601a40
  - name: glib-sys
    version: 0.17.4
    sha: 49f00ad0a1bf548e61adfff15d83430941d9e1bb620e334f779edd1c745680a5
  - name: gobject-sys
    version: 0.17.4
    sha: 15e75b0000a64632b2d8ca3cf856af9308e3a970844f6e9659bd197f026793d0
  - name: graphene-rs
    version: 0.17.1
    sha: 21cf11565bb0e4dfc2f99d4775b6c329f0d40a2cff9c0066214d31a0e1b46256
  - name: graphene-sys
    version: 0.17.0
    sha: cf80a4849a8d9565410a8fec6fc3678e9c617f4ac7be182ca55ab75016e07af9
  - name: gsk4
    version: 0.6.3
    sha: 6f01ef44fa7cac15e2da9978529383e6bee03e570ba5bf7036b4c10a15cc3a3c
  - name: gsk4-sys
    version: 0.6.3
    sha: c07a84fb4dcf1323d29435aa85e2f5f58bef564342bef06775ec7bd0da1f01b0
  - name: gtk4
    version: 0.6.4
    sha: 1e30e124b5a605f6f5513db13958bfcd51d746607b20bc7bb718b33e303274ed
  - name: gtk4-macros
    version: 0.6.3
    sha: 30e21acdeb9a02b8cba83e65afbb8aa45f977785e50f1113407024c6b6256988
  - name: gtk4-sys
    version: 0.6.3
    sha: 5f8283f707b07e019e76c7f2934bdd4180c277e08aa93f4c0d8dd07b7a34e22f
  - name: hashbrown
    version: 0.12.3
    sha: 8a9ee70c43aaf417c914396645a0fa852624801b24ebb7ae78fe8272889ac888
  - name: heck
    version: 0.4.1
    sha: 95505c38b4572b2d910cecb0281560f54b440a19336cbbcb27bf6ce6adc6f5a8
  - name: hermit-abi
    version: 0.1.19
    sha: 62b467343b94ba476dcb2500d242dadbb39557df889310ac77c5d99100aaac33
  - name: humantime
    version: 1.3.0
    sha: df004cfca50ef23c36850aaaa59ad52cc70d0e90243c3c7737a4dd32dc7a3c4f
  - name: indexmap
    version: 1.9.2
    sha: 1885e79c1fc4b10f0e172c475f458b7f7b93061064d98c3293e98c5ba0c8b399
  - name: lazy_static
    version: 1.4.0
    sha: e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646
  - name: libadwaita
    version: 0.3.1
    sha: b1c4efd2020a4fcedbad2c4a97de97bf6045e5dc49d61d5a5d0cfd753db60700
  - name: libadwaita-sys
    version: 0.3.0
    sha: 0727b85b4fe2b1bed5ac90df6343de15cbf8118bfb96d7c3cc1512681a4b34ac
  - name: libc
    version: 0.2.140
    sha: 99227334921fae1a979cf0bfdfcc6b3e5ce376ef57e16fb6fb3ea2ed6095f80c
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
    version: 0.8.0
    sha: d61c719bcfbcf5d62b3a09efa6088de8c54bc0bfcd3ea7ae39fcc186108b8de1
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
    version: 1.17.1
    sha: b7e5500299e16ebb147ae15a00a942af264cf3688f47923b8fc2cd5858f23ad3
  - name: pango
    version: 0.17.4
    sha: 52c280b82a881e4208afb3359a8e7fde27a1b272280981f1f34610bed5770d37
  - name: pango-sys
    version: 0.17.0
    sha: 4293d0f0b5525eb5c24734d30b0ed02cd02aa734f216883f376b54de49625de8
  - name: pin-project-lite
    version: 0.2.9
    sha: e0a7ae3ac2f1173085d398531c705756c94a4c56843785df85a60c1a0afac116
  - name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - name: pkg-config
    version: 0.3.26
    sha: 6ac9a59f73473f1b8d852421e59e64809f025994837ef743615c6d0c5b305160
  - name: pretty_env_logger
    version: 0.4.0
    sha: 926d36b9553851b8b0005f1275891b392ee4d2d833852c417ed025477350fb9d
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
    version: 1.0.52
    sha: 1d0e1ae9e836cc3beddd63db0df682593d7e2d3d891ae8c9083d2113e1744224
  - name: quick-error
    version: 1.2.3
    sha: a1d01941d82fa2ab50be1e79e6714289dd7cde78eba4c074bc5a4374f650dfe0
  - name: quote
    version: 1.0.26
    sha: 4424af4bf778aae2051a77b60283332f386554255d722233d09fbfc7e30da2fc
  - name: regex
    version: 1.7.1
    sha: 48aaa5748ba571fb95cd2c85c09f629215d3a6ece942baa100950af03a34f733
  - name: regex-syntax
    version: 0.6.28
    sha: 456c603be3e8d448b072f410900c09faf164fbce2d480456f50eea6e25f9c848
  - name: rustc_version
    version: 0.4.0
    sha: bfa0f585226d2e68097d4f95d113b15b83a82e819ab25717ec0590d9584ef366
  - name: semver
    version: 1.0.17
    sha: bebd363326d05ec3e2f532ab7660680f3b02130d780c299bca73469d521bc0ed
  - name: serde
    version: 1.0.157
    sha: 707de5fcf5df2b5788fca98dd7eab490bc2fd9b7ef1404defc462833b83f25ca
  - name: slab
    version: 0.4.8
    sha: 6528351c9bc8ab22353f9d776db39a20288e8d6c37ef8cfe3317cf875eecfc2d
  - name: smallvec
    version: 1.10.0
    sha: a507befe795404456341dfab10cef66ead4c041f62b8b11bbb92bffe5d0953e0
  - name: syn
    version: 1.0.109
    sha: 72b64191b275b66ffe2469e8af2c1cfe3bafa67b529ead792a6d0160888b4237
  - name: syn
    version: 2.0.2
    sha: 59d3276aee1fa0c33612917969b5172b5be2db051232a6e4826f1a1a9191b045
  - name: system-deps
    version: 6.0.3
    sha: 2955b1fe31e1fa2fbd1976b71cc69a606d7d4da16f6de3333d0c92d51419aeff
  - name: temp-dir
    version: 0.1.11
    sha: af547b166dd1ea4b472165569fc456cfb6818116f854690b0ff205e636523dab
  - name: termcolor
    version: 1.2.0
    sha: be55cf8942feac5c765c2c993422806843c9a9a45d4d5c407ad6dd2ea95eb9b6
  - name: thiserror
    version: 1.0.40
    sha: 978c9a314bd8dc99be594bc3c175faaa9794be04a5a5e153caba6915336cebac
  - name: thiserror-impl
    version: 1.0.40
    sha: f9456a42c5b0d803c8cd86e73dd7cc9edd429499f37a3550d286d5e86720569f
  - name: toml
    version: 0.5.11
    sha: f4f7f0dd8d50a853a531c426359045b1998f04219d88799810762cd4ad314234
  - name: toml_datetime
    version: 0.6.1
    sha: 3ab8ed2edee10b50132aed5f331333428b011c99402b5a534154ed15746f9622
  - name: toml_edit
    version: 0.19.7
    sha: dc18466501acd8ac6a3f615dd29a3438f8ca6bb3b19537138b3106e575621274
  - name: unicode-ident
    version: 1.0.8
    sha: e5464a87b239f13a63a501f2701565754bae92d243d4bb7eb12f6d57d2269bf4
  - name: version-compare
    version: 0.1.1
    sha: 579a42fc0b8e0c63b76519a339be31bed574929511fa53c1a3acae26eb258f29
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
  - name: winnow
    version: 0.3.6
    sha: 23d020b441f92996c80d94ae9166e8501e59c7bb56121189dc9eab3bd8216966
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
