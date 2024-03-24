do_compile:prepend() {

    # Copy over shared objects that only reside in RECIPE_SYSROOT_NATIVE at time of build
    # over to a location that is viewable during builds. So, that gcc builds.
    mkdir -p ${STAGING_LIBDIR}/${TARGET_SYS}/${BINV}/adalib
    cp ${STAGING_LIBDIR_NATIVE}/${TARGET_SYS}/gcc/${TARGET_SYS}/${BINV}/adalib/lib*.so* \
       ${STAGING_LIBDIR}/${TARGET_SYS}/${BINV}/adalib

}

do_install:append() {
    chown -R root:root ${D}/*
}

# At the moment unable to determine what causes
# libgnarl-13.so in package gnat doesn't have GNU_HASH (didn't pass LDFLAGS?)
# LDFLAGS (-Wl,--hash-style=gnu) gets passed via GNATLINK in gnat.bbclass and
# gets pass in LDFLAGS_FOR_TARGET during do_compile
INSANE_SKIP:gnat += "ldflags"

PACKAGES += "\
    gnat \
    gnat-dev \
    gnat-staticdev \
    gnat-symlinks \
    "

FILES:gnat = "\
    ${bindir}/${TARGET_PREFIX}gnat \
    ${bindir}/${TARGET_PREFIX}gnatbind \
    ${bindir}/${TARGET_PREFIX}gnatchop \
    ${bindir}/${TARGET_PREFIX}gnatclean \
    ${bindir}/${TARGET_PREFIX}gnatfind \
    ${bindir}/${TARGET_PREFIX}gnatkr \
    ${bindir}/${TARGET_PREFIX}gnatlink \
    ${bindir}/${TARGET_PREFIX}gnatls \
    ${bindir}/${TARGET_PREFIX}gnatmake \
    ${bindir}/${TARGET_PREFIX}gnatname \
    ${bindir}/${TARGET_PREFIX}gnatprep \
    ${bindir}/${TARGET_PREFIX}gnatxref \
    ${libexecdir}/gcc/${TARGET_SYS}/${BINV}/gnat1 \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/lib*${SOLIBS} \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/lib*-*${SOLIBSDEV} \
    "

FILES:gnat-dev = "\
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/*.ali \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adainclude/*.ad[sb] \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adainclude/*.h \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/libgnarl${SOLIBSDEV} \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/libgnat${SOLIBSDEV} \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/ada_target_properties \
    "

FILES:gnat-staticdev = "\
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/lib*.a \
    "

FILES:gnat-symlinks = "\
    ${bindir}/gnat \
    ${bindir}/gnatbind \
    ${bindir}/gnatchop \
    ${bindir}/gnatclean \
    ${bindir}/gnatfind \
    ${bindir}/gnatkr \
    ${bindir}/gnatlink \
    ${bindir}/gnatls \
    ${bindir}/gnatmake \
    ${bindir}/gnatname \
    ${bindir}/gnatprep \
    ${bindir}/gnatxref \
    "
