kind: autotools

sources:
- kind: tar
  url: gnome_downloads:librsvg/2.56/librsvg-2.56.0.tar.xz
  ref: 194b5097d9cd107495f49c291cf0da65ec2b4bb55e5628369751a3f44ba222b3
- kind: cargo

  ref:
  - name: adler
    version: 1.0.2
    sha: f26201604c87b1e01bd3d98f8d5d9a8fcbb815e8cedb41ffccbeb4bf593a35fe
  - name: aho-corasick
    version: 0.7.20
    sha: cc936419f96fa211c1b9166887b38e5e40b19958e5b895be7c1f93adec7071ac
  - name: android_system_properties
    version: 0.1.5
    sha: 819e7219dbd41043ac279b19830f2efc897156490d7fd6ea916720117ee66311
  - name: anes
    version: 0.1.6
    sha: 4b46cbb362ab8752921c97e041f5e366ee6297bd428a31275b9fcf1e380f7299
  - name: anstyle
    version: 0.3.4
    sha: 1ba0b55c2201aa802adb684e7963ce2c3191675629e7df899774331e3ac747cf
  - name: anyhow
    version: 1.0.69
    sha: 224afbd727c3d6e4b90103ece64b8d1b67fbb1973b1046c2281eed3f3803f800
  - name: approx
    version: 0.5.1
    sha: cab112f0a86d568ea0e627cc1d6be74a1e9cd55214684db5561995f6dad897c6
  - name: assert_cmd
    version: 2.0.10
    sha: ec0b2340f55d9661d76793b2bfc2eb0e62689bd79d067a95707ea762afd5e9dd
  - name: atty
    version: 0.2.14
    sha: d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8
  - name: autocfg
    version: 1.1.0
    sha: d468802bab17cbc0cc575e9b053f41e72aa36bfa6b7f55e3529ffa43161b97fa
  - name: base-x
    version: 0.2.11
    sha: 4cbbc9d0964165b47557570cce6c952866c2678457aca742aafc9fb771d30270
  - name: bit-set
    version: 0.5.3
    sha: 0700ddab506f33b20a03b13996eccd309a48e5ff77d0d95926aa0210fb4e95f1
  - name: bit-vec
    version: 0.6.3
    sha: 349f9b6a179ed607305526ca489b34ad0a41aed5f7980fa90eb03160b69598fb
  - name: bitflags
    version: 1.3.2
    sha: bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a
  - name: block
    version: 0.1.6
    sha: 0d8c1fef690941d3e7788d328517591fecc684c084084702d6ff1641e993699a
  - name: bstr
    version: 1.3.0
    sha: 5ffdb39cb703212f3c11973452c2861b972f757b021158f3516ba10f2fa8b2c1
  - name: bumpalo
    version: 3.12.0
    sha: 0d261e256854913907f67ed06efbc3338dfe6179796deefc1ff763fc1aee5535
  - name: bytemuck
    version: 1.13.1
    sha: 17febce684fd15d89027105661fec94afb475cb995fbc59d2865198446ba2eea
  - name: byteorder
    version: 1.4.3
    sha: 14c189c53d098945499cdfa7ecc63567cf3886b3332b312a5b4585d8d3a6a610
  - name: cairo-rs
    version: 0.17.0
    sha: a8af54f5d48af1226928adc1f57edd22f5df1349e7da1fc96ae15cf43db0e871
  - name: cairo-sys-rs
    version: 0.17.0
    sha: f55382a01d30e5e53f185eee269124f5e21ab526595b872751278dfbb463594e
  - name: cast
    version: 0.3.0
    sha: 37b2a672a2cb129a2e41c10b1224bb368f9f37a2b16b612598138befd7b37eb5
  - name: cc
    version: 1.0.79
    sha: 50d30906286121d95be3d479533b458f87493b30a4b5f79a607db8f5d11aa91f
  - name: cfg-expr
    version: 0.11.0
    sha: b0357a6402b295ca3a86bc148e84df46c02e41f41fef186bda662557ef6328aa
  - name: cfg-if
    version: 1.0.0
    sha: baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd
  - name: chrono
    version: 0.4.24
    sha: 4e3c5919066adf22df73762e50cffcde3a758f2a848b113b586d1f86728b673b
  - name: ciborium
    version: 0.2.0
    sha: b0c137568cc60b904a7724001b35ce2630fd00d5d84805fbb608ab89509d788f
  - name: ciborium-io
    version: 0.2.0
    sha: 346de753af073cc87b52b2083a506b38ac176a44cfb05497b622e27be899b369
  - name: ciborium-ll
    version: 0.2.0
    sha: 213030a2b5a4e0c0892b6652260cf6ccac84827b83a85a534e178e3906c4cf1b
  - name: clap
    version: 3.2.23
    sha: 71655c45cb9845d3270c9d6df84ebe72b4dad3c2ba3f7023ad47c144e4e473a5
  - name: clap
    version: 4.1.9
    sha: 9a9d6ada83c1edcce028902ea27dd929069c70df4c7600b131b4d9a1ad2879cc
  - name: clap_complete
    version: 4.1.5
    sha: 37686beaba5ac9f3ab01ee3172f792fc6ffdd685bfb9e63cfef02c0571a4e8e1
  - name: clap_derive
    version: 4.1.9
    sha: fddf67631444a3a3e3e5ac51c36a5e01335302de677bd78759eaa90ab1f46644
  - name: clap_lex
    version: 0.2.4
    sha: 2850f2f5a82cbf437dd5af4d49848fbdfc27c157c3d010345776f952765261c5
  - name: clap_lex
    version: 0.3.3
    sha: 033f6b7a4acb1f358c742aaca805c939ee73b4c6209ae4318ec7aca81c42e646
  - name: codespan-reporting
    version: 0.11.1
    sha: 3538270d33cc669650c4b093848450d380def10c331d38c768e34cac80576e6e
  - name: const-cstr
    version: 0.3.0
    sha: ed3d0b5ff30645a68f35ece8cea4556ca14ef8a1651455f789a099a0513532a6
  - name: const_fn
    version: 0.4.9
    sha: fbdcdcb6d86f71c5e97409ad45898af11cbc995b4ee8112d59095a28d376c935
  - name: convert_case
    version: 0.4.0
    sha: 6245d59a3e82a7fc217c5828a6692dbc6dfb63a0c8c90495621f7b9d79704a0e
  - name: core-foundation-sys
    version: 0.8.3
    sha: 5827cebf4670468b8772dd191856768aedcb1b0278a04f989f7766351917b9dc
  - name: crc32fast
    version: 1.3.2
    sha: b540bd8bc810d3885c6ea91e2018302f68baba2129ab3e88f32389ee9370880d
  - name: criterion
    version: 0.4.0
    sha: e7c76e09c1aae2bc52b3d2f29e13c6572553b30c4aa1b8a49fd70de6412654cb
  - name: criterion-plot
    version: 0.5.0
    sha: 6b50826342786a51a89e2da3a28f1c32b06e387201bc2d19791f622c673706b1
  - name: crossbeam-channel
    version: 0.5.7
    sha: cf2b3e8478797446514c91ef04bafcb59faba183e621ad488df88983cc14128c
  - name: crossbeam-deque
    version: 0.8.3
    sha: ce6fd6f855243022dcecf8702fef0c297d4338e226845fe067f6341ad9fa0cef
  - name: crossbeam-epoch
    version: 0.9.14
    sha: 46bd5f3f85273295a9d14aedfb86f6aadbff6d8f5295c4a9edb08e819dcf5695
  - name: crossbeam-utils
    version: 0.8.15
    sha: 3c063cd8cc95f5c377ed0d4b49a4b21f632396ff690e8470c29b3359b346984b
  - name: cssparser
    version: 0.29.6
    sha: f93d03419cb5950ccfd3daf3ff1c7a36ace64609a1a8746d493df1ca0afde0fa
  - name: cssparser-macros
    version: 0.6.0
    sha: dfae75de57f2b2e85e8768c3ea840fd159c8f33e2b6522c7835b7abac81be16e
  - name: cxx
    version: 1.0.92
    sha: 9a140f260e6f3f79013b8bfc65e7ce630c9ab4388c6a89c71e07226f49487b72
  - name: cxx-build
    version: 1.0.92
    sha: da6383f459341ea689374bf0a42979739dc421874f112ff26f829b8040b8e613
  - name: cxxbridge-flags
    version: 1.0.92
    sha: 90201c1a650e95ccff1c8c0bb5a343213bdd317c6e600a93075bca2eff54ec97
  - name: cxxbridge-macro
    version: 1.0.92
    sha: 0b75aed41bb2e6367cae39e6326ef817a851db13c13e4f3263714ca3cfb8de56
  - name: data-url
    version: 0.2.0
    sha: 8d7439c3735f405729d52c3fbbe4de140eaf938a1fe47d227c27f8254d4302a5
  - name: derive_more
    version: 0.99.17
    sha: 4fb810d30a7c1953f91334de7244731fc3f3c10d7fe163338a35b9f640960321
  - name: difflib
    version: 0.4.0
    sha: 6184e33543162437515c2e2b48714794e37845ec9851711914eec9d308f6ebe8
  - name: discard
    version: 1.0.4
    sha: 212d0f5754cb6769937f4501cc0e67f4f4483c8d2c3e1e922ee9edbe4ab4c7c0
  - name: dlib
    version: 0.5.0
    sha: ac1b7517328c04c2aa68422fc60a41b92208182142ed04a25879c26c8f878794
  - name: doc-comment
    version: 0.3.3
    sha: fea41bba32d969b513997752735605054bc0dfa92b4c56bf1189f2e174be7a10
  - name: dtoa
    version: 0.4.8
    sha: 56899898ce76aaf4a0f24d914c97ea6ed976d42fec6ad33fcbb0a1103e07b2b0
  - name: dtoa-short
    version: 0.3.3
    sha: bde03329ae10e79ede66c9ce4dc930aa8599043b0743008548680f25b91502d6
  - name: either
    version: 1.8.1
    sha: 7fcaabb2fef8c910e7f4c7ce9f67a1283a1715879a7c230ca9d6d1ae31f16d91
  - name: encoding
    version: 0.2.33
    sha: 6b0d943856b990d12d3b55b359144ff341533e516d94098b1d3fc1ac666d36ec
  - name: encoding-index-japanese
    version: 1.20141219.5
    sha: 04e8b2ff42e9a05335dbf8b5c6f7567e5591d0d916ccef4e0b1710d32a0d0c91
  - name: encoding-index-korean
    version: 1.20141219.5
    sha: 4dc33fb8e6bcba213fe2f14275f0963fd16f0a02c878e3095ecfdf5bee529d81
  - name: encoding-index-simpchinese
    version: 1.20141219.5
    sha: d87a7194909b9118fc707194baa434a4e3b0fb6a5a757c73c3adb07aa25031f7
  - name: encoding-index-singlebyte
    version: 1.20141219.5
    sha: 3351d5acffb224af9ca265f435b859c7c01537c0849754d3db3fdf2bfe2ae84a
  - name: encoding-index-tradchinese
    version: 1.20141219.5
    sha: fd0e20d5688ce3cab59eb3ef3a2083a5c77bf496cb798dc6fcdb75f323890c18
  - name: encoding_index_tests
    version: 0.1.4
    sha: a246d82be1c9d791c5dfde9a2bd045fc3cbba3fa2b11ad558f27d01712f00569
  - name: errno
    version: 0.2.8
    sha: f639046355ee4f37944e44f60642c6f3a7efa3cf6b78c78a0d989a8ce6c396a1
  - name: errno-dragonfly
    version: 0.1.2
    sha: aa68f1b12764fab894d2755d2518754e71b4fd80ecfb822714a1206c2aab39bf
  - name: fastrand
    version: 1.9.0
    sha: e51093e27b0797c359783294ca4f0a911c270184cb10f85783b118614a1501be
  - name: flate2
    version: 1.0.25
    sha: a8a2db397cb1c8772f31494cb8917e48cd1e64f0fa7efac59fbd741a0a8ce841
  - name: float-cmp
    version: 0.9.0
    sha: 98de4bbd547a563b716d8dfa9aad1cb19bfab00f4fa09a6a4ed21dbcf44ce9c4
  - name: fnv
    version: 1.0.7
    sha: 3f9eec918d3f24069decb9af1554cad7c880e2da24a9afd88aca000531ab82c1
  - name: form_urlencoded
    version: 1.1.0
    sha: a9c384f161156f5260c24a097c56119f9be8c798586aecc13afbcbe7b7e26bf8
  - name: futf
    version: 0.1.5
    sha: df420e2e84819663797d1ec6544b13c5be84629e7bb00dc960d6917db2987843
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
  - name: fxhash
    version: 0.2.1
    sha: c31b6d751ae2c7f11320402d34e41349dd1016f8d5d45e48c4312bc8625af50c
  - name: gdk-pixbuf
    version: 0.17.0
    sha: b023fbe0c6b407bd3d9805d107d9800da3829dc5a676653210f1d5f16d7f59bf
  - name: gdk-pixbuf-sys
    version: 0.17.0
    sha: 7b41bd2b44ed49d99277d3925652a163038bd5ed943ec9809338ffb2f4391e3b
  - name: getrandom
    version: 0.1.16
    sha: 8fc3cb4d91f53b50155bdcfd23f6a4c39ae1969c2ae85982b135750cccaf5fce
  - name: getrandom
    version: 0.2.8
    sha: c05aeb6a22b8f62540c194aac980f2115af067bfe15a0734d7277a768d396b31
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
  - name: half
    version: 1.8.2
    sha: eabb4a44450da02c90444cf74558da904edde8fb4e9035a9a6a4e15445af0bd7
  - name: hashbrown
    version: 0.12.3
    sha: 8a9ee70c43aaf417c914396645a0fa852624801b24ebb7ae78fe8272889ac888
  - name: heck
    version: 0.4.1
    sha: 95505c38b4572b2d910cecb0281560f54b440a19336cbbcb27bf6ce6adc6f5a8
  - name: hermit-abi
    version: 0.1.19
    sha: 62b467343b94ba476dcb2500d242dadbb39557df889310ac77c5d99100aaac33
  - name: hermit-abi
    version: 0.2.6
    sha: ee512640fe35acbfb4bb779db6f0d80704c2cacfa2e39b601ef3e3f47d1ae4c7
  - name: hermit-abi
    version: 0.3.1
    sha: fed44880c466736ef9a5c5b5facefb5ed0785676d0c02d612db14e54f0d84286
  - name: iana-time-zone
    version: 0.1.53
    sha: 64c122667b287044802d6ce17ee2ddf13207ed924c712de9a66a5814d5b64765
  - name: iana-time-zone-haiku
    version: 0.1.1
    sha: 0703ae284fc167426161c2e3f1da3ea71d94b21bedbcc9494e92b28e334e3dca
  - name: idna
    version: 0.3.0
    sha: e14ddfc70884202db2244c223200c204c2bda1bc6e0998d11b5e024d657209e6
  - name: indexmap
    version: 1.9.2
    sha: 1885e79c1fc4b10f0e172c475f458b7f7b93061064d98c3293e98c5ba0c8b399
  - name: instant
    version: 0.1.12
    sha: 7a5bbe824c507c5da5956355e86a746d82e0e1464f65d862cc5e71da70e94b2c
  - name: io-lifetimes
    version: 1.0.7
    sha: 76e86b86ae312accbf05ade23ce76b625e0e47a255712b7414037385a1c05380
  - name: is-terminal
    version: 0.4.4
    sha: 21b6b32576413a8e69b90e952e4a026476040d81017b80445deda5f2d3921857
  - name: itertools
    version: 0.10.5
    sha: b0fd2260e829bddf4cb6ea802289de2f86d6a7a690192fbe91b3f46e0f2c8473
  - name: itoa
    version: 1.0.6
    sha: 453ad9f582a441959e5f0d088b02ce04cfe8d51a8eaf077f12ac6d3e94164ca6
  - name: js-sys
    version: 0.3.61
    sha: 445dde2150c55e483f3d8416706b97ec8e8237c307e5b7b4b8dd15e6af2a0730
  - name: language-tags
    version: 0.3.2
    sha: d4345964bb142484797b161f473a503a434de77149dd8c7427788c6e13379388
  - name: lazy_static
    version: 1.4.0
    sha: e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646
  - name: libc
    version: 0.2.140
    sha: 99227334921fae1a979cf0bfdfcc6b3e5ce376ef57e16fb6fb3ea2ed6095f80c
  - name: libloading
    version: 0.7.4
    sha: b67380fd3b2fbe7527a606e18729d21c6f3951633d0500574c4dc22d2d638b9f
  - name: libm
    version: 0.2.6
    sha: 348108ab3fba42ec82ff6e9564fc4ca0247bdccdc68dd8af9764bbc79c3c8ffb
  - name: link-cplusplus
    version: 1.0.8
    sha: ecd207c9c713c34f95a097a5b029ac2ce6010530c7b49d7fea24d977dede04f5
  - name: linked-hash-map
    version: 0.5.6
    sha: 0717cef1bc8b636c6e1c1bbdefc09e6322da8a9321966e8928ef80d20f7f770f
  - name: linux-raw-sys
    version: 0.1.4
    sha: f051f77a7c8e6957c0696eac88f26b0117e54f52d3fc682ab19397a8812846a4
  - name: locale_config
    version: 0.3.0
    sha: 08d2c35b16f4483f6c26f0e4e9550717a2f6575bcd6f12a53ff0c490a94a6934
  - name: lock_api
    version: 0.4.9
    sha: 435011366fe56583b16cf956f9df0095b405b82d76425bc8981c0e22e60ec4df
  - name: log
    version: 0.4.17
    sha: abb12e687cfb44aa40f41fc3978ef76448f9b6038cad6aef4259d3c095a2382e
  - name: lopdf
    version: 0.29.0
    sha: de0f69c40d6dbc68ebac4bf5aec3d9978e094e22e29fcabd045acd9cec74a9dc
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
    version: 0.3.2
    sha: add85d4dd35074e6fedc608f8c8f513a3548619a9024b751949ef0e8e45a4d84
  - name: memchr
    version: 2.5.0
    sha: 2dffe52ecf27772e601905b7522cb4ef790d2cc203488bbd0e2fe85fcb74566d
  - name: memoffset
    version: 0.8.0
    sha: d61c719bcfbcf5d62b3a09efa6088de8c54bc0bfcd3ea7ae39fcc186108b8de1
  - name: miniz_oxide
    version: 0.6.2
    sha: b275950c28b37e794e8c55d88aeb5e139d0ce23fdbbeda68f8d7174abdf9e8fa
  - name: nalgebra
    version: 0.32.2
    sha: d68d47bba83f9e2006d117a9a33af1524e655516b8919caac694427a6fb1e511
  - name: nalgebra-macros
    version: 0.2.0
    sha: d232c68884c0c99810a5a4d333ef7e47689cfd0edc85efc9e54e1e6bf5212766
  - name: new_debug_unreachable
    version: 1.0.4
    sha: e4a24736216ec316047a1fc4252e27dabb04218aa4a3f37c6e7ddbf1f9782b54
  - name: nodrop
    version: 0.1.14
    sha: 72ef4a56884ca558e5ddb05a1d1e7e1bfd9a68d9ed024c21704cc98872dae1bb
  - name: normalize-line-endings
    version: 0.3.0
    sha: 61807f77802ff30975e01f4f071c8ba10c022052f98b3294119f3e615d13e5be
  - name: num-complex
    version: 0.4.3
    sha: 02e0d21255c828d6f128a1e41534206671e8c3ea0c62f32291e808dc82cff17d
  - name: num-integer
    version: 0.1.45
    sha: 225d3389fb3509a24c93f5c29eb6bde2586b98d9f016636dff58d7c6f7569cd9
  - name: num-rational
    version: 0.4.1
    sha: 0638a1c9d0a3c0914158145bc76cff373a75a627e6ecbfb71cbe6f453a5a19b0
  - name: num-traits
    version: 0.2.15
    sha: 578ede34cf02f8924ab9447f50c28075b4d3e5b269972345e7e0372b38c6cdcd
  - name: num_cpus
    version: 1.15.0
    sha: 0fac9e2da13b5eb447a6ce3d392f23a29d8694bff781bf03a16cd9ac8697593b
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
  - name: oorandom
    version: 11.1.3
    sha: 0ab1bc2a289d34bd04a330323ac98a1b4bc82c9d9fcb1e66b63caa84da26b575
  - name: os_str_bytes
    version: 6.4.1
    sha: 9b7820b9daea5457c9f21c69448905d723fbd21136ccf521748f23fd49e723ee
  - name: pango
    version: 0.17.4
    sha: 52c280b82a881e4208afb3359a8e7fde27a1b272280981f1f34610bed5770d37
  - name: pango-sys
    version: 0.17.0
    sha: 4293d0f0b5525eb5c24734d30b0ed02cd02aa734f216883f376b54de49625de8
  - name: pangocairo
    version: 0.17.0
    sha: 2feeb7ea7874507f83f5e7ba869c54e321959431c8fbd70d4b735c8b15d90506
  - name: pangocairo-sys
    version: 0.17.3
    sha: f60f1be8ef08087ddcbdcc1350e06073bff11113d425d12b622b716d96b9611c
  - name: parking_lot
    version: 0.12.1
    sha: 3742b2c103b9f06bc9fff0a37ff4912935851bee6d36f3c02bcc755bcfec228f
  - name: parking_lot_core
    version: 0.9.7
    sha: 9069cbb9f99e3a5083476ccb29ceb1de18b9118cafa53e90c9551235de2b9521
  - name: paste
    version: 1.0.12
    sha: 9f746c4065a8fa3fe23974dd82f15431cc8d40779821001404d10d2e79ca7d79
  - name: percent-encoding
    version: 2.2.0
    sha: 478c572c3d73181ff3c2539045f6eb99e5491218eae919370993b890cdbdd98e
  - name: phf
    version: 0.10.1
    sha: fabbf1ead8a5bcbc20f5f8b939ee3f5b0f6f281b6ad3468b84656b658b455259
  - name: phf
    version: 0.8.0
    sha: 3dfb61232e34fcb633f43d12c58f83c1df82962dcdfa565a4e866ffc17dafe12
  - name: phf_codegen
    version: 0.10.0
    sha: 4fb1c3a8bc4dd4e5cfce29b44ffc14bedd2ee294559a294e2a4d4c9e9a6a13cd
  - name: phf_codegen
    version: 0.8.0
    sha: cbffee61585b0411840d3ece935cce9cb6321f01c45477d30066498cd5e1a815
  - name: phf_generator
    version: 0.10.0
    sha: 5d5285893bb5eb82e6aaf5d59ee909a06a16737a8970984dd7746ba9283498d6
  - name: phf_generator
    version: 0.8.0
    sha: 17367f0cc86f2d25802b2c26ee58a7b23faeccf78a396094c13dced0d0182526
  - name: phf_macros
    version: 0.10.0
    sha: 58fdf3184dd560f160dd73922bea2d5cd6e8f064bf4b13110abd81b03697b4e0
  - name: phf_shared
    version: 0.10.0
    sha: b6796ad771acdc0123d2a88dc428b5e38ef24456743ddb1744ed628f9815c096
  - name: phf_shared
    version: 0.8.0
    sha: c00cf8b9eafe68dde5e9eaa2cef8ee84a9336a47d566ec55ca16589633b65af7
  - name: pin-project-lite
    version: 0.2.9
    sha: e0a7ae3ac2f1173085d398531c705756c94a4c56843785df85a60c1a0afac116
  - name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - name: pkg-config
    version: 0.3.26
    sha: 6ac9a59f73473f1b8d852421e59e64809f025994837ef743615c6d0c5b305160
  - name: plotters
    version: 0.3.4
    sha: 2538b639e642295546c50fcd545198c9d64ee2a38620a628724a3b266d5fbf97
  - name: plotters-backend
    version: 0.3.4
    sha: 193228616381fecdc1224c62e96946dfbc73ff4384fba576e052ff8c1bea8142
  - name: plotters-svg
    version: 0.3.3
    sha: f9a81d2759aae1dae668f783c308bc5c8ebd191ff4184aaa1b37f65a6ae5a56f
  - name: png
    version: 0.17.7
    sha: 5d708eaf860a19b19ce538740d2b4bdeeb8337fa53f7738455e706623ad5c638
  - name: pom
    version: 3.2.0
    sha: 07e2192780e9f8e282049ff9bffcaa28171e1cb0844f49ed5374e518ae6024ec
  - name: ppv-lite86
    version: 0.2.17
    sha: 5b40af805b3121feab8a3c29f04d8ad262fa8e0561883e7653e024ae4479e6de
  - name: precomputed-hash
    version: 0.1.1
    sha: 925383efa346730478fb4838dbe9137d2a47675ad789c546d150a6e1dd4ab31c
  - name: predicates
    version: 2.1.5
    sha: 59230a63c37f3e18569bdb90e4a89cbf5bf8b06fea0b84e65ea10cc4df47addd
  - name: predicates
    version: 3.0.1
    sha: 1ba7d6ead3e3966038f68caa9fc1f860185d95a793180bbcfe0d0da47b3961ed
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
  - name: proc-macro-hack
    version: 0.5.20+deprecated
    sha: dc375e1527247fe1a97d8b7156678dfe7c1af2fc075c9a4db3690ecd2a148068
  - name: proc-macro2
    version: 1.0.52
    sha: 1d0e1ae9e836cc3beddd63db0df682593d7e2d3d891ae8c9083d2113e1744224
  - name: proptest
    version: 1.1.0
    sha: 29f1b898011ce9595050a68e60f90bad083ff2987a695a42357134c8381fba70
  - name: quick-error
    version: 1.2.3
    sha: a1d01941d82fa2ab50be1e79e6714289dd7cde78eba4c074bc5a4374f650dfe0
  - name: quick-error
    version: 2.0.1
    sha: a993555f31e5a609f617c12db6250dedcac1b0a85076912c436e6fc9b2c8e6a3
  - name: quote
    version: 1.0.26
    sha: 4424af4bf778aae2051a77b60283332f386554255d722233d09fbfc7e30da2fc
  - name: rand
    version: 0.7.3
    sha: 6a6b1679d49b24bbfe0c803429aa1874472f50d9b363131f0e89fc356b544d03
  - name: rand
    version: 0.8.5
    sha: 34af8d1a0e25924bc5b7c43c079c942339d8f0a8b57c39049bef581b46327404
  - name: rand_chacha
    version: 0.2.2
    sha: f4c8ed856279c9737206bf725bf36935d8666ead7aa69b52be55af369d193402
  - name: rand_chacha
    version: 0.3.1
    sha: e6c10a63a0fa32252be49d21e7709d4d4baf8d231c2dbce1eaa8141b9b127d88
  - name: rand_core
    version: 0.5.1
    sha: 90bde5296fc891b0cef12a6d03ddccc162ce7b2aff54160af9338f8d40df6d19
  - name: rand_core
    version: 0.6.4
    sha: ec0be4795e2f6a28069bec0b5ff3e2ac9bafc99e6a9a7dc3547996c5c816922c
  - name: rand_hc
    version: 0.2.0
    sha: ca3129af7b92a17112d59ad498c6f81eaf463253766b90396d39ea7a39d6613c
  - name: rand_pcg
    version: 0.2.1
    sha: 16abd0c1b639e9eb4d7c50c0b8100b0d0f849be2349829c740fe8e6eb4816429
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
    version: 0.2.16
    sha: fb5a58c1855b4b6819d59012155603f0b22ad30cad752600aadfcb695265519a
  - name: regex
    version: 1.7.1
    sha: 48aaa5748ba571fb95cd2c85c09f629215d3a6ece942baa100950af03a34f733
  - name: regex-automata
    version: 0.1.10
    sha: 6c230d73fb8d8c1b9c0b3135c5142a8acee3a0558fb8db5cf1cb65f8d7862132
  - name: regex-syntax
    version: 0.6.28
    sha: 456c603be3e8d448b072f410900c09faf164fbce2d480456f50eea6e25f9c848
  - name: rgb
    version: 0.8.36
    sha: 20ec2d3e3fc7a92ced357df9cebd5a10b6fb2aa1ee797bf7e9ce2f17dffc8f59
  - name: rustc_version
    version: 0.2.3
    sha: 138e3e0acb6c9fb258b19b67cb8abd63c00679d2851805ea151465464fe9030a
  - name: rustc_version
    version: 0.4.0
    sha: bfa0f585226d2e68097d4f95d113b15b83a82e819ab25717ec0590d9584ef366
  - name: rustix
    version: 0.36.9
    sha: fd5c6ff11fecd55b40746d1995a02f2eb375bf8c00d192d521ee09f42bef37bc
  - name: rusty-fork
    version: 0.3.0
    sha: cb3dcc6e454c328bb824492db107ab7c0ae8fcffe4ad210136ef014458c1bc4f
  - name: ryu
    version: 1.0.13
    sha: f91339c0467de62360649f8d3e185ca8de4224ff281f66000de5eb2a77a79041
  - name: safe_arch
    version: 0.6.0
    sha: 794821e4ccb0d9f979512f9c1973480123f9bd62a90d74ab0f9426fcf8f4a529
  - name: same-file
    version: 1.0.6
    sha: 93fc1dc3aaa9bfed95e02e6eadabb4baf7e3078b0bd1b4d7b6b0b68378900502
  - name: scopeguard
    version: 1.1.0
    sha: d29ab0c6d3fc0ee92fe66e2d99f700eab17a8d57d1c1d3b748380fb20baa78cd
  - name: scratch
    version: 1.0.5
    sha: 1792db035ce95be60c3f8853017b3999209281c24e2ba5bc8e59bf97a0c590c1
  - name: selectors
    version: 0.24.0
    sha: 0c37578180969d00692904465fb7f6b3d50b9a2b952b87c23d0e2e5cb5013416
  - name: semver
    version: 0.9.0
    sha: 1d7eb9ef2c18661902cc47e535f9bc51b78acd254da71d375c2f6720d9a40403
  - name: semver
    version: 1.0.17
    sha: bebd363326d05ec3e2f532ab7660680f3b02130d780c299bca73469d521bc0ed
  - name: semver-parser
    version: 0.7.0
    sha: 388a1df253eca08550bef6c72392cfe7c30914bf41df5269b68cbd6ff8f570a3
  - name: serde
    version: 1.0.156
    sha: 314b5b092c0ade17c00142951e50ced110ec27cea304b1037c6969246c2469a4
  - name: serde_derive
    version: 1.0.156
    sha: d7e29c4601e36bcec74a223228dce795f4cd3616341a4af93520ca1a837c087d
  - name: serde_json
    version: 1.0.94
    sha: 1c533a59c9d8a93a09c6ab31f0fd5e5f4dd1b8fc9434804029839884765d04ea
  - name: servo_arc
    version: 0.2.0
    sha: d52aa42f8fdf0fed91e5ce7f23d8138441002fa31dca008acf47e6fd4721f741
  - name: sha1
    version: 0.6.1
    sha: c1da05c97445caa12d05e848c4a4fcbbea29e748ac28f7e80e9b010392063770
  - name: sha1_smol
    version: 1.0.0
    sha: ae1a47186c03a32177042e55dbc5fd5aee900b8e0069a8d70fba96a9375cd012
  - name: simba
    version: 0.8.0
    sha: 50582927ed6f77e4ac020c057f37a268fc6aebc29225050365aacbb9deeeddc4
  - name: siphasher
    version: 0.3.10
    sha: 7bd3e3206899af3f8b12af284fafc038cc1dc2b41d1b89dd17297221c5d225de
  - name: slab
    version: 0.4.8
    sha: 6528351c9bc8ab22353f9d776db39a20288e8d6c37ef8cfe3317cf875eecfc2d
  - name: smallvec
    version: 1.10.0
    sha: a507befe795404456341dfab10cef66ead4c041f62b8b11bbb92bffe5d0953e0
  - name: stable_deref_trait
    version: 1.2.0
    sha: a8f112729512f8e442d81f95a8a7ddf2b7c6b8a1a6f509a95864142b30cab2d3
  - name: standback
    version: 0.2.17
    sha: e113fb6f3de07a243d434a56ec6f186dfd51cb08448239fe7bcae73f87ff28ff
  - name: stdweb
    version: 0.4.20
    sha: d022496b16281348b52d0e30ae99e01a73d737b2f45d38fed4edf79f9325a1d5
  - name: stdweb-derive
    version: 0.5.3
    sha: c87a60a40fccc84bef0652345bbbbbe20a605bf5d0ce81719fc476f5c03b50ef
  - name: stdweb-internal-macros
    version: 0.2.9
    sha: 58fa5ff6ad0d98d1ffa8cb115892b6e69d67799f6763e162a1c9db421dc22e11
  - name: stdweb-internal-runtime
    version: 0.1.5
    sha: 213701ba3370744dcd1a12960caa4843b3d68b4d1c0a5d575e0d65b2ee9d16c0
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
  - name: system-deps
    version: 6.0.3
    sha: 2955b1fe31e1fa2fbd1976b71cc69a606d7d4da16f6de3333d0c92d51419aeff
  - name: tempfile
    version: 3.4.0
    sha: af18f7ae1acd354b992402e9ec5864359d693cd8a79dcbef59f76891701c1e95
  - name: tendril
    version: 0.4.3
    sha: d24a120c5fc464a3458240ee02c299ebcb9d67b5249c8848b09d639dca8d7bb0
  - name: termcolor
    version: 1.2.0
    sha: be55cf8942feac5c765c2c993422806843c9a9a45d4d5c407ad6dd2ea95eb9b6
  - name: termtree
    version: 0.4.1
    sha: 3369f5ac52d5eb6ab48c6b4ffdc8efbcad6b89c765749064ba298f2c68a16a76
  - name: textwrap
    version: 0.16.0
    sha: 222a222a5bfe1bba4a77b45ec488a741b3cb8872e5e499451fd7d0129c9c7c3d
  - name: thiserror
    version: 1.0.39
    sha: a5ab016db510546d856297882807df8da66a16fb8c4101cb8b30054b0d5b2d9c
  - name: thiserror-impl
    version: 1.0.39
    sha: 5420d42e90af0c38c3290abcca25b9b3bdf379fc9f55c528f53a269d9c9a267e
  - name: time
    version: 0.2.27
    sha: 4752a97f8eebd6854ff91f1c1824cd6160626ac4bd44287f7f4ea2035a02a242
  - name: time-macros
    version: 0.1.1
    sha: 957e9c6e26f12cb6d0dd7fc776bb67a706312e7299aed74c8dd5b17ebb27e2f1
  - name: time-macros-impl
    version: 0.1.2
    sha: fd3c141a1b43194f3f56a1411225df8646c55781d5f26db825b3d98507eb482f
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
    version: 0.5.11
    sha: f4f7f0dd8d50a853a531c426359045b1998f04219d88799810762cd4ad314234
  - name: toml_datetime
    version: 0.6.1
    sha: 3ab8ed2edee10b50132aed5f331333428b011c99402b5a534154ed15746f9622
  - name: toml_edit
    version: 0.19.7
    sha: dc18466501acd8ac6a3f615dd29a3438f8ca6bb3b19537138b3106e575621274
  - name: typenum
    version: 1.16.0
    sha: 497961ef93d974e23eb6f433eb5fe1b7930b659f06d12dec6fc44a8f554c0bba
  - name: unarray
    version: 0.1.4
    sha: eaea85b334db583fe3274d12b4cd1880032beab409c0d774be044d4480ab9a94
  - name: unicode-bidi
    version: 0.3.11
    sha: 524b68aca1d05e03fdf03fcdce2c6c94b6daf6d16861ddaa7e4f2b6638a9052c
  - name: unicode-ident
    version: 1.0.8
    sha: e5464a87b239f13a63a501f2701565754bae92d243d4bb7eb12f6d57d2269bf4
  - name: unicode-normalization
    version: 0.1.22
    sha: 5c5713f0fc4b5db668a2ac63cdb7bb4469d8c9fed047b1d0292cc7b0ce2ba921
  - name: unicode-width
    version: 0.1.10
    sha: c0edd1e5b14653f783770bce4a4dabb4a5108a5370a5f5d8cfe8710c361f6c8b
  - name: url
    version: 2.3.1
    sha: 0d68c799ae75762b8c3fe375feb6600ef5602c883c5d21eb51c09f22b83c4643
  - name: utf-8
    version: 0.7.6
    sha: 09cc8ee72d2a9becf2f2febe0205bbed8fc6615b7cb429ad062dc7b7ddd036a9
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
    version: 2.3.3
    sha: 36df944cda56c7d8d8b7496af378e6b16de9284591917d307c9b4d313c44e698
  - name: wasi
    version: 0.11.0+wasi-snapshot-preview1
    sha: 9c8d87e72b64a3b4db28d11ce29237c246188f4f51057d65a7eab63b7987e423
  - name: wasi
    version: 0.9.0+wasi-snapshot-preview1
    sha: cccddf32554fecc6acb585f82a32a72e28b48f8c4c1883ddfeeeaa96f7d8e519
  - name: wasm-bindgen
    version: 0.2.84
    sha: 31f8dcbc21f30d9b8f2ea926ecb58f6b91192c17e9d33594b3df58b2007ca53b
  - name: wasm-bindgen-backend
    version: 0.2.84
    sha: 95ce90fd5bcc06af55a641a86428ee4229e44e07033963a2290a8e241607ccb9
  - name: wasm-bindgen-macro
    version: 0.2.84
    sha: 4c21f77c0bedc37fd5dc21f897894a5ca01e7bb159884559461862ae90c0b4c5
  - name: wasm-bindgen-macro-support
    version: 0.2.84
    sha: 2aff81306fcac3c7515ad4e177f521b5c9a15f2b08f4e32d823066102f35a5f6
  - name: wasm-bindgen-shared
    version: 0.2.84
    sha: 0046fef7e28c3804e5e38bfa31ea2a0f73905319b677e57ebe37e49358989b5d
  - name: web-sys
    version: 0.3.61
    sha: e33b99f4b23ba3eec1a53ac264e35a755f00e966e0065077d6027c0f575b0b97
  - name: weezl
    version: 0.1.7
    sha: 9193164d4de03a926d909d3bc7c30543cecb35400c02114792c2cae20d5e2dbb
  - name: wide
    version: 0.7.8
    sha: b689b6c49d6549434bf944e6b0f39238cf63693cb7a147e9d887507fffa3b223
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
  - name: windows-sys
    version: 0.42.0
    sha: 5a3e1820f08b8513f676f7ab6c1f99ff312fb97b553d30ff4dd86f9f15728aa7
  - name: windows-sys
    version: 0.45.0
    sha: 75283be5efb2831d37ea142365f009c02ec203cd29a3ebecbc093d52315b66d0
  - name: windows-targets
    version: 0.42.2
    sha: 8e5180c00cd44c9b1c88adb3693291f1cd93605ded80c250a75d472756b4d071
  - name: windows_aarch64_gnullvm
    version: 0.42.2
    sha: 597a5118570b68bc08d8d59125332c54f1ba9d9adeedeef5b99b02ba2b0698f8
  - name: windows_aarch64_msvc
    version: 0.42.2
    sha: e08e8864a60f06ef0d0ff4ba04124db8b0fb3be5776a5cd47641e942e58c4d43
  - name: windows_i686_gnu
    version: 0.42.2
    sha: c61d927d8da41da96a81f029489353e68739737d3beca43145c8afec9a31a84f
  - name: windows_i686_msvc
    version: 0.42.2
    sha: 44d840b6ec649f480a41c8d80f9c65108b92d89345dd94027bfe06ac444d1060
  - name: windows_x86_64_gnu
    version: 0.42.2
    sha: 8de912b8b8feb55c064867cf047dda097f92d51efad5b491dfb98f6bbb70cb36
  - name: windows_x86_64_gnullvm
    version: 0.42.2
    sha: 26d41b46a36d453748aedef1486d5c7a85db22e56aff34643984ea85514e94a3
  - name: windows_x86_64_msvc
    version: 0.42.2
    sha: 9aec5da331524158c6d1a4ac0ab1541149c0b9505fde06423b02f5ef0106b9f0
  - name: winnow
    version: 0.3.6
    sha: 23d020b441f92996c80d94ae9166e8501e59c7bb56121189dc9eab3bd8216966
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
