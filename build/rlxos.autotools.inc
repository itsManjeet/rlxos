
SOURCE_DIR ?= .
ifdef DISTDIR
	SOURCE_DIR = ${DISTDIR}
endif

all: .build-done

clean:

install: .build-done
	${MAKE} ${INSTALL_ARGS}

compile_db:

.configure-done: ${SOURCE_DIR}/configure
	$< ${CONFIGURE_ARGS} ${EXTRA_CONFIGURE_ARGS}
	
	@touch $@

.build-done: .configure-done
	${PRE_BUILD_COMMANDS}
	${MAKE} ${BUILD_ARGS}
	${POST_BUILD_COMMANDS}

	@touch $@

include ${.TOPDIR}/build/rlxos.sources.inc