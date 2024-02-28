require recipes-devtools/gcc/ada-common.inc
require recipes-devtools/gcc/ada-cross.inc

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
