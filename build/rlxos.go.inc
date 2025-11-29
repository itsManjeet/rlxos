include ${.TOPDIR}/build/rlxos.toolchain.inc

ifndef PACKAGE
PACKAGE = rlxos.dev/$(shell realpath --relative-to ${.TOPDIR} ${.SRCDIR})
endif

TARGET := ${PACKAGE:rlxos.dev/%=${SYSROOT_PATH}/%}

ifeq (${CGO_ENABLED}, 1)
export CGO_CFLAGS	+= --sysroot=${SYSROOT_PATH}
export CGO_LDFLAGS	+= --sysroot=${SYSROOT_PATH}
else
CGO_ENABLED = 0
endif

all: ${PRE_TARGETS} ${TARGET} ${POST_TARGETS}

${SYSROOT_PATH}/%:
	GOOS=${GOOS} GOARCH=${GOARCH} CGO_ENABLED=${CGO_ENABLED} ${GO} build ${GOFLAGS} -o $@ ${@:${SYSROOT_PATH}/%=rlxos.dev/%}

clean:
	rm -rf ${TARGET} ${GENERATED_FILES}

install:
	install -v -D -m0755 ${TARGET} -o ${TARGET:${SYSROOT_PATH}/%=%{DESTDIR}/%}

compile_db:
	echo "${TARGET}: $$(find $$(go -C ${.TOPDIR} list ${GOFLAGS} -deps ${PACKAGE} | grep '^rlxos.dev' | sed 's#^rlxos.dev/#${.TOPDIR}/#g') -type f -name '*.go' | sort | tr '\n' ' ')" > depends.inc

-include ./depends.inc
