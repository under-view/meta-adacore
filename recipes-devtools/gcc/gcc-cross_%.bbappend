# Original source:
# https://github.com/Lucretia/meta-ada/blob/master/recipes-devtools/gcc/gcc-cross_4.6.bbappend

DEPENDS += "alire-gnat-native"

inherit ada-sources
require recipes-devtools/gcc/ada.inc

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

EXTRA_OECONF += " \
    --with-newlib \
    --without-headers \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-shared \
    --disable-libatomic \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    "

do_install () {
    ( cd ${B}/${TARGET_SYS}/libgcc; oe_runmake 'DESTDIR=${D}' install-unwind_h-forbuild install-unwind_h )

    # Run make install to ensuring adalib,adainclude gets installed
    oe_runmake 'DESTDIR=${D}' install

    install -d ${D}${target_base_libdir}
    install -d ${D}${target_libdir}

    # Link gfortran to g77 to satisfy not-so-smart configure or hard coded g77
    # gfortran is fully backwards compatible. This is a safe and practical solution.
    if [ -n "${@d.getVar('FORTRAN')}" ]; then
        ln -sf ${STAGING_DIR_NATIVE}${prefix_native}/bin/${TARGET_PREFIX}gfortran ${STAGING_DIR_NATIVE}${prefix_native}/bin/${TARGET_PREFIX}g77 || true
        fortsymlinks="g77 gfortran"
    fi

    # Insert symlinks into libexec so when tools without a prefix are searched for, the correct ones are
    # found. These need to be relative paths so they work in different locations.
    dest=${D}${libexecdir}/gcc/${TARGET_SYS}/${BINV}/
    install -d $dest
    for t in ar as ld ld.bfd ld.gold nm objcopy objdump ranlib strip gcc cpp $fortsymlinks; do
        ln -sf ${BINRELPATH}/${TARGET_PREFIX}$t $dest$t
        ln -sf ${BINRELPATH}/${TARGET_PREFIX}$t ${dest}${TARGET_PREFIX}$t
    done

    # Remove things we don't need but keep share/java
    for d in info man share/doc share/locale share/man share/info; do
        rm -rf ${D}${STAGING_DIR_NATIVE}${prefix_native}/$d
    done

    find ${D}${libdir}/gcc/${TARGET_SYS}/${BINV}/include-fixed -type f -not -name "README" -not -name limits.h -not -name syslimits.h | xargs rm -f

    # install LTO linker plugins where binutils tools can find it
    install -d ${D}${libdir}/bfd-plugins
    ln -sf ${LIBRELPATH}/liblto_plugin.so ${D}${libdir}/bfd-plugins/liblto_plugin.so
}
