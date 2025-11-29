.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR := ${.TOPDIR}/_external/go

all: ${TOOLCHAIN_PATH}/lib/go/bin/go

${TOOLCHAIN_PATH}/lib/go/bin/go: ${DISTDIR}/bin/go
	@mkdir -p ${TOOLCHAIN_PATH}/lib/go/
	cd ${DISTDIR}; \
		cp -a bin pkg src lib misc api test \
			${TOOLCHAIN_PATH}/lib/go/

	ln -sf ../../lib/go/bin/go    ${TOOLCHAIN_PATH}/bin/go
	ln -sf ../../lib/go/bin/gofmt ${TOOLCHAIN_PATH}/bin/gofmt

	rm -rf ${TOOLCHAIN_PATH}/lib/go/pkg/bootstrap
	rm -rf ${TOOLCHAIN_PATH}/lib/go/pkg/obj/go-build

	cp ${DISTDIR}/go.env ${TOOLCHAIN_PATH}/lib/go/

${DISTDIR}/bin/go:
	cd ${DISTDIR}/src; \
		./make.bash

clean:
	rm -rf ${TOOLCHAIN_PATH}/lib/go/
	rm -f  ${TOOLCHAIN_PATH}/bin/go ${TOOLCHAIN_PATH}/bin/gofmt

install:

compile_db:

fetch-sources: