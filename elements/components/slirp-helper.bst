kind: manual

build-depends:
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:components/libffi.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:components/libslirp.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:bootstrap-import.bst

sources:
- kind: tar
  url: crates:crates/libslirp/libslirp-4.3.0.crate
  ref: 4c6f95366c6c3299af0cfe7852888ca4b0aed40eeb22ca2ff644bec799439455
- kind: cargo
  ref:
  - name: ansi_term
    version: 0.11.0
    sha: ee49baf6cb617b853aa8d93bf420db2383fab46d314482ca2803b40d5fde979b
  - name: atty
    version: 0.2.14
    sha: d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8
  - name: bitflags
    version: 1.2.1
    sha: cf1de2fe8c75bc145a2f577add951f8134889b4795d47466a54a5c846d691693
  - name: block-buffer
    version: 0.7.3
    sha: c0940dc441f31689269e10ac70eb1002a3a1d3ad1390e030043662eb7fe4688b
  - name: block-padding
    version: 0.1.5
    sha: fa79dedbb091f449f1f39e53edf88d5dbe95f895dae6135a8d7b881fb5af73f5
  - name: byte-tools
    version: 0.3.1
    sha: e3b5ca7a04898ad4bcd41c90c5285445ff5b791899bb1b0abdd2a2aa791211d7
  - name: byteorder
    version: 1.3.4
    sha: 08c48aae112d48ed9f069b33538ea9e3e90aa263cfa3d1c24309612b1f7472de
  - name: cc
    version: 1.0.61
    sha: ed67cbde08356238e75fc4656be4749481eeffb09e19f320a25237d5221c985d
  - name: cfg-if
    version: 0.1.10
    sha: 4785bdd1c96b2a846b2bd7cc02e86b6b3dbf14e7e53446c4f54c92a361040822
  - name: clap
    version: 2.33.3
    sha: 37e58ac78573c40708d45522f0d80fa2f01cc4f9b4e2bf749807255454312002
  - name: crypto-mac
    version: 0.7.0
    sha: 4434400df11d95d556bac068ddfedd482915eb18fe8bea89bc80b6e4b1c179e5
  - name: derivative
    version: 2.1.1
    sha: cb582b60359da160a9477ee80f15c8d784c477e69c217ef2cdd4169c24ea380f
  - name: digest
    version: 0.8.1
    sha: f3d0c8c8752312f9713efd397ff63acb9f85585afbf179282e720e7704954dd5
  - name: enumflags2
    version: 0.6.4
    sha: 83c8d82922337cd23a15f88b70d8e4ef5f11da38dd7cdb55e84dd5de99695da0
  - name: enumflags2_derive
    version: 0.6.4
    sha: 946ee94e3dbf58fdd324f9ce245c7b238d46a66f00e86a020b71996349e46cce
  - name: error-chain
    version: 0.12.4
    sha: 2d2f06b9cac1506ece98fe3231e3cc9c4410ec3d5b1f24ae1c8946f0742cdefc
  - name: etherparse
    version: 0.8.3
    sha: 706c7cc3e05a64c496e9cca52ef8ad82a846a8c5b03345fddd81a76009a435b7
  - name: fake-simd
    version: 0.1.2
    sha: e88a8acf291dafb59c2d96e8f59828f3838bb1a70398823ade51a84de6a6deed
  - name: fastrand
    version: 1.4.0
    sha: ca5faf057445ce5c9d4329e382b2ce7ca38550ef3b73a5348362d5f24e0c7fe3
  - name: fuchsia-zircon
    version: 0.3.3
    sha: 2e9763c69ebaae630ba35f74888db465e49e259ba1bc0eda7d06f4a067615d82
  - name: fuchsia-zircon-sys
    version: 0.3.3
    sha: 3dcaa9ae7725d12cdb85b3ad99a434db70b468c09ded17e012d86b5c1010f7a7
  - name: generic-array
    version: 0.12.3
    sha: c68f0274ae0e023facc3c97b2e00f076be70e254bc851d972503b328db79b2ec
  - name: heck
    version: 0.3.1
    sha: 20564e78d53d2bb135c343b3f47714a56af2061f1c928fdb541dc7b9fdd94205
  - name: hermit-abi
    version: 0.1.17
    sha: 5aca5565f760fb5b220e499d72710ed156fdb74e631659e99377d9ebfbd13ae8
  - name: hmac
    version: 0.7.1
    sha: 5dcb5e64cda4c23119ab41ba960d1e170a774c8e4b9d9e6a9bc18aabf5e59695
  - name: idna
    version: 0.2.0
    sha: 02e2673c30ee86b5b96a9cb52ad15718aa1f966f5ab9ad54a8b95d5ca33120a9
  - name: instant
    version: 0.1.7
    sha: 63312a18f7ea8760cdd0a7c5aac1a619752a246b833545e3e36d1f81f7cd9e66
  - name: iovec
    version: 0.1.4
    sha: b2b3ea6ff95e175473f8ffe6a7eb7c00d054240321b84c57051175fe3c1e075e
  - name: ipnetwork
    version: 0.17.0
    sha: 02c3eaab3ac0ede60ffa41add21970a7df7d91772c03383aac6c2c3d53cc716b
  - name: kernel32-sys
    version: 0.2.2
    sha: 7507624b29483431c0ba2d82aece8ca6cdba9382bff4ddd0f7490560c056098d
  - name: lazy_static
    version: 1.4.0
    sha: e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646
  - name: lazycell
    version: 1.3.0
    sha: 830d08ce1d1d941e6b30645f1a0eb5643013d835ce3779a5fc208261dbe10f55
  - name: libc
    version: 0.2.79
    sha: 2448f6066e80e3bfc792e9c98bf705b4b0fc6e8ef5b43e5889aff0eaa9c58743
  - name: libslirp-sys
    version: 4.2.0
    sha: 26e54a5719a79bee3b25ee15e4b2cf80f51597b2d45d9889f3c1b8c150d907b4
  - name: libsystemd
    version: 0.2.1
    sha: f3a64961e79726a5b05e0db592097ca895831d755484203578fe75b580847262
  - name: log
    version: 0.4.11
    sha: 4fabed175da42fed1fa0746b0ea71f412aa9d35e76e95e59b192c64b9dc2bf8b
  - name: matches
    version: 0.1.8
    sha: 7ffc5c5338469d4d3ea17d269fa8ea3512ad247247c30bd2df69e68309ed0a08
  - name: mio
    version: 0.6.22
    sha: fce347092656428bc8eaf6201042cb551b8d67855af7374542a92a0fbfcac430
  - name: mio-extras
    version: 2.0.6
    sha: 52403fe290012ce777c4626790c8951324a2b9e3316b3143779c72b029742f19
  - name: miow
    version: 0.2.1
    sha: 8c1f2f3b1cf331de6896aabf6e9d55dca90356cc9960cca7eaaf408a355ae919
  - name: net2
    version: 0.2.35
    sha: 3ebc3ec692ed7c9a255596c67808dee269f64655d8baf7b4f0638e51ba1d6853
  - name: nix
    version: 0.17.0
    sha: 50e4785f2c3b7589a0d0c1dd60285e1188adac4006e8abd6dd578e1567027363
  - name: once_cell
    version: 1.4.1
    sha: 260e51e7efe62b592207e9e13a68e43692a7a279171d6ba57abd208bf23645ad
  - name: opaque-debug
    version: 0.2.3
    sha: 2839e79665f131bdb5782e51f2c6c9599c133c6098982a54c794358bf432529c
  - name: percent-encoding
    version: 2.1.0
    sha: d4fd5641d01c8f18a23da7b6fe29298ff4b55afcccdf78973b24cf3175fee32e
  - name: pkg-config
    version: 0.3.19
    sha: 3831453b3449ceb48b6d9c7ad7c96d5ea673e9b470a1dc578c2ce6521230884c
  - name: proc-macro-crate
    version: 0.1.5
    sha: 1d6ea3c4595b96363c13943497db34af4460fb474a95c43f4446ad341b8c9785
  - name: proc-macro-error
    version: 1.0.4
    sha: da25490ff9892aab3fcf7c36f08cfb902dd3e71ca0f9f9517bea02a73a5ce38c
  - name: proc-macro-error-attr
    version: 1.0.4
    sha: a1be40180e52ecc98ad80b184934baf3d0d29f979574e439af5a55274b35f869
  - name: proc-macro2
    version: 1.0.24
    sha: 1e0704ee1a7e00d7bb417d0770ea303c1bccbabf0ef1667dae92b5967f5f8a71
  - name: quote
    version: 1.0.7
    sha: aa563d17ecb180e500da1cfd2b028310ac758de548efdd203e18f283af693f37
  - name: scoped-tls
    version: 1.0.0
    sha: ea6a9290e3c9cf0f18145ef7ffa62d68ee0bf5fcd651017e586dc7fd5da448c2
  - name: serde
    version: 1.0.117
    sha: b88fa983de7720629c9387e9f517353ed404164b1e482c970a90c1a4aaf7dc1a
  - name: serde_derive
    version: 1.0.117
    sha: cbd1ae72adb44aab48f325a02444a5fc079349a8d804c1fc922aed3f7454c74e
  - name: serde_repr
    version: 0.1.6
    sha: 2dc6b7951b17b051f3210b063f12cc17320e2fe30ae05b0fe2a3abb068551c76
  - name: sha2
    version: 0.8.2
    sha: a256f46ea78a0c0d9ff00077504903ac881a1dafdc20da66545699e7776b3e69
  - name: slab
    version: 0.4.2
    sha: c111b5bd5695e56cffe5129854aa230b39c93a305372fdbb2668ca2394eea9f8
  - name: strsim
    version: 0.8.0
    sha: 8ea5119cdb4c55b55d432abb513a0429384878c15dde60cc77b1c99de1a95a6a
  - name: structopt
    version: 0.3.20
    sha: 126d630294ec449fae0b16f964e35bf3c74f940da9dca17ee9b905f7b3112eb8
  - name: structopt-derive
    version: 0.4.13
    sha: 65e51c492f9e23a220534971ff5afc14037289de430e3c83f9daf6a1b6ae91e8
  - name: subtle
    version: 1.0.0
    sha: 2d67a5a62ba6e01cb2192ff309324cb4875d0c451d55fe2319433abe7a05a8ee
  - name: syn
    version: 1.0.45
    sha: ea9c5432ff16d6152371f808fb5a871cd67368171b09bb21b43df8e4a47a3556
  - name: textwrap
    version: 0.11.0
    sha: d326610f408c7a4eb6f51c37c330e496b08506c9457c9d34287ecc38809fb060
  - name: tinyvec
    version: 0.3.4
    sha: 238ce071d267c5710f9d31451efec16c5ee22de34df17cc05e56cbc92e967117
  - name: toml
    version: 0.5.7
    sha: 75cf45bb0bef80604d001caaec0d09da99611b3c0fd39d3080468875cdb65645
  - name: typenum
    version: 1.12.0
    sha: 373c8a200f9e67a0c95e62a4f52fbf80c23b4381c05a17845531982fa99e6b33
  - name: unicode-bidi
    version: 0.3.4
    sha: 49f2bd0c6468a8230e1db229cff8029217cf623c767ea5d60bfbd42729ea54d5
  - name: unicode-normalization
    version: 0.1.13
    sha: 6fb19cf769fa8c6a80a162df694621ebeb4dafb606470b2b2fce0be40a98a977
  - name: unicode-segmentation
    version: 1.6.0
    sha: e83e153d1053cbb5a118eeff7fd5be06ed99153f00dbcd8ae310c5fb2b22edc0
  - name: unicode-width
    version: 0.1.8
    sha: 9337591893a19b88d8d87f2cec1e73fad5cdfd10e5a6f349f498ad6ea2ffb1e3
  - name: unicode-xid
    version: 0.2.1
    sha: f7fe0bb3479651439c9112f72b6c505038574c9fbb575ed1bf3b797fa39dd564
  - name: url
    version: 2.1.1
    sha: 829d4a8476c35c9bf0bbce5a3b23f4106f79728039b726d292bb93bc106787cb
  - name: uuid
    version: 0.8.1
    sha: 9fde2f6a4bea1d6e007c4ad38c6839fa71cbb63b6dbf5b595aa38dc9b1093c11
  - name: vec_map
    version: 0.8.2
    sha: f1bddf1187be692e79c5ffeab891132dfb0f236ed36a43c7ed39f1165ee20191
  - name: version_check
    version: 0.9.2
    sha: b5a972e5669d67ba988ce3dc826706fb0a8b01471c088cb0b6110b805cc36aed
  - name: void
    version: 1.0.2
    sha: 6a02e4885ed3bc0f2de90ea6dd45ebcbb66dacffe03547fadbb0eeae2770887d
  - name: winapi
    version: 0.2.8
    sha: 167dc9d6949a9b857f3451275e911c3f44255842c1f7a76f33c55103a909087a
  - name: winapi
    version: 0.3.9
    sha: 5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419
  - name: winapi-build
    version: 0.1.1
    sha: 2d315eee3b34aca4797b2da6b13ed88266e6d612562a0c46390af8299fc699bc
  - name: winapi-i686-pc-windows-gnu
    version: 0.4.0
    sha: ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6
  - name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
  - name: ws2_32-sys
    version: 0.2.1
    sha: d59cefebd0c892fa2dd6de581e937301d8552cb44489cdff035c6187cb63fa5e
  - name: zbus
    version: 1.2.1
    sha: 3a8a1a98eac87778308d7b2725cee6543a13936a3913b98e37fcf8ce9e4362da
  - name: zbus_macros
    version: 1.2.1
    sha: 9ca4d050be67f3b7a29878a6f0788a8dcd100c7297e619dcb91051f94679a8a4
  - name: zvariant
    version: 2.2.0
    sha: fb79b31a454101beda19e64082dfd9ad59c5ff8afa41e1de1065333105b02740
  - name: zvariant_derive
    version: 2.2.0
    sha: 605bf414a59d93a3d55055e72ea066c5c0bc578ed2227df15c407207b1c780ef

config:
  install-commands:
  - cargo install --all-features --path . --root "%{install-root}%{prefix}"
  - rm "%{install-root}%{prefix}"/.crates*
  - ln -s libslirp-helper "%{install-root}%{bindir}/slirp-helper"
