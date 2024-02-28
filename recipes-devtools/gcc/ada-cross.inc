inherit ada-sources

DEPENDS += "alire-gnat-native"

SYSROOT_PATH = "${RECIPE_SYSROOT_NATIVE}/usr/bin/${ALIREC}"

PATH:prepend = "${SYSROOT_PATH}/bin:"

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

export GNATBIND="gnatbind"
export GNATLINK="gnatlink"
export GNATMAKE="gnatmake"

ADA_CFLAGS = "-I${RECIPE_SYSROOT}/usr/include"
ADA_CFLAGS += "-I${SYSROOT_PATH}/usr/include"
ADA_CFLAGS += "-I${SYSROOT_PATH}/include"

ADA_FOR_BUILD = "-L${SYSROOT_PATH}/lib"

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
TARGET_CFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CXXFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CPPFLAGS:append = " ${ADA_CFLAGS}"

TARGET_LDFLAGS:append = " ${ADA_FOR_BUILD}"
