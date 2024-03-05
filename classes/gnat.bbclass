# Not utilized by gnat1 ada compiler so leads to warnings
TARGET_CFLAGS:remove = "-fmacro-prefix-map=${STAGING_DIR_HOST}="
TARGET_CFLAGS:remove = "-fmacro-prefix-map=${B}=${TARGET_DBGSRC_DIR}"
TARGET_CFLAGS:remove = "-fmacro-prefix-map=${S}=${TARGET_DBGSRC_DIR}"

GNATMAKE_COMMON_FLAGS = "--sysroot=${RECIPE_SYSROOT}"

GNATMAKE_CFLAGS = "${GNATMAKE_COMMON_FLAGS} ${TARGET_CFLAGS} -gnatpg -gnata -gnatU"

GNATMAKE_LDFLAGS = "${GNATMAKE_COMMON_FLAGS} ${TARGET_LDFLAGS}"
GNATMAKE_LDFLAGS += "-Wl,--allow-shlib-undefined -Wl,--dynamic-linker=${UNINATIVE_LOADER}"

# If GNATMAKE variable defined in Makefile
# use that instead of oe_run_gnatmake
export GNATGCC="${TARGET_PREFIX}gcc ${GNATMAKE_CFLAGS}"
export GNATBIND="${TARGET_PREFIX}gnatbind"
export GNATLINK="${TARGET_PREFIX}gnatlink ${GNATMAKE_LDFLAGS}"
export GNATMAKE="${TARGET_PREFIX}gnatmake"

oe_run_gnatmake() {
    ${GNATMAKE} \
        --GCC="${GNATGCC}" \
        --GNATBIND="${GNATBIND}" \
        --GNATLINK="${GNATLINK}" \
        $@
}
