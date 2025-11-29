.TOPDIR 	?= .
include ${.TOPDIR}/build/rlxos.defaults.inc

.BUILDDIR 	?= _out/${TARGET_TRIPLET}
.OBJDIR 	?= ${.BUILDDIR}
.SRCDIR 	?= .
.CURDIR 	?= .
.RELDIR 	:= ${.SRCDIR:.%=${.TOPDIR}/%}

SUBDIR_MFLAGS =	--no-print-directory 							\
		-I $(abspath ${.TOPDIR}/build)							\
		-C $(abspath ${.OBJDIR}/$$nextdir) 						\
		-f $(abspath ${.RELDIR}/$$nextdir/rlxos.mk) 			\
		.TOPDIR=$(abspath ${.TOPDIR}) 							\
		.SRCDIR=$(abspath ${.SRCDIR}/$$nextdir) 				\
		.OBJDIR=$(abspath ${.OBJDIR}/$$nextdir) 				\
		.BUILDDIR=$(abspath ${.BUILDDIR})						\
		_THISDIR_=$$nextdir
		
SUBDIR_TARGETS = all install clean fetch-sources compile_db

$(SUBDIR_TARGETS): _SUBDIRUSE

define __SUBDIRUSE
for nextdir in ${SUBDIR}; do												\
	b=; for s in ${SKIPDIR}; do												\
		[ "$$s" = "$$nextdir" ] && b=1 && break;							\
	done;																	\
	[ -n "$$b" ] && echo "($$nextdir skipped)" && continue;					\
	echo "  DIR $${_THISDIR_:+$${_THISDIR_}/}$$nextdir";					\
	mkdir -p "${.OBJDIR}/$$nextdir"											\
	&& ${MAKE} ${SUBDIR_MFLAGS} ${MAKECMDGOALS} || exit 1;					\
done
endef

_SUBDIRUSE:
ifneq (${SUBDIR},)
	+@${__SUBDIRUSE}

${SUBDIR}:
	+@nextdir="$@"; 					\
	echo "  DIR $$nextdir"; 			\
	mkdir -p "${.OBJDIR}/$$nextdir" 	\
	&& ${MAKE} ${SUBDIR_MFLAGS} all || exit 1
endif

.PHONY: _SUBDIRUSE $(SUBDIR_TARGETS) $(SUBDIR)