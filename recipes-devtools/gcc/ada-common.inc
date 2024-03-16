ADA := ",ada"

LANGUAGES .= "${ADA}"

EXTRA_OECONF += "\
    --enable-libada \
    --enable-static=libada \
    "

SYSROOT_PATH ?= ""

do_compile () {
    # Prevent native/host sysroot path from being used in configargs.h header,
    # as it will be rewritten when used by other sysroots preventing support
    # for gcc plugins
    oe_runmake configure-gcc
    sed -i 's@${STAGING_DIR_TARGET}@/host@g' ${B}/gcc/configargs.h
    sed -i 's@${STAGING_DIR_HOST}@/host@g' ${B}/gcc/configargs.h

    # gcc-crosssdk requires appending extra flags to XGCC to get past
    # ${TARGET_SYS}-ld: cannot find crti.o: No such file or directory
    # ${TARGET_SYS}-ld: cannot find -ldl: No such file or directory
    # ${TARGET_SYS}-ld: cannot find -lm: No such file or directory
    # Libraries exists after classes/glibc-headers.bbclass finishes.
    # When compiling gnatlib-shared xgcc just can't locate them.
    sed -i \
    's@$(SYSROOT_CFLAGS_FOR_TARGET) $(DEBUG_PREFIX_CFLAGS_FOR_TARGET)@$(SYSROOT_CFLAGS_FOR_TARGET) $(EXTRA_XGCC_FLAGS)@g' \
    ${B}/Makefile

    if [ "${SYSROOT_PATH}" != "gcc-nativesdk" ]; then
        export CC="${BUILD_CC}"
        export AR_FOR_TARGET="${TARGET_SYS}-ar"
        export RANLIB_FOR_TARGET="${TARGET_SYS}-ranlib"
        export LD_FOR_TARGET="${TARGET_SYS}-ld ${TARGET_LDFLAGS}"
        export NM_FOR_TARGET="${TARGET_SYS}-nm"
        export CC_FOR_TARGET="${CCACHE} ${TARGET_SYS}-gcc"
        export CFLAGS_FOR_TARGET="${TARGET_CFLAGS}"
        export CPPFLAGS_FOR_TARGET="${TARGET_CPPFLAGS}"
        export CXXFLAGS_FOR_TARGET="${TARGET_CXXFLAGS}"
        export LDFLAGS_FOR_TARGET="${TARGET_LDFLAGS}"

        # Prevent sysroot/workdir paths from being used in checksum-options.
        # checksum-options is used to generate a checksum which is embedded into
        # the output binary.
        oe_runmake TARGET-gcc=checksum-options all-gcc
        sed -i 's@${DEBUG_PREFIX_MAP}@@g' ${B}/gcc/checksum-options
        sed -i 's@${STAGING_DIR_HOST}@/host@g' ${B}/gcc/checksum-options
    fi

    # Ensure ./config/i386/t-linux64 has $(srcdir) prepended
    # instead of ./ so when make goes to find path it can actually find it.
    grep -rlnIE "./config/i386/t-linux64" ${B}/gcc | \
    xargs sed -i 's@./config/i386/t-linux64@$(srcdir)/config/i386/t-linux64@g' || ret=$?

    oe_runmake all-host configure-target-libgcc
    (cd ${B}/${TARGET_SYS}/libgcc; oe_runmake enable-execute-stack.c unwind.h md-unwind-support.h sfp-machine.h gthr-default.h)
}

do_install:append() {

    # Run ensure required adalib,adainclude gets installed
    DESTDIR="${D}" oe_runmake -C "${B}" install-target-libada

    cd "${D}/${bindir}"

    if [ -e ${TARGET_PREFIX}gnat ]; then
        ln -sf ${TARGET_PREFIX}gnat gnat || true
    fi
    if [ -e ${TARGET_PREFIX}gnatbind ]; then
        ln -sf ${TARGET_PREFIX}gnatbind gnatbind || true
    fi
    if [ -e ${TARGET_PREFIX}gnatchop ]; then
        ln -sf ${TARGET_PREFIX}gnatchop gnatchop || true
    fi
    if [ -e ${TARGET_PREFIX}gnatclean ]; then
        ln -sf ${TARGET_PREFIX}gnatclean gnatclean || true
    fi
    if [ -e ${TARGET_PREFIX}gnatfind ]; then
        ln -sf ${TARGET_PREFIX}gnatfind gnatfind || true
    fi
    if [ -e ${TARGET_PREFIX}gnatkr ]; then
        ln -sf ${TARGET_PREFIX}gnatkr gnatkr || true
    fi
    if [ -e ${TARGET_PREFIX}gnatlink ]; then
        ln -sf ${TARGET_PREFIX}gnatlink gnatlink || true
    fi
    if [ -e ${TARGET_PREFIX}gnatls ]; then
        ln -sf ${TARGET_PREFIX}gnatls gnatls || true
    fi
    if [ -e ${TARGET_PREFIX}gnatmake ]; then
        ln -sf ${TARGET_PREFIX}gnatmake gnatmake || true
    fi
    if [ -e ${TARGET_PREFIX}gnatname ]; then
        ln -sf ${TARGET_PREFIX}gnatname gnatname || true
    fi
    if [ -e ${TARGET_PREFIX}gnatprep ]; then
        ln -sf ${TARGET_PREFIX}gnatprep gnatprep || true
    fi
    if [ -e ${TARGET_PREFIX}gnatxref ]; then
        ln -sf ${TARGET_PREFIX}gnatxref gnatxref || true
    fi
}
