inherit ada-sources

DEPENDS += "alire-gnat-native"

SYSROOT_PATH = "${RECIPE_SYSROOT_NATIVE}/usr/bin/${ALIREC}"

PATH:prepend = "${SYSROOT_PATH}/bin:"

EXTRA_OECONF_PATHS:remove = "--with-build-sysroot=${STAGING_DIR_TARGET}"
EXTRA_OECONF_PATHS:append = " --with-build-sysroot=${SYSROOT_PATH}"

export GNATBIND="gnatbind"
export GNATLINK="gnatlink"
export GNATMAKE="gnatmake"

ADA_CFLAGS += "-I${RECIPE_SYSROOT}/usr/include"
ADA_CFLAGS += "-I${SYSROOT_PATH}/usr/include"
ADA_CFLAGS += "-I${SYSROOT_PATH}/include"

ADA_FOR_BUILD = "-L${SYSROOT_PATH}/lib"

TARGET_CFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CXXFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CPPFLAGS:append = " ${ADA_CFLAGS}"

TARGET_LDFLAGS:append = " ${ADA_FOR_BUILD}"
