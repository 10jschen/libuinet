#
# Derived from FreeBSD src/share/mk/bsd.prog.mk
#

ifdef DEBUG_FLAGS
CFLAGS+=${DEBUG_FLAGS}
CXXFLAGS+=${DEBUG_FLAGS}
endif

ifdef NO_SHARED
ifneq (${NO_SHARED},no)
ifneq (${NO_SHARED},NO)
LDFLAGS+= -static
endif
endif
endif

ifdef PROG_CXX
PROG=	${PROG_CXX}
endif

ifndef PROG
$(error  PROG or PROG_CXX must be defined.)
endif

ifndef SRCS
ifdef PROG_CXX
SRCS=	${PROG}.cc
else
SRCS=	${PROG}.c
endif
endif

OBJS+= $(patsubst %.cc,%.o,$(patsubst %.c,%.o,${SRCS}))


#
# Include Makefile.inc from each UINET library that is being used and
# set up the compiler and linker options for finding and linking to
# each one.
#
UINET_LIB_PATHS:= $(foreach lib,${UINET_LIBS},${TOPDIR}/lib/lib$(lib))
UINET_LIB_INCS:= $(foreach libpath,${UINET_LIB_PATHS},$(libpath)/Makefile.inc)
UINET_CFLAGS:= $(foreach lib,${UINET_LIBS}, -I${TOPDIR}/lib/lib$(lib)$(if $(wildcard ${TOPDIR}/lib/lib$(lib)/api_include),/api_include))

-include ${UINET_LIB_INCS}

#
# Including UINET_LIB_INCS may have added to UINET_LIBS in order to
# pick up additional link flags, so rebuild UINET_LIB_PATHS before
# building UINET_LDADD.
#
UINET_LIB_PATHS:= $(foreach lib,${UINET_LIBS},${TOPDIR}/lib/lib$(lib))
UINET_LDADD:= $(foreach lib,${UINET_LIBS}, ${TOPDIR}/lib/lib$(lib)$(if $(wildcard ${TOPDIR}/lib/lib$(lib)/.libs),/.libs)/lib$(lib).a)


CFLAGS+= ${UINET_CFLAGS}
CXXFLAGS+= ${UINET_CFLAGS}

${PROG}: ${OBJS}
ifdef PROG_CXX
	${CXX} ${CXXFLAGS} ${LDFLAGS} -o $@ ${OBJS} ${UINET_LDADD} ${LDADD} 
else
	${CC} ${CFLAGS} ${LDFLAGS} -o $@ ${OBJS} ${UINET_LDADD} ${LDADD}
endif


clean:
	@rm -f ${PROG} ${OBJS}

all: ${PROG}

install:
	${UINET_INSTALL_DIR} -d ${UINET_DESTDIR}/bin
	${UINET_INSTALL_BIN} ${PROG} ${UINET_DESTDIR}/bin

config:
