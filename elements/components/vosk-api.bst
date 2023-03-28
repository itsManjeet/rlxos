kind: manual

sources:
- kind: git_tag
  url: https://github.com/alphacep/vosk-api.git
  track: master
  directory: vosk-api

  ref: go/v0.3.45-4-gfff40ce1a1f1b921272a184acfd0c21350750789
- kind: git_tag
  url: https://github.com/xianyi/OpenBLAS.git
  track: v0.3.20
  directory: OpenBLAS

  ref: v0.3.20-0-g0b678b19dc03f2a999d6e038814c4c50b9640a4e
- kind: git_tag
  url: https://github.com/alphacep/clapack.git
  track: v3.2.1
  directory: clapack

  ref: 67d9d1aa7261a1a8b457af3f38ea974946935b02
- kind: git_tag
  url: https://github.com/alphacep/openfst.git
  track: master
  directory: openfst

  ref: 7dfd808194105162f20084bb4d8e4ee4b65266d5
- kind: git_tag
  url: https://github.com/alphacep/kaldi.git
  track: vosk
  directory: kaldi

  ref: 93ef0019b847272a239fbb485ef97f29feb1d587
- kind: remote
  url: https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip

  ref: 30f26242c4eb449f948e42cb302dd7a686cb29a3423a8367f99ff41780942498
- kind: remote
  url: https://alphacephei.com/vosk/models/vosk-model-spk-0.4.zip

  ref: a74d8f51144484813e16af689bb0f916b7a111e2347f467c4933c1166097b5a7

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystems.bst
- freedesktop-sdk.bst:components/libarchive.bst

config:
  configure-commands:
  - mkdir -p models
  # - bsdtar -xf vosk-model-small-en-us-0.15.zip -C models
  - ln -sf ../../OpenBLAS kaldi/tools/OpenBLAS
  - ln -sf ../../clapack kaldi/tools/clapack
  - ln -sf ../../openfst kaldi/tools/openfst

  - autoreconf -fi openfst

  build-commands:
  - make -C OpenBLAS ONLY_CBLAS='1' DYNAMIC_ARCH='1' TARGET='NEHALEM' USE_LOCKING='1'
    USE_THREAD='0' all
  - make -C OpenBLAS PREFIX='%{build-root}/OpenBLAS/install' install

  - CFLAGS+=' -Wno-error=format-security -fcommon' cmake -B build-clapack -S clapack
    -Wno-dev
  - make -C build-clapack

  - |
    while read -r -d '' _file
    do
      cp -af "$_file" "%{build-root}/OpenBLAS/install/lib"
    done< <(find build-clapack -type f -name '*.a' -print0)

  - |
    cd openfst
    ./configure \
      --prefix='%{build-root}/kaldi/tools/openfst' \
      --enable-static \
      --enable-shared \
      --enable-far \
      --enable-ngram-fsts \
      --enable-lookahead-fsts \
      --with-pic \
      --disable-bin

    make

    make install

  - |
    cd %{build-root}/kaldi/src
    ./configure --mathlib='OPENBLAS_CLAPACK' --shared --use-cuda='no'
    sed -i 's/[[:space:]]-O1[[:space:]]/ -O3 /g' kaldi.mk
    make online2 lm rnnlm
    while read -r -d '' _file
    do
        rm "$_file"
    done < <(find "%{build-root}/kaldi" -type f -name '*.o' -print0)

  - |
    make -C "%{build-root}/vosk-api/src" \
      KALDI_ROOT="%{build-root}/kaldi" \
      EXTRA_CFLAGS="${CFLAGS} -fcommon" \
      OPENFST_ROOT="%{build-root}/kaldi/tools/openfst" \
      OPENBLAS_ROOT="%{build-root}/kaldi/tools/OpenBLAS/install"

  install-commands:
  - install -d -m755 %{install-root}/%{libdir}
  - install -D -m644 vosk-api/src/vosk_api.h -t %{install-root}/%{includedir}/
  - cp -dr --no-preserve='ownership' vosk-api/src/*.so* %{install-root}/%{libdir}/
