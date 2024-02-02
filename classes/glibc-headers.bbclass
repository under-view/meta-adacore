DEPENDS:append = " bison-native linux-libc-headers"

SRCBRANCH ?= "release/2.38/master"
GLIBC_GIT_URI ?= "git://sourceware.org/git/glibc.git;protocol=https"
GLIBC_DIR = "glibc"

SRCREV_FORMAT .= "_${GLIBC_DIR}"

SRC_URI:append = "\
    ${GLIBC_GIT_URI};branch=${SRCBRANCH};name=${GLIBC_DIR};subdir=${GLIBC_DIR} \
    "

SRCREV_glibc ?= "1e04dcec491bd8f48b5b74ce3e8414132578a645"

do_install_glibc_headers() {
    final_install_dir=$1
    glibc_build_dir=${WORKDIR}/${GLIBC_DIR}/${GLIBC_DIR}-build

    mkdir -p ${glibc_build_dir}

    # To support NPTL
    # See: https://man7.org/linux/man-pages/man7/nptl.7.html
    echo "libc_cv_forced_unwind=yes"     > ${glibc_build_dir}/config.cache
    echo "libc_cv_c_cleanup=yes"        >> ${glibc_build_dir}/config.cache
    echo "libc_cv_mlong_double_128=yes" >> ${glibc_build_dir}/config.cache
    echo "libc_cv_alpha_tls=yes"        >> ${glibc_build_dir}/config.cache

    cd ${glibc_build_dir}
    ../configure --prefix=${final_install_dir} \
                 --host=${TARGET_SYS} \
                 --build=${HOST_SYS} \
                 --disable-sanity-checks \
                 --enable-kernel=${OLDEST_KERNEL} \
                 --with-headers=${RECIPE_SYSROOT}/usr/include \
                 --cache-file=${glibc_build_dir}/config.cache \

    oe_runmake install-headers
}

