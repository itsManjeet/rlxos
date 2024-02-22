version: 2.42
about: A linker, an assembler, and other tools for handling object files

pre-script: |-
  sed -i '/^development=/s/true/false/' bfd/development.sh
  patch -Np1 -i patches/binutils/gold-warn-unsupported.patch

configure: >
  --with-lib-path=/usr/lib
  --with-bugurl=https://github.com/itsmanjeet/rlxos/issues
  --enable-cet
  --enable-colored-disassembly
  --enable-default-execstack=no
  --enable-deterministic-archives
  --enable-gold
  --enable-install-libiberty
  --enable-jansson
  --enable-ld=default
  --enable-new-dtags
  --enable-pgo-build=lto
  --enable-plugins
  --enable-relro
  --enable-shared
  --enable-targets=x86_64-pip,bpf-unknown-none
  --enable-threads
  --disable-gdb
  --disable-gdbserver
  --disable-libdecnumber
  --disable-readline
  --disable-sim
  --disable-werror
  --with-debuginfod
  --with-pic
  --with-system-zlib

compile: -O tooldir=%{prefix}
install: prefix=%{prefix} -O tooldir=%{install-root}/%{prefix}

post-script: |-
  install -m644 libiberty/pic/libiberty.a %{install-root}/%{libdir}/
  
  rm -fv %{install-root}/%{datadir}/man/man1/{dlltool,windres,windmc}*
  
  rm -fv %{install-root}/usr/lib/lib{bfd,opcodes}.so
  
  tee "%{install-root}/%{libdir}/libbfd.so" << EOS
  /* GNU ld script */
  INPUT( /usr/lib/libbfd.a -lsframe -liberty -lz -lzstd -ldl )
  EOS

  tee "%{install-root}/%{libdir}/libopcode.so" << EOS
  /* GNU ld script */
  INPUT( /usr/lib/libopcodes.a -lbfd )
  EOS

sources:
  - https://ftp.gnu.org/gnu/binutils/binutils-%{version}.tar.xz
  - patches/binutils/gold-warn-unsupported.patch
