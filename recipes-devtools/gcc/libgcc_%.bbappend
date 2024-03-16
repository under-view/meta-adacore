# May not be the best work around. Ensure sysroot for
# libgcc & nativesdk-libgcc recipes can be re-populated.

COMPILERDEP:append:class-nativesdk = " glibc:do_populate_sysroot"

do_wipe_sysroot() {
    find ${RECIPE_SYSROOT} \
        -not -name 'sysroot-providers' \
        -not -name 'recipe-sysroot' \
        -exec rm -rf {} \; || ret=$?

    rm -rf ${COMPONENTS_DIR}/${PACKAGE_ARCH}/${BPN}
    rm -rf ${COMPONENTS_DIR}/${TARGET_SYS}/${BPN}
    rm -rf ${COMPONENTS_DIR}/${SDK_ARCH}-nativesdk/nativesdk-${BPN}
}

do_populate_sysroot:prepend() {
    bb.build.exec_func("do_wipe_sysroot", d)
}
