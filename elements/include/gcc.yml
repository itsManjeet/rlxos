version: 13.1.0
release: 1
about: The GNU compiler collection, which includes the C and C++ compilers

pre-script: |
  sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64

configure: >
  LD=ld 
  --enable-languages=c,c++,lto
  --enable-default-pie
  --enable-default-ssp
  --disable-multilib
  --disable-bootstrap
  --disable-fixincludes
  --with-system-zlib

post-script: |
  mkdir -p %{install-root}/usr/lib/bfd-plugins/
  ln -sv ../bin/cpp %{install-root}/usr/lib/
  ln -sfv ../../lib/gcc/x86_64-pc-linux-gnu/%{version}/liblto_plugin.so \
    %{install-root}/usr/lib/bfd-plugins/

  ln -sv gcc %{install-root}/usr/bin/cc

  if [[ -d %{install-root}/lib ]] ; then
    cp %{install-root}/lib/* %{install-root}/usr/lib/ -a
    rm %{install-root}/lib -r
  fi

sources:
  - https://ftp.gnu.org/gnu/gcc/gcc-%{version}/gcc-%{version}.tar.xz