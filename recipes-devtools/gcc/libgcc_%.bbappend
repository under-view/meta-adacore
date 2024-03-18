# May not be the best work around. Ensure sysroot for
# libgcc & nativesdk-libgcc can be re-populated.

COMPILERDEP:append:class-nativesdk = " glibc:do_populate_sysroot"

do_populate_sysroot[cleandirs] = "${@d.getVar('RECIPE_SYSROOT')}"
