inherit ada-sources

DEPENDS += "virtual/gnat1"

GNAT_INSTALL_LOCATION = "/usr/bin/${ADA_COMMUNITY}"
SYSROOT_PATH = "${RECIPE_SYSROOT_NATIVE}${GNAT_INSTALL_LOCATION}"

PATH:prepend = "${SYSROOT_PATH}/bin:"

EXTRA_OECONF_PATHS:remove = "--with-build-sysroot=${STAGING_DIR_TARGET}"
EXTRA_OECONF_PATHS:append = " --with-build-sysroot=${SYSROOT_PATH}"

export GNATBIND="gnatbind"
export GNATLINK="gnatlink"
export GNATMAKE="gnatmake"

ADA_CFLAGS += "-I${SYSROOT_PATH}/usr/include"
ADA_CFLAGS += "-I${SYSROOT_PATH}/include"
ADA_CFLAGS += "-I${RECIPE_SYSROOT}/usr/include"

ADA_FOR_BUILD = "-L${SYSROOT_PATH}/usr/lib -L${SYSROOT_PATH}/usr/lib64"

TARGET_CFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CXXFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CPPFLAGS:append = " ${ADA_CFLAGS}"

TARGET_LDFLAGS:append = " ${ADA_FOR_BUILD}"

ADA_CFLAGS += "-B${SYSROOT_PATH}/usr/lib"
ADA_CFLAGS += "-B${SYSROOT_PATH}/usr/lib64"

export EXTRA_XGCC_FLAGS="${ADA_CFLAGS}"

do_compile:prepend() {
    # Remove empty limit.h file so that the glibc version
    # from alire-gnat-native (glibc-headers.bbclass) gets
    # utilized during compilation
    rm -f ${RECIPE_SYSROOT}/usr/include/limits.h || ret=$?

}

# It appears multiple gcc recipes utilize
# the same build directory. After building remove
# any reference to ${GNAT_INSTALL_LOCATION} so that
# future builds don't incorporate paths that were only
# meant for gcc-cross & gcc-crosssdk.
do_gcc_stash_builddir() {
    dest=${BUILDDIRSTASH}

    grep -rlnIE "${GNAT_INSTALL_LOCATION}" * | \
    xargs sed -i 's@${GNAT_INSTALL_LOCATION}@@g' || ret=$?

    hardlinkdir . $dest
    # Makefile does move-if-change which can end up with
    # 'timestamp' as file contents so break links to those files
    rm $dest/gcc/include/*.h

    cp gcc/include/*.h $dest/gcc/include/
    sysroot-relativelinks.py $dest
}
