#!/bin/bash



PERL_SRC_FLDR="perl-$PERL_VERSION"

RLXOS_DOWNLOAD "https://www.cpan.org/src/5.0/$PERL_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $PERL_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$PERL_SRC_FLDR


sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.32/core_perl     \
             -Darchlib=/usr/lib/perl5/5.32/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.32/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.32/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl

make
make install