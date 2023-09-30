kind: autotools

sources:
- kind: tar
  url: gnome_downloads:librsvg/2.57/librsvg-2.57.0.tar.xz
  ref: 335fe2e0c2cbf1b7bf0668651224a23e135451f0b1793cd813649be2bffa74e8
- kind: cargo

  ref:
  - name: adler
    version: 1.0.2
    sha: f26201604c87b1e01bd3d98f8d5d9a8fcbb815e8cedb41ffccbeb4bf593a35fe
  - name: aho-corasick
    version: 1.0.5
    sha: 0c378d78423fdad8089616f827526ee33c19f2fddbd5de1629152c9593ba4783
  - name: android-tzdata
    version: 0.1.1
    sha: e999941b234f3131b00bc13c22d06e8c5ff726d1b6318ac7eb276997bbb4fef0
  - name: android_system_properties
    version: 0.1.5
    sha: 819e7219dbd41043ac279b19830f2efc897156490d7fd6ea916720117ee66311
  - name: anes
    version: 0.1.6
    sha: 4b46cbb362ab8752921c97e041f5e366ee6297bd428a31275b9fcf1e380f7299
  - name: anstream
    version: 0.5.0
    sha: b1f58811cfac344940f1a400b6e6231ce35171f614f26439e80f8c1465c5cc0c
  - name: anstyle
    version: 1.0.3
    sha: b84bf0a05bbb2a83e5eb6fa36bb6e87baa08193c35ff52bbf6b38d8af2890e46
  - name: anstyle-parse
    version: 0.2.1
    sha: 938874ff5980b03a87c5524b3ae5b59cf99b1d6bc836848df7bc5ada9643c333
  - name: anstyle-query
    version: 1.0.0
    sha: 5ca11d4be1bab0c8bc8734a9aa7bf4ee8316d462a08c6ac5052f888fef5b494b
  - name: anstyle-wincon
    version: 2.1.0
    sha: 58f54d10c6dfa51283a066ceab3ec1ab78d13fae00aa49243a45e4571fb79dfd
  - name: anyhow
    version: 1.0.75
    sha: a4668cab20f66d8d020e1fbc0ebe47217433c1b6c8f2040faf858554e394ace6
  - name: approx
    version: 0.5.1
    sha: cab112f0a86d568ea0e627cc1d6be74a1e9cd55214684db5561995f6dad897c6
  - name: assert_cmd
    version: 2.0.12
    sha: 88903cb14723e4d4003335bb7f8a14f27691649105346a0f0957466c096adfe6
  - name: autocfg
    version: 1.1.0
    sha: d468802bab17cbc0cc575e9b053f41e72aa36bfa6b7f55e3529ffa43161b97fa
  - name: bit-set
    version: 0.5.3
    sha: 0700ddab506f33b20a03b13996eccd309a48e5ff77d0d95926aa0210fb4e95f1
  - name: bit-vec
    version: 0.6.3
    sha: 349f9b6a179ed607305526ca489b34ad0a41aed5f7980fa90eb03160b69598fb
  - name: bitflags
    version: 1.3.2
    sha: bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a
  - name: bitflags
    version: 2.4.0
    sha: b4682ae6287fcf752ecaabbfcc7b6f9b72aa33933dc23a554d853aea8eea8635
  - name: block
    version: 0.1.6
    sha: 0d8c1fef690941d3e7788d328517591fecc684c084084702d6ff1641e993699a
  - name: bstr
    version: 1.6.2
    sha: 4c2f7349907b712260e64b0afe2f84692af14a454be26187d9df565c7f69266a
  - name: bumpalo
    version: 3.13.0
    sha: a3e2c3daef883ecc1b5d58c15adae93470a91d425f3532ba1695849656af3fc1
  - name: bytemuck
    version: 1.14.0
    sha: 374d28ec25809ee0e23827c2ab573d729e293f281dfe393500e7ad618baa61c6
  - name: byteorder
    version: 1.4.3
    sha: 14c189c53d098945499cdfa7ecc63567cf3886b3332b312a5b4585d8d3a6a610
  - name: cairo-rs
    version: 0.18.0
    sha: d859b656775a6b1dd078d3e5924884e6ea88aa649a7fdde03d5b2ec56ffcc10b
  - name: cairo-sys-rs
    version: 0.18.0
    sha: bd4d115132e01c0165e3bf5f56aedee8980b0b96ede4eb000b693c05a8adb8ff
  - name: cast
    version: 0.3.0
    sha: 37b2a672a2cb129a2e41c10b1224bb368f9f37a2b16b612598138befd7b37eb5
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
    version: 0.4.30
    sha: defd4e7873dbddba6c7c91e199c7fcb946abc4a6a4ac3195400bcfb01b5de877
  - name: ciborium
    version: 0.2.1
    sha: effd91f6c78e5a4ace8a5d3c0b6bfaec9e2baaef55f3efc00e45fb2e477ee926
  - name: ciborium-io
    version: 0.2.1
    sha: cdf919175532b369853f5d5e20b26b43112613fd6fe7aee757e35f7a44642656
  - name: ciborium-ll
    version: 0.2.1
    sha: defaa24ecc093c77630e6c15e17c51f5e187bf35ee514f4e2d67baaa96dae22b
  - name: clap
    version: 4.4.2
    sha: 6a13b88d2c62ff462f88e4a121f17a82c1af05693a2f192b5c38d14de73c19f6
  - name: clap_builder
    version: 4.4.2
    sha: 2bb9faaa7c2ef94b2743a21f5a29e6f0010dff4caa69ac8e9d6cf8b6fa74da08
  - name: clap_complete
    version: 4.4.1
    sha: 4110a1e6af615a9e6d0a36f805d5c99099f8bab9b8042f5bc1fa220a4a89e36f
  - name: clap_derive
    version: 4.4.2
    sha: 0862016ff20d69b84ef8247369fabf5c008a7417002411897d40ee1f4532b873
  - name: clap_lex
    version: 0.5.1
    sha: cd7cc57abe963c6d3b9d8be5b06ba7c8957a930305ca90304f24ef040aa6f961
  - name: colorchoice
    version: 1.0.0
    sha: acbf1af155f9b9ef647e42cdc158db4b64a1b61f743629225fde6f3e0be2a7c7
  - name: const-cstr
    version: 0.3.0
    sha: ed3d0b5ff30645a68f35ece8cea4556ca14ef8a1651455f789a099a0513532a6
  - name: core-foundation-sys
    version: 0.8.4
    sha: e496a50fda8aacccc86d7529e2c1e0892dbd0f898a6b5645b5561b89c3210efa
  - name: crc32fast
    version: 1.3.2
    sha: b540bd8bc810d3885c6ea91e2018302f68baba2129ab3e88f32389ee9370880d
  - name: criterion
    version: 0.5.1
    sha: f2b12d017a929603d80db1831cd3a24082f8137ce19c69e6447f54f5fc8d692f
  - name: criterion-plot
    version: 0.5.0
    sha: 6b50826342786a51a89e2da3a28f1c32b06e387201bc2d19791f622c673706b1
  - name: crossbeam-channel
    version: 0.5.8
    sha: a33c2bf77f2df06183c3aa30d1e96c0695a313d4f9c453cc3762a6db39f99200
  - name: crossbeam-deque
    version: 0.8.3
    sha: ce6fd6f855243022dcecf8702fef0c297d4338e226845fe067f6341ad9fa0cef
  - name: crossbeam-epoch
    version: 0.9.15
    sha: ae211234986c545741a7dc064309f67ee1e5ad243d0e48335adc0484d960bcc7
  - name: crossbeam-utils
    version: 0.8.16
    sha: 5a22b2d63d4d1dc0b7f1b6b2747dd0088008a9be28b6ddf0b1e7d335e3037294
  - name: cssparser
    version: 0.31.2
    sha: 5b3df4f93e5fbbe73ec01ec8d3f68bba73107993a5b1e7519273c32db9b0d5be
  - name: cssparser-macros
    version: 0.6.1
    sha: 13b588ba4ac1a99f7f2964d24b3d896ddc6bf847ee3855dbd4366f058cfcd331
  - name: cstr
    version: 0.2.11
    sha: 8aa998c33a6d3271e3678950a22134cd7dd27cef86dee1b611b5b14207d1d90b
  - name: data-url
    version: 0.3.0
    sha: 41b319d1b62ffbd002e057f36bebd1f42b9f97927c9577461d855f3513c4289f
  - name: deranged
    version: 0.3.8
    sha: f2696e8a945f658fd14dc3b87242e6b80cd0f36ff04ea560fa39082368847946
  - name: derive_more
    version: 0.99.17
    sha: 4fb810d30a7c1953f91334de7244731fc3f3c10d7fe163338a35b9f640960321
  - name: difflib
    version: 0.4.0
    sha: 6184e33543162437515c2e2b48714794e37845ec9851711914eec9d308f6ebe8
  - name: dlib
    version: 0.5.2
    sha: 330c60081dcc4c72131f8eb70510f1ac07223e5d4163db481a04a0befcffa412
  - name: doc-comment
    version: 0.3.3
    sha: fea41bba32d969b513997752735605054bc0dfa92b4c56bf1189f2e174be7a10
  - name: dtoa
    version: 1.0.9
    sha: dcbb2bf8e87535c23f7a8a321e364ce21462d0ff10cb6407820e8e96dfff6653
  - name: dtoa-short
    version: 0.3.4
    sha: dbaceec3c6e4211c79e7b1800fb9680527106beb2f9c51904a3210c03a448c74
  - name: either
    version: 1.9.0
    sha: a26ae43d7bcc3b814de94796a5e736d4029efb0ee900c12e2d54c993ad1a1e07
  - name: encoding_rs
    version: 0.8.33
    sha: 7268b386296a025e474d5140678f75d6de9493ae55a5d709eeb9dd08149945e1
  - name: equivalent
    version: 1.0.1
    sha: 5443807d6dff69373d433ab9ef5378ad8df50ca6298caf15de6e52e24aaf54d5
  - name: errno
    version: 0.3.3
    sha: 136526188508e25c6fef639d7927dfb3e0e3084488bf202267829cf7fc23dbdd
  - name: errno-dragonfly
    version: 0.1.2
    sha: aa68f1b12764fab894d2755d2518754e71b4fd80ecfb822714a1206c2aab39bf
  - name: fastrand
    version: 2.0.0
    sha: 6999dc1837253364c2ebb0704ba97994bd874e8f195d665c50b7548f6ea92764
  - name: fdeflate
    version: 0.3.0
    sha: d329bdeac514ee06249dabc27877490f17f5d371ec693360768b838e19f3ae10
  - name: flate2
    version: 1.0.27
    sha: c6c98ee8095e9d1dcbf2fcc6d95acccb90d1c81db1e44725c6a984b1dbdfb010
  - name: float-cmp
    version: 0.9.0
    sha: 98de4bbd547a563b716d8dfa9aad1cb19bfab00f4fa09a6a4ed21dbcf44ce9c4
  - name: fnv
    version: 1.0.7
    sha: 3f9eec918d3f24069decb9af1554cad7c880e2da24a9afd88aca000531ab82c1
  - name: form_urlencoded
    version: 1.2.0
    sha: a62bc1cf6f830c2ec14a513a9fb124d0a213a629668a4186f329db21fe045652
  - name: futf
    version: 0.1.5
    sha: df420e2e84819663797d1ec6544b13c5be84629e7bb00dc960d6917db2987843
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
  - name: futures-macro
    version: 0.3.28
    sha: 89ca545a94061b6365f2c7355b4b32bd20df3ff95f02da9329b34ccc3bd6ee72
  - name: futures-task
    version: 0.3.28
    sha: 76d3d132be6c0e6aa1534069c705a74a5997a356c0dc2f86a47765e5617c5b65
  - name: futures-util
    version: 0.3.28
    sha: 26b01e40b772d54cf6c6d721c1d1abd0647a0106a12ecaa1c186273392a69533
  - name: fxhash
    version: 0.2.1
    sha: c31b6d751ae2c7f11320402d34e41349dd1016f8d5d45e48c4312bc8625af50c
  - name: gdk-pixbuf
    version: 0.18.0
    sha: bbc9c2ed73a81d556b65d08879ba4ee58808a6b1927ce915262185d6d547c6f3
  - name: gdk-pixbuf-sys
    version: 0.18.0
    sha: 3f9839ea644ed9c97a34d129ad56d38a25e6756f99f3a88e15cd39c20629caf7
  - name: getrandom
    version: 0.2.10
    sha: be4136b2a15dd319360be1c07d9933517ccf0be8f16bf62a3bee4f0d618df427
  - name: gio
    version: 0.18.1
    sha: 7884cba6b1c5db1607d970cadf44b14a43913d42bc68766eea6a5e2fe0891524
  - name: gio-sys
    version: 0.18.1
    sha: 37566df850baf5e4cb0dfb78af2e4b9898d817ed9263d1090a2df958c64737d2
  - name: glib
    version: 0.18.1
    sha: 331156127e8166dd815cf8d2db3a5beb492610c716c03ee6db4f2d07092af0a7
  - name: glib-macros
    version: 0.18.0
    sha: 179643c50bf28d20d2f6eacd2531a88f2f5d9747dd0b86b8af1e8bb5dd0de3c0
  - name: glib-sys
    version: 0.18.1
    sha: 063ce2eb6a8d0ea93d2bf8ba1957e78dbab6be1c2220dd3daca57d5a9d869898
  - name: gobject-sys
    version: 0.18.0
    sha: 0850127b514d1c4a4654ead6dedadb18198999985908e6ffe4436f53c785ce44
  - name: half
    version: 1.8.2
    sha: eabb4a44450da02c90444cf74558da904edde8fb4e9035a9a6a4e15445af0bd7
  - name: hashbrown
    version: 0.14.0
    sha: 2c6201b9ff9fd90a5a3bac2e56a830d0caa509576f0e503818ee82c181b3437a
  - name: heck
    version: 0.4.1
    sha: 95505c38b4572b2d910cecb0281560f54b440a19336cbbcb27bf6ce6adc6f5a8
  - name: hermit-abi
    version: 0.3.2
    sha: 443144c8cdadd93ebf52ddb4056d257f5b52c04d3c804e657d19eb73fc33668b
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
  - name: is-terminal
    version: 0.4.9
    sha: cb0889898416213fab133e1d33a0e5858a48177452750691bde3666d0fdbaf8b
  - name: itertools
    version: 0.10.5
    sha: b0fd2260e829bddf4cb6ea802289de2f86d6a7a690192fbe91b3f46e0f2c8473
  - name: itertools
    version: 0.11.0
    sha: b1c173a5686ce8bfa551b3563d0c2170bf24ca44da99c7ca4bfdab5418c3fe57
  - name: itoa
    version: 1.0.9
    sha: af150ab688ff2122fcef229be89cb50dd66af9e01a4ff320cc137eecc9bacc38
  - name: js-sys
    version: 0.3.64
    sha: c5f195fe497f702db0f318b07fdd68edb16955aed830df8363d837542f8f935a
  - name: language-tags
    version: 0.3.2
    sha: d4345964bb142484797b161f473a503a434de77149dd8c7427788c6e13379388
  - name: lazy_static
    version: 1.4.0
    sha: e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646
  - name: libc
    version: 0.2.147
    sha: b4668fb0ea861c1df094127ac5f1da3409a82116a4ba74fca2e58ef927159bb3
  - name: libloading
    version: 0.8.0
    sha: d580318f95776505201b28cf98eb1fa5e4be3b689633ba6a3e6cd880ff22d8cb
  - name: libm
    version: 0.2.7
    sha: f7012b1bbb0719e1097c47611d3898568c546d597c2e74d66f6087edd5233ff4
  - name: linked-hash-map
    version: 0.5.6
    sha: 0717cef1bc8b636c6e1c1bbdefc09e6322da8a9321966e8928ef80d20f7f770f
  - name: linux-raw-sys
    version: 0.4.7
    sha: 1a9bad9f94746442c783ca431b22403b519cd7fbeed0533fdd6328b2f2212128
  - name: locale_config
    version: 0.3.0
    sha: 08d2c35b16f4483f6c26f0e4e9550717a2f6575bcd6f12a53ff0c490a94a6934
  - name: lock_api
    version: 0.4.10
    sha: c1cc9717a20b1bb222f333e6a92fd32f7d8a18ddc5a3191a11af45dcbf4dcd16
  - name: log
    version: 0.4.20
    sha: b5e6163cb8c49088c2c36f57875e58ccd8c87c7427f7fbd50ea6710b2f3f2e8f
  - name: lopdf
    version: 0.31.0
    sha: 07c8e1b6184b1b32ea5f72f572ebdc40e5da1d2921fa469947ff7c480ad1f85a
  - name: mac
    version: 0.1.1
    sha: c41e0c4fef86961ac6d6f8a82609f55f31b05e4fce149ac5710e439df7619ba4
  - name: malloc_buf
    version: 0.0.6
    sha: 62bb907fe88d54d8d9ce32a3cceab4218ed2f6b7d35617cafe9adf84e43919cb
  - name: markup5ever
    version: 0.11.0
    sha: 7a2629bb1404f3d34c2e921f21fd34ba00b206124c81f65c50b43b6aaefeb016
  - name: matches
    version: 0.1.10
    sha: 2532096657941c2fea9c289d370a250971c689d4f143798ff67113ec042024a5
  - name: matrixmultiply
    version: 0.3.7
    sha: 090126dc04f95dc0d1c1c91f61bdd474b3930ca064c1edc8a849da2c6cbe1e77
  - name: md5
    version: 0.7.0
    sha: 490cc448043f947bae3cbee9c203358d62dbee0db12107a74be5c30ccfd09771
  - name: memchr
    version: 2.6.3
    sha: 8f232d6ef707e1956a43342693d2a31e72989554d58299d7a88738cc95b0d35c
  - name: memoffset
    version: 0.9.0
    sha: 5a634b1c61a95585bd15607c6ab0c4e5b226e695ff2800ba0cdccddf208c406c
  - name: minimal-lexical
    version: 0.2.1
    sha: 68354c5c6bd36d73ff3feceb05efa59b6acb7626617f4962be322a825e61f79a
  - name: miniz_oxide
    version: 0.7.1
    sha: e7810e0be55b428ada41041c41f32c9f1a42817901b4ccf45fa3d4b6561e74c7
  - name: nalgebra
    version: 0.32.3
    sha: 307ed9b18cc2423f29e83f84fd23a8e73628727990181f18641a8b5dc2ab1caa
  - name: nalgebra-macros
    version: 0.2.1
    sha: 91761aed67d03ad966ef783ae962ef9bbaca728d2dd7ceb7939ec110fffad998
  - name: new_debug_unreachable
    version: 1.0.4
    sha: e4a24736216ec316047a1fc4252e27dabb04218aa4a3f37c6e7ddbf1f9782b54
  - name: nom
    version: 7.1.3
    sha: d273983c5a657a70a3e8f2a01329822f3b8c8172b73826411a55751e404a0a4a
  - name: normalize-line-endings
    version: 0.3.0
    sha: 61807f77802ff30975e01f4f071c8ba10c022052f98b3294119f3e615d13e5be
  - name: num-complex
    version: 0.4.4
    sha: 1ba157ca0885411de85d6ca030ba7e2a83a28636056c7c699b07c8b6f7383214
  - name: num-integer
    version: 0.1.45
    sha: 225d3389fb3509a24c93f5c29eb6bde2586b98d9f016636dff58d7c6f7569cd9
  - name: num-rational
    version: 0.4.1
    sha: 0638a1c9d0a3c0914158145bc76cff373a75a627e6ecbfb71cbe6f453a5a19b0
  - name: num-traits
    version: 0.2.16
    sha: f30b0abd723be7e2ffca1272140fac1a2f084c77ec3e123c192b66af1ee9e6c2
  - name: num_cpus
    version: 1.16.0
    sha: 4161fcb6d602d4d2081af7c3a45852d875a03dd337a6bfdd6e06407b61342a43
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
  - name: oorandom
    version: 11.1.3
    sha: 0ab1bc2a289d34bd04a330323ac98a1b4bc82c9d9fcb1e66b63caa84da26b575
  - name: pango
    version: 0.18.0
    sha: 06a9e54b831d033206160096b825f2070cf5fda7e35167b1c01e9e774f9202d1
  - name: pango-sys
    version: 0.18.0
    sha: 436737e391a843e5933d6d9aa102cb126d501e815b83601365a948a518555dc5
  - name: pangocairo
    version: 0.18.0
    sha: 57036589a9cfcacf83f9e606d15813fc6bf03f0e9e69aa2b5e3bb85af86b38a5
  - name: pangocairo-sys
    version: 0.18.0
    sha: fc3c8ff676a37e7a72ec1d5fc029f91c407278083d2752784ff9f5188c108833
  - name: parking_lot
    version: 0.12.1
    sha: 3742b2c103b9f06bc9fff0a37ff4912935851bee6d36f3c02bcc755bcfec228f
  - name: parking_lot_core
    version: 0.9.8
    sha: 93f00c865fe7cabf650081affecd3871070f26767e7b2070a3ffae14c654b447
  - name: paste
    version: 1.0.14
    sha: de3145af08024dea9fa9914f381a17b8fc6034dfb00f3a84013f7ff43f29ed4c
  - name: percent-encoding
    version: 2.3.0
    sha: 9b2a4787296e9989611394c33f193f676704af1686e70b8f8033ab5ba9a35a94
  - name: phf
    version: 0.10.1
    sha: fabbf1ead8a5bcbc20f5f8b939ee3f5b0f6f281b6ad3468b84656b658b455259
  - name: phf
    version: 0.11.2
    sha: ade2d8b8f33c7333b51bcf0428d37e217e9f32192ae4772156f65063b8ce03dc
  - name: phf_codegen
    version: 0.10.0
    sha: 4fb1c3a8bc4dd4e5cfce29b44ffc14bedd2ee294559a294e2a4d4c9e9a6a13cd
  - name: phf_generator
    version: 0.10.0
    sha: 5d5285893bb5eb82e6aaf5d59ee909a06a16737a8970984dd7746ba9283498d6
  - name: phf_generator
    version: 0.11.2
    sha: 48e4cc64c2ad9ebe670cb8fd69dd50ae301650392e81c05f9bfcb2d5bdbc24b0
  - name: phf_macros
    version: 0.11.2
    sha: 3444646e286606587e49f3bcf1679b8cef1dc2c5ecc29ddacaffc305180d464b
  - name: phf_shared
    version: 0.10.0
    sha: b6796ad771acdc0123d2a88dc428b5e38ef24456743ddb1744ed628f9815c096
  - name: phf_shared
    version: 0.11.2
    sha: 90fcb95eef784c2ac79119d1dd819e162b5da872ce6f3c3abe1e8ca1c082f72b
  - name: pin-project-lite
    version: 0.2.13
    sha: 8afb450f006bf6385ca15ef45d71d2288452bc3683ce2e2cacc0d18e4be60b58
  - name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - name: pkg-config
    version: 0.3.27
    sha: 26072860ba924cbfa98ea39c8c19b4dd6a4a25423dbdf219c1eca91aa0cf6964
  - name: plotters
    version: 0.3.5
    sha: d2c224ba00d7cadd4d5c660deaf2098e5e80e07846537c51f9cfa4be50c1fd45
  - name: plotters-backend
    version: 0.3.5
    sha: 9e76628b4d3a7581389a35d5b6e2139607ad7c75b17aed325f210aa91f4a9609
  - name: plotters-svg
    version: 0.3.5
    sha: 38f6d39893cca0701371e3c27294f09797214b86f1fb951b89ade8ec04e2abab
  - name: png
    version: 0.17.10
    sha: dd75bf2d8dd3702b9707cdbc56a5b9ef42cec752eb8b3bafc01234558442aa64
  - name: ppv-lite86
    version: 0.2.17
    sha: 5b40af805b3121feab8a3c29f04d8ad262fa8e0561883e7653e024ae4479e6de
  - name: precomputed-hash
    version: 0.1.1
    sha: 925383efa346730478fb4838dbe9137d2a47675ad789c546d150a6e1dd4ab31c
  - name: predicates
    version: 3.0.3
    sha: 09963355b9f467184c04017ced4a2ba2d75cbcb4e7462690d388233253d4b1a9
  - name: predicates-core
    version: 1.0.6
    sha: b794032607612e7abeb4db69adb4e33590fa6cf1149e95fd7cb00e634b92f174
  - name: predicates-tree
    version: 1.0.9
    sha: 368ba315fb8c5052ab692e68a0eefec6ec57b23a36959c14496f0b0df2c0cecf
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
    version: 1.0.66
    sha: 18fb31db3f9bddb2ea821cde30a9f70117e3f119938b5ee630b7403aa6e2ead9
  - name: proptest
    version: 1.2.0
    sha: 4e35c06b98bf36aba164cc17cb25f7e232f5c4aeea73baa14b8a9f0d92dbfa65
  - name: quick-error
    version: 1.2.3
    sha: a1d01941d82fa2ab50be1e79e6714289dd7cde78eba4c074bc5a4374f650dfe0
  - name: quick-error
    version: 2.0.1
    sha: a993555f31e5a609f617c12db6250dedcac1b0a85076912c436e6fc9b2c8e6a3
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
  - name: rand_xorshift
    version: 0.3.0
    sha: d25bf25ec5ae4a3f1b92f929810509a2f53d7dca2f50b794ff57e3face536c8f
  - name: rawpointer
    version: 0.2.1
    sha: 60a357793950651c4ed0f3f52338f53b2f809f32d83a07f72909fa13e4c6c1e3
  - name: rayon
    version: 1.7.0
    sha: 1d2df5196e37bcc87abebc0053e20787d73847bb33134a69841207dd0a47f03b
  - name: rayon-core
    version: 1.11.0
    sha: 4b8f95bd6966f5c87776639160a66bd8ab9895d9d4ab01ddba9fc60661aebe8d
  - name: rctree
    version: 0.5.0
    sha: 3b42e27ef78c35d3998403c1d26f3efd9e135d3e5121b0a4845cc5cc27547f4f
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
    version: 0.6.29
    sha: f162c6dd7b008981e4d40210aca20b4bd0f9b60ca9271061b07f78537722f2e1
  - name: regex-syntax
    version: 0.7.5
    sha: dbb5fb1acd8a1a18b3dd5be62d25485eb770e05afb408a9627d14d451bae12da
  - name: rgb
    version: 0.8.36
    sha: 20ec2d3e3fc7a92ced357df9cebd5a10b6fb2aa1ee797bf7e9ce2f17dffc8f59
  - name: rustix
    version: 0.38.13
    sha: d7db8590df6dfcd144d22afd1b83b36c21a18d7cbc1dc4bb5295a8712e9eb662
  - name: rusty-fork
    version: 0.3.0
    sha: cb3dcc6e454c328bb824492db107ab7c0ae8fcffe4ad210136ef014458c1bc4f
  - name: ryu
    version: 1.0.15
    sha: 1ad4cc8da4ef723ed60bced201181d83791ad433213d8c24efffda1eec85d741
  - name: safe_arch
    version: 0.7.1
    sha: f398075ce1e6a179b46f51bd88d0598b92b00d3551f1a2d4ac49e771b56ac354
  - name: same-file
    version: 1.0.6
    sha: 93fc1dc3aaa9bfed95e02e6eadabb4baf7e3078b0bd1b4d7b6b0b68378900502
  - name: scopeguard
    version: 1.2.0
    sha: 94143f37725109f92c262ed2cf5e59bce7498c01bcc1502d7b9afe439a4e9f49
  - name: selectors
    version: 0.25.0
    sha: 4eb30575f3638fc8f6815f448d50cb1a2e255b0897985c8c59f4d37b72a07b06
  - name: serde
    version: 1.0.188
    sha: cf9e0fcba69a370eed61bcf2b728575f726b50b55cba78064753d708ddc7549e
  - name: serde_derive
    version: 1.0.188
    sha: 4eca7ac642d82aa35b60049a6eccb4be6be75e599bd2e9adb5f875a737654af2
  - name: serde_json
    version: 1.0.106
    sha: 2cc66a619ed80bf7a0f6b17dd063a84b88f6dea1813737cf469aef1d081142c2
  - name: serde_spanned
    version: 0.6.3
    sha: 96426c9936fd7a0124915f9185ea1d20aa9445cc9821142f0a73bc9207a2e186
  - name: servo_arc
    version: 0.3.0
    sha: d036d71a959e00c77a63538b90a6c2390969f9772b096ea837205c6bd0491a44
  - name: simba
    version: 0.8.1
    sha: 061507c94fc6ab4ba1c9a0305018408e312e17c041eb63bef8aa726fa33aceae
  - name: simd-adler32
    version: 0.3.7
    sha: d66dc143e6b11c1eddc06d5c423cfc97062865baf299914ab64caa38182078fe
  - name: siphasher
    version: 0.3.11
    sha: 38b58827f4464d87d377d175e90bf58eb00fd8716ff0a62f80356b5e61555d0d
  - name: slab
    version: 0.4.9
    sha: 8f92a496fb766b417c996b9c5e57daf2f7ad3b0bebe1ccfca4856390e3d3bb67
  - name: smallvec
    version: 1.11.0
    sha: 62bb4feee49fdd9f707ef802e22365a35de4b7b299de4763d44bfea899442ff9
  - name: stable_deref_trait
    version: 1.2.0
    sha: a8f112729512f8e442d81f95a8a7ddf2b7c6b8a1a6f509a95864142b30cab2d3
  - name: string_cache
    version: 0.8.7
    sha: f91138e76242f575eb1d3b38b4f1362f10d3a43f47d182a5b359af488a02293b
  - name: string_cache_codegen
    version: 0.5.2
    sha: 6bb30289b722be4ff74a408c3cc27edeaad656e06cb1fe8fa9231fa59c728988
  - name: strsim
    version: 0.10.0
    sha: 73473c0e59e6d5812c5dfe2a064a6444949f089e20eec9a2e5506596494e4623
  - name: syn
    version: 1.0.109
    sha: 72b64191b275b66ffe2469e8af2c1cfe3bafa67b529ead792a6d0160888b4237
  - name: syn
    version: 2.0.32
    sha: 239814284fd6f1a4ffe4ca893952cdd93c224b6a1571c9a9eadd670295c0c9e2
  - name: system-deps
    version: 6.1.1
    sha: 30c2de8a4d8f4b823d634affc9cd2a74ec98c53a756f317e529a48046cbf71f3
  - name: target-lexicon
    version: 0.12.11
    sha: 9d0e916b1148c8e263850e1ebcbd046f333e0683c724876bb0da63ea4373dc8a
  - name: tempfile
    version: 3.8.0
    sha: cb94d2f3cc536af71caac6b6fcebf65860b347e7ce0cc9ebe8f70d3e521054ef
  - name: tendril
    version: 0.4.3
    sha: d24a120c5fc464a3458240ee02c299ebcb9d67b5249c8848b09d639dca8d7bb0
  - name: termtree
    version: 0.4.1
    sha: 3369f5ac52d5eb6ab48c6b4ffdc8efbcad6b89c765749064ba298f2c68a16a76
  - name: thiserror
    version: 1.0.48
    sha: 9d6d7a740b8a666a7e828dd00da9c0dc290dff53154ea77ac109281de90589b7
  - name: thiserror-impl
    version: 1.0.48
    sha: 49922ecae66cc8a249b77e68d1d0623c1b2c514f0060c27cdc68bd62a1219d35
  - name: time
    version: 0.3.28
    sha: 17f6bb557fd245c28e6411aa56b6403c689ad95061f50e4be16c274e70a17e48
  - name: time-core
    version: 0.1.1
    sha: 7300fbefb4dadc1af235a9cef3737cea692a9d97e1b9cbcd4ebdae6f8868e6fb
  - name: time-macros
    version: 0.2.14
    sha: 1a942f44339478ef67935ab2bbaec2fb0322496cf3cbe84b261e06ac3814c572
  - name: tinytemplate
    version: 1.2.1
    sha: be4d6b5f19ff7664e8c98d03e2139cb510db9b0a60b55f8e8709b689d939b6bc
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
  - name: typenum
    version: 1.16.0
    sha: 497961ef93d974e23eb6f433eb5fe1b7930b659f06d12dec6fc44a8f554c0bba
  - name: unarray
    version: 0.1.4
    sha: eaea85b334db583fe3274d12b4cd1880032beab409c0d774be044d4480ab9a94
  - name: unicode-bidi
    version: 0.3.13
    sha: 92888ba5573ff080736b3648696b70cafad7d250551175acbaa4e0385b3e1460
  - name: unicode-ident
    version: 1.0.11
    sha: 301abaae475aa91687eb82514b328ab47a211a533026cb25fc3e519b86adfc3c
  - name: unicode-normalization
    version: 0.1.22
    sha: 5c5713f0fc4b5db668a2ac63cdb7bb4469d8c9fed047b1d0292cc7b0ce2ba921
  - name: url
    version: 2.4.1
    sha: 143b538f18257fac9cad154828a57c6bf5157e1aa604d4816b5995bf6de87ae5
  - name: utf-8
    version: 0.7.6
    sha: 09cc8ee72d2a9becf2f2febe0205bbed8fc6615b7cb429ad062dc7b7ddd036a9
  - name: utf8parse
    version: 0.2.1
    sha: 711b9620af191e0cdc7468a8d14e709c3dcdb115b36f838e601583af800a370a
  - name: version-compare
    version: 0.1.1
    sha: 579a42fc0b8e0c63b76519a339be31bed574929511fa53c1a3acae26eb258f29
  - name: version_check
    version: 0.9.4
    sha: 49874b5167b65d7193b8aba1567f5c7d93d001cafc34600cee003eda787e483f
  - name: wait-timeout
    version: 0.2.0
    sha: 9f200f5b12eb75f8c1ed65abd4b2db8a6e1b138a20de009dacee265a2498f3f6
  - name: walkdir
    version: 2.4.0
    sha: d71d857dc86794ca4c280d616f7da00d2dbfd8cd788846559a6813e6aa4b54ee
  - name: wasi
    version: 0.11.0+wasi-snapshot-preview1
    sha: 9c8d87e72b64a3b4db28d11ce29237c246188f4f51057d65a7eab63b7987e423
  - name: wasm-bindgen
    version: 0.2.87
    sha: 7706a72ab36d8cb1f80ffbf0e071533974a60d0a308d01a5d0375bf60499a342
  - name: wasm-bindgen-backend
    version: 0.2.87
    sha: 5ef2b6d3c510e9625e5fe6f509ab07d66a760f0885d858736483c32ed7809abd
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
  - name: weezl
    version: 0.1.7
    sha: 9193164d4de03a926d909d3bc7c30543cecb35400c02114792c2cae20d5e2dbb
  - name: wide
    version: 0.7.11
    sha: aa469ffa65ef7e0ba0f164183697b89b854253fd31aeb92358b7b6155177d62f
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
  - name: xml5ever
    version: 0.17.0
    sha: 4034e1d05af98b51ad7214527730626f019682d797ba38b51689212118d8e650
  - name: yeslogic-fontconfig-sys
    version: 4.0.1
    sha: ec657fd32bbcbeaef5c7bc8e10b3db95b143fab8db0a50079773dbf936fd4f73
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- components/gi-docgen.bst
- freedesktop-sdk.bst:components/python3-docutils.bst
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/gdk-pixbuf.bst
- components/glib.bst
- components/pango.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --enable-gtk-doc
    --enable-vala

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/librsvg-2.so'
