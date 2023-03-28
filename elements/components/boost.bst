kind: manual

sources:
- kind: tar
  url: boostorg:artifactory/main/release/1.79.0/source/boost_1_79_0.tar.bz2

  ref: 475d589d51a7f8b3ba2ba4eda022b170e562ca3b760ee922c146b6c65856ef39
depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  optimize-debug: 'false'
  local_flags: -fcommon

config:
  configure-commands:
  - ./bootstrap.sh --includedir=%{install-root}%{includedir} --libdir=%{install-root}%{libdir}
  build-commands:
  - ./b2 -q -j${JOBS} --build-dir=_build link=shared stage
  install-commands:
  - ./b2 -q --build-dir=_build link=shared install

environment:
  JOBS: '%{max-jobs}'

environment-nocache:
- JOBS
