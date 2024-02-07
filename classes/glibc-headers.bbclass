DEPENDS:append = " bison-native linux-libc-headers"

SRCBRANCH ?= "release/2.37/master"
GLIBC_GIT_URI ?= "git://sourceware.org/git/glibc.git;protocol=https"
GLIBC_DIR = "glibc"

SRCREV_FORMAT .= "_${GLIBC_DIR}"

SRC_URI:append = "\
    ${GLIBC_GIT_URI};branch=${SRCBRANCH};name=${GLIBC_DIR};subdir=${GLIBC_DIR} \
    "

SRCREV_glibc ?= "8b849f70b397bae04ddad20ace07561103a8260a"

EXTRA_OECONF = "--enable-kernel=${OLDEST_KERNEL} \
                --disable-profile \
                --disable-debug --without-gd \
                --enable-clocale=gnu \
                --with-headers=${STAGING_INCDIR} \
                --without-selinux \
                --enable-bind-now \
                --enable-stack-protector=strong \
                --disable-crypt \
                --with-default-link \
                --disable-werror \
                --enable-fortify-source \
                ${@bb.utils.contains_any('SELECTED_OPTIMIZATION', '-O0 -Og', '--disable-werror', '', d)} \
                --host=${TARGET_SYS} \
                --build=${HOST_SYS} \
                --enable-kernel=${OLDEST_KERNEL} \
                --with-headers=${RECIPE_SYSROOT}/usr/include \
                "

do_install_glibc_headers() {
    final_install_dir=$1
    glibc_build_dir=${WORKDIR}/${GLIBC_DIR}/${GLIBC_DIR}-build

    mkdir -p ${glibc_build_dir}
    mkdir -p ${final_install_dir}/usr/include

    # To support NPTL
    # See: https://man7.org/linux/man-pages/man7/nptl.7.html
    echo "libc_cv_forced_unwind=yes"     > ${glibc_build_dir}/config.cache
    echo "libc_cv_c_cleanup=yes"        >> ${glibc_build_dir}/config.cache
    echo "libc_cv_mlong_double_128=yes" >> ${glibc_build_dir}/config.cache
    echo "libc_cv_alpha_tls=yes"        >> ${glibc_build_dir}/config.cache

    cd ${glibc_build_dir}
    ../configure ${EXTRA_OECONF} \
                 --prefix=${final_install_dir} \
                 --cache-file=${glibc_build_dir}/config.cache

    oe_runmake
    oe_runmake install
    oe_runmake install-headers
}

