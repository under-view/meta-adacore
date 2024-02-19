# Original source:
# https://github.com/Lucretia/meta-ada/blob/master/recipes-devtools/gcc/gcc-cross_4.6.bbappend

ADA := ",ada"

LANGUAGES .= "${ADA}"

DEPENDS += "alire-gnat-native"

inherit ada-sources

SYSROOT_PATH = "${RECIPE_SYSROOT_NATIVE}/usr/bin/${ALIREC}"

PATH:prepend = "${SYSROOT_PATH}/bin:"

# For odd reasons when s-oscons-tmplt.c is being compiled. Compiler fails to find
# limits.h even though it's include in SYSROOT_PATH
# 
# Bellow fixes compile issues by manually defining limits.h macros used by source
# s-oscons-tmplt.c:321:95: error: 'INT_MAX' undeclared (first use in this function)
# gcc/ada/s-oscons-tmplt.c:166:1: note: 'INT_MAX' is defined in header '<limits.h>'; did you forget to '#include <limits.h>'?
#   165 | # include <signal.h>
#   +++ |+#include <limits.h>
#   166 | #endif
TARGET_CFLAGS:append = " -DINT_MAX=2147483647"
TARGET_CFLAGS:append = " -DLLONG_MAX=9223372036854775807LL"
TARGET_CFLAGS:append = " -DLLONG_MIN=-9223372036854775808LL"

TARGET_CFLAGS:append = " -I${RECIPE_SYSROOT}/usr/include"
TARGET_CFLAGS:append = " -I${SYSROOT_PATH}/usr/include"
TARGET_CFLAGS:append = " -I${SYSROOT_PATH}/include"
TARGET_LDFLAGS:append = " -L${SYSROOT_PATH}/lib"

EXTRA_OECONF_PATHS:remove = "--with-build-sysroot=${STAGING_DIR_TARGET}"
EXTRA_OECONF_PATHS:append = " --with-build-sysroot=${SYSROOT_PATH}"

do_compile () {
    export CC="${BUILD_CC}"
    export AR_FOR_TARGET="${TARGET_SYS}-ar"
    export RANLIB_FOR_TARGET="${TARGET_SYS}-ranlib"
    export LD_FOR_TARGET="${TARGET_SYS}-ld"
    export NM_FOR_TARGET="${TARGET_SYS}-nm"
    export CC_FOR_TARGET="${CCACHE} ${TARGET_SYS}-gcc"
    export CFLAGS_FOR_TARGET="${TARGET_CFLAGS}"
    export CPPFLAGS_FOR_TARGET="${TARGET_CPPFLAGS}"
    export CXXFLAGS_FOR_TARGET="${TARGET_CXXFLAGS}"
    export LDFLAGS_FOR_TARGET="${TARGET_LDFLAGS}"

    # Prevent native/host sysroot path from being used in configargs.h header,
    # as it will be rewritten when used by other sysroots preventing support
    # for gcc plugins
    oe_runmake configure-gcc
    sed -i 's@${STAGING_DIR_TARGET}@/host@g' ${B}/gcc/configargs.h
    sed -i 's@${STAGING_DIR_HOST}@/host@g' ${B}/gcc/configargs.h

    # Prevent sysroot/workdir paths from being used in checksum-options.
    # checksum-options is used to generate a checksum which is embedded into
    # the output binary.
    oe_runmake TARGET-gcc=checksum-options all-gcc
    sed -i 's@${DEBUG_PREFIX_MAP}@@g' ${B}/gcc/checksum-options
    sed -i 's@${STAGING_DIR_HOST}@/host@g' ${B}/gcc/checksum-options

    # Build in ada
    mkdir -p ${B}/${TARGET_SYS}/libada
    cp -a ${SYSROOT_PATH}/lib/*crt*.o ${B}/${TARGET_SYS}/libada

    sed -i -e 's@./config/i386/t-linux64@$(srcdir)/config/i386/t-linux64@g' \
              ${B}/gcc/ada/gcc-interface/Makefile

    oe_runmake all-host configure-target-libgcc
    (cd ${B}/${TARGET_SYS}/libgcc; oe_runmake enable-execute-stack.c unwind.h md-unwind-support.h sfp-machine.h gthr-default.h)
}

EXTRA_OECONF += " \
    --enable-libada \
    --enable-static=libada \
    --with-newlib \
    --without-headers \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    "

PACKAGES += "\
    gnat \
    gnat-dev \
    gnat-symlinks \
    "

FILES:gnat = "\
    ${bindir}/${TARGET_PREFIX}gnat \
    ${bindir}/${TARGET_PREFIX}gnatbind \
    ${bindir}/${TARGET_PREFIX}gnatchop \
    ${bindir}/${TARGET_PREFIX}gnatclean \
    ${bindir}/${TARGET_PREFIX}gnatfind \
    ${bindir}/${TARGET_PREFIX}gnatkr \
    ${bindir}/${TARGET_PREFIX}gnatlink \
    ${bindir}/${TARGET_PREFIX}gnatls \
    ${bindir}/${TARGET_PREFIX}gnatmake \
    ${bindir}/${TARGET_PREFIX}gnatname \
    ${bindir}/${TARGET_PREFIX}gnatprep \
    ${bindir}/${TARGET_PREFIX}gnatxref \
    ${libexecdir}/gcc/${TARGET_SYS}/${BINV}/gnat1 \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/lib*${SOLIBS} \
    "

FILES:gnat-dev = "\
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/*.ali \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/lib*.a \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adainclude/*.ad[sb] \
    "

FILES:gnat-symlinks = "\
    ${bindir}/gnat \
    ${bindir}/gnatbind \
    ${bindir}/gnatchop \
    ${bindir}/gnatclean \
    ${bindir}/gnatfind \
    ${bindir}/gnatkr \
    ${bindir}/gnatlink \
    ${bindir}/gnatls \
    ${bindir}/gnatmake \
    ${bindir}/gnatname \
    ${bindir}/gnatprep \
    ${bindir}/gnatxref \
    "

do_install:append() {

    cd "${D}/${bindir}"

    if [ -e ${TARGET_PREFIX}gnat ]; then
        ln -sf ${TARGET_PREFIX}gnat gnat || true
    fi
    if [ -e ${TARGET_PREFIX}gnatbind ]; then
        ln -sf ${TARGET_PREFIX}gnatbind gnatbind || true
    fi
    if [ -e ${TARGET_PREFIX}gnatchop ]; then
        ln -sf ${TARGET_PREFIX}gnatchop gnatchop || true
    fi
    if [ -e ${TARGET_PREFIX}gnatclean ]; then
        ln -sf ${TARGET_PREFIX}gnatclean gnatclean || true
    fi
    if [ -e ${TARGET_PREFIX}gnatfind ]; then
        ln -sf ${TARGET_PREFIX}gnatfind gnatfind || true
    fi
    if [ -e ${TARGET_PREFIX}gnatkr ]; then
        ln -sf ${TARGET_PREFIX}gnatkr gnatkr || true
    fi
    if [ -e ${TARGET_PREFIX}gnatlink ]; then
        ln -sf ${TARGET_PREFIX}gnatlink gnatlink || true
    fi
    if [ -e ${TARGET_PREFIX}gnatls ]; then
        ln -sf ${TARGET_PREFIX}gnatls gnatls || true
    fi
    if [ -e ${TARGET_PREFIX}gnatmake ]; then
        ln -sf ${TARGET_PREFIX}gnatmake gnatmake || true
    fi
    if [ -e ${TARGET_PREFIX}gnatname ]; then
        ln -sf ${TARGET_PREFIX}gnatname gnatname || true
    fi
    if [ -e ${TARGET_PREFIX}gnatprep ]; then
        ln -sf ${TARGET_PREFIX}gnatprep gnatprep || true
    fi
    if [ -e ${TARGET_PREFIX}gnatxref ]; then
        ln -sf ${TARGET_PREFIX}gnatxref gnatxref || true
    fi

    # Wipe precompiled gnat compiler pulled off internet.
    # As it's nolonger required.
    rm -rf ${SYSROOT_PATH}
}
