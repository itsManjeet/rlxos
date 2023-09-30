kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-tour/45/gnome-tour-45.0.tar.xz

  ref: 5be4b8ef4b8f4d5ecaccc31048db6e085a8f7bffadaa0843b8e8a788ff1dadee
- kind: cargo
  ref:
  - name: aho-corasick
    version: 1.0.5
    sha: 0c378d78423fdad8089616f827526ee33c19f2fddbd5de1629152c9593ba4783
  - name: anyhow
    version: 1.0.75
    sha: a4668cab20f66d8d020e1fbc0ebe47217433c1b6c8f2040faf858554e394ace6
  - name: autocfg
    version: 1.1.0
    sha: d468802bab17cbc0cc575e9b053f41e72aa36bfa6b7f55e3529ffa43161b97fa
  - name: bitflags
    version: 2.4.0
    sha: b4682ae6287fcf752ecaabbfcc7b6f9b72aa33933dc23a554d853aea8eea8635
  - name: block
    version: 0.1.6
    sha: 0d8c1fef690941d3e7788d328517591fecc684c084084702d6ff1641e993699a
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
  - name: env_logger
    version: 0.10.0
    sha: 85cdab6a89accf66733ad5a1693a4dcced6aeff64602b634530dd73c1f3ee9f0
  - name: equivalent
    version: 1.0.1
    sha: 5443807d6dff69373d433ab9ef5378ad8df50ca6298caf15de6e52e24aaf54d5
  - name: errno
    version: 0.3.3
    sha: 136526188508e25c6fef639d7927dfb3e0e3084488bf202267829cf7fc23dbdd
  - name: errno-dragonfly
    version: 0.1.2
    sha: aa68f1b12764fab894d2755d2518754e71b4fd80ecfb822714a1206c2aab39bf
  - name: field-offset
    version: 0.3.6
    sha: 38e2275cc4e4fc009b0669731a1e5ab7ebf11f469eaede2bab9309a5b4d6057f
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
  - name: humantime
    version: 2.1.0
    sha: 9a3a5bfb195931eeb336b2a7b4d761daec841b97f947d34394601737a7bba5e4
  - name: indexmap
    version: 2.0.0
    sha: d5477fe2230a79769d8dc68e0eabf5437907c0457a5614a9e8dddb67f65eb65d
  - name: is-terminal
    version: 0.4.9
    sha: cb0889898416213fab133e1d33a0e5858a48177452750691bde3666d0fdbaf8b
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
    version: 0.9.0
    sha: 5a634b1c61a95585bd15607c6ab0c4e5b226e695ff2800ba0cdccddf208c406c
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
  - name: pango
    version: 0.18.0
    sha: 06a9e54b831d033206160096b825f2070cf5fda7e35167b1c01e9e774f9202d1
  - name: pango-sys
    version: 0.18.0
    sha: 436737e391a843e5933d6d9aa102cb126d501e815b83601365a948a518555dc5
  - name: pin-project-lite
    version: 0.2.13
    sha: 8afb450f006bf6385ca15ef45d71d2288452bc3683ce2e2cacc0d18e4be60b58
  - name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - name: pkg-config
    version: 0.3.27
    sha: 26072860ba924cbfa98ea39c8c19b4dd6a4a25423dbdf219c1eca91aa0cf6964
  - name: pretty_env_logger
    version: 0.5.0
    sha: 865724d4dbe39d9f3dd3b52b88d859d66bcb2d6a0acfd5ea68a65fb66d4bdc1c
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
  - name: serde_spanned
    version: 0.6.3
    sha: 96426c9936fd7a0124915f9185ea1d20aa9445cc9821142f0a73bc9207a2e186
  - name: slab
    version: 0.4.9
    sha: 8f92a496fb766b417c996b9c5e57daf2f7ad3b0bebe1ccfca4856390e3d3bb67
  - name: smallvec
    version: 1.11.0
    sha: 62bb4feee49fdd9f707ef802e22365a35de4b7b299de4763d44bfea899442ff9
  - name: syn
    version: 1.0.109
    sha: 72b64191b275b66ffe2469e8af2c1cfe3bafa67b529ead792a6d0160888b4237
  - name: syn
    version: 2.0.36
    sha: 91e02e55d62894af2a08aca894c6577281f76769ba47c94d5756bec8ac6e7373
  - name: system-deps
    version: 6.1.1
    sha: 30c2de8a4d8f4b823d634affc9cd2a74ec98c53a756f317e529a48046cbf71f3
  - name: target-lexicon
    version: 0.12.11
    sha: 9d0e916b1148c8e263850e1ebcbd046f333e0683c724876bb0da63ea4373dc8a
  - name: temp-dir
    version: 0.1.11
    sha: af547b166dd1ea4b472165569fc456cfb6818116f854690b0ff205e636523dab
  - name: termcolor
    version: 1.2.0
    sha: be55cf8942feac5c765c2c993422806843c9a9a45d4d5c407ad6dd2ea95eb9b6
  - name: thiserror
    version: 1.0.48
    sha: 9d6d7a740b8a666a7e828dd00da9c0dc290dff53154ea77ac109281de90589b7
  - name: thiserror-impl
    version: 1.0.48
    sha: 49922ecae66cc8a249b77e68d1d0623c1b2c514f0060c27cdc68bd62a1219d35
  - name: toml
    version: 0.7.8
    sha: dd79e69d3b627db300ff956027cc6c3798cef26d22526befdfcd12feeb6d2257
  - name: toml_datetime
    version: 0.6.3
    sha: 7cda73e2f1397b1262d6dfdcef8aafae14d1de7748d66822d3bfeeb6d03e5e4b
  - name: toml_edit
    version: 0.19.15
    sha: 1b5bb770da30e5cbfde35a2d7b9b8a2c4b8ef89548a7a6aeab5c9a576e3e7421
  - name: unicode-ident
    version: 1.0.12
    sha: 3354b9ac3fae1ff6755cb6db53683adb661634f67557942dea4facebec0fee4b
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
# - kind: patch
#   path: patches/gnome-tour/0001-rlxos-specified-patches.patch
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
