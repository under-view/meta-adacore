# May not be the best work around. Ensure sysroot for
# libgcc & nativesdk-libgcc can be re-populated.

COMPILERDEP:append:class-nativesdk = " glibc:do_populate_sysroot"

do_wipe_sysroot() {
    find ${RECIPE_SYSROOT} \
        -not -name 'sysroot-providers' \
        -not -name 'recipe-sysroot' \
        -exec rm -rf {} \; || ret=$?
}

do_populate_sysroot:prepend() {
    bb.build.exec_func("do_wipe_sysroot", d)
}
