GNATMAKE_COMMON_FLAGS = "--sysroot=${RECIPE_SYSROOT}"
GNATMAKE_CFLAGS = "${GNATMAKE_COMMON_FLAGS}"
GNATMAKE_LDFLAGS = "${GNATMAKE_COMMON_FLAGS} -L${STAGING_LIBDIR} -Wl,--hash-style=gnu"

oe_run_gnatmake() {
    ${TARGET_PREFIX}gnatmake \
        --GCC="${TARGET_PREFIX}gcc ${GNATMAKE_CFLAGS}" \
        --GNATBIND="${TARGET_PREFIX}gnatbind" \
        --GNATLINK="${TARGET_PREFIX}gnatlink ${GNATMAKE_LDFLAGS}" \
        $@
}
