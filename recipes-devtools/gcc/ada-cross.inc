inherit ada-sources

DEPENDS += "virtual/gnat1"

GNAT_INSTALL_LOCATION = "/usr/bin/${ADA_COMMUNITY}"
SYSROOT_PATH = "${RECIPE_SYSROOT_NATIVE}${GNAT_INSTALL_LOCATION}"

PATH:prepend = "${SYSROOT_PATH}/bin:"

EXTRA_OECONF_PATHS:remove = "--with-build-sysroot=${STAGING_DIR_TARGET}"
EXTRA_OECONF_PATHS:append = " --with-build-sysroot=${SYSROOT_PATH}"

ADA_CFLAGS += "-I${SYSROOT_PATH}/usr/include"
ADA_CFLAGS += "-I${SYSROOT_PATH}/include"
ADA_CFLAGS += "-I${RECIPE_SYSROOT}/usr/include"

ADA_FOR_BUILD = "-L${SYSROOT_PATH}/usr/lib -L${SYSROOT_PATH}/usr/lib64"

TARGET_CFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CXXFLAGS:append = " ${ADA_CFLAGS}"
TARGET_CPPFLAGS:append = " ${ADA_CFLAGS}"

TARGET_LDFLAGS:append = " ${ADA_FOR_BUILD}"

BFLAGS += "-B${SYSROOT_PATH}/usr/lib"
BFLAGS += "-B${SYSROOT_PATH}/usr/lib64"

ADA_CFLAGS += "${BFLAGS}"

export EXTRA_XGCC_FLAGS="${ADA_CFLAGS}"

export GNATBIND="gnatbind"
export GNATLINK="gnatlink --sysroot=${SYSROOT_PATH} ${BFLAGS} ${TARGET_LDFLAGS}"
export GNATMAKE="gnatmake"

export ADA_INCLUDE_PATH="${SYSROOT_PATH}/lib/gcc/x86_64-pc-linux-gnu/${PV}/adainclude"
export ADA_OBJECTS_PATH="${SYSROOT_PATH}/lib/gcc/x86_64-pc-linux-gnu/${PV}/adalib"

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
