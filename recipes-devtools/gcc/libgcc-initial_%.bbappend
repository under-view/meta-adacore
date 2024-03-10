do_configure:prepend() {
    # Add empty limit.h file to bybass
    # native-libgcc-intial configure error
    touch ${RECIPE_SYSROOT}/usr/include/limits.h || ret=$?

}
