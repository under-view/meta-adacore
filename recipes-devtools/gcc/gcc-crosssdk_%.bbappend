require recipes-devtools/gcc/ada-common.inc
require recipes-devtools/gcc/ada-cross.inc

SYSTEMHEADERS:ada = "/usr/include"

ADA_CFLAGS += "-B${SYSROOT_PATH}/usr/lib"
ADA_CFLAGS += "-B${SYSROOT_PATH}/usr/lib64"

export EXTRA_XGCC_FLAGS="${ADA_CFLAGS}"
