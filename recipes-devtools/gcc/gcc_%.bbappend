inherit gnat
require recipes-devtools/gcc/ada-common.inc

SYSROOT_PATH = "gcc-target"

PACKAGES += "\
    gnat \
    gnat-dev \
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
    "

FILES:gnat-dev = "\
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/*.ali \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adalib/lib*.a \
    ${gcclibdir}/${TARGET_SYS}/${BINV}/adainclude/*.ad[sb] \
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

do_configure:prepend() {
    # When building gcc that runs on target there are a number
    # of compiler flags set by OE that gnat1 doesn't support.
    # Leading to the object file being generated, but
    # x"$errors" = x fails because $errors is set to the gnat1
    # WARNING labels
    #
    # delete x"$errors" so that ada support for the gcc that
    # runs on target may be built.
    sed -i 's@test x\"\$errors\" = x && test -f conftest.\$ac_objext;@test -f conftest.\$ac_objext;@g' \
           ${S}/configure

    # Replace generic gnatmake with one the utilizities gcc
    # cross compiler with gnat support generated from the yocto project.
    # Can't make this sed command generic as there are targets in the
    # Makefile with the name gnatmake.
    sed -i \
        -e 's@gnatmake -q -g $(GEN_IL_FLAGS)@$(GNATMAKE) --GCC="$(CC)" --GNATLINK="$(GNATLINK)" --GNATBIND="$(GNATBIND)" -q -g $(GEN_IL_FLAGS)@g' \
        -e 's@gnatmake -q xsnamest@$(GNATMAKE) --GCC="$(CC)" --GNATLINK="$(GNATLINK)" --GNATBIND="$(GNATBIND)" -q xsnamest@g' \
        -e 's@gnatmake $(GEN_IL_INCLUDES) seinfo_tables.adb@$(GNATMAKE) --GCC="$(CC)" --GNATLINK="$(GNATLINK)" --GNATBIND="$(GNATBIND)" $(GEN_IL_INCLUDES) seinfo_tables.adb@g' \
        ${S}/gcc/ada/Make-generated.in

    sed -i \
        -e 's@gnatmake -q xoscons@$(GNATMAKE) --GCC="$(CC)" --GNATLINK="$(GNATLINK)" --GNATBIND="$(GNATBIND)" -q xoscons@g' \
        ${S}/gcc/ada/gcc-interface/Makefile.in

    sed -i \
        -e 's@CC=the.host.compiler.should.not.be.needed@CC=$(CC)@g' \
        ${S}/libada/Makefile.in

}
