inherit gnat

require recipes-devtools/gcc/ada-common.inc
require recipes-devtools/gcc/ada-target.inc

SYSROOT_PATH = "gcc-nativesdk"

DEPENDS += "gmp mpfr libmpc"
