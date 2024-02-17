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
                --disable-debug \
                --without-gd \
                --enable-clocale=gnu \
                --with-headers=${STAGING_INCDIR} \
                --without-selinux \
                --enable-bind-now \
                --enable-stack-protector=strong \
                --disable-crypt \
                --with-default-link \
                --disable-werror \
                --enable-fortify-source \
                --enable-cet \
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
    mkdir -p ${final_install_dir}/include/gnu

    # To support NPTL
    # See: https://man7.org/linux/man-pages/man7/nptl.7.html
    echo "libc_cv_forced_unwind=yes"     > ${glibc_build_dir}/config.cache
    echo "libc_cv_c_cleanup=yes"        >> ${glibc_build_dir}/config.cache
    echo "libc_cv_mlong_double_128=yes" >> ${glibc_build_dir}/config.cache
    echo "libc_cv_alpha_tls=yes"        >> ${glibc_build_dir}/config.cache

    cd ${glibc_build_dir}
    ../configure ${EXTRA_OECONF} \
                 --prefix=/usr \
                 --cache-file=${glibc_build_dir}/config.cache

    oe_runmake \
    install-bootstrap-headers="yes" \
    install_root=${final_install_dir} \
    install-headers

    # To get the C Runtime Objects needed by programs to start
    # https://docs.oracle.com/cd/E88353_01/html/E37853/crti.o-7.html
    make csu/subdir_lib

    install ${glibc_build_dir}/csu/crt1.o \
            ${glibc_build_dir}/csu/crti.o \
            ${glibc_build_dir}/csu/crtn.o \
            ${glibc_build_dir}/csu/Scrt1.o \
            ${final_install_dir}/lib

    gcc \
        -nostdlib \
        -nostartfiles \
        -shared \
        -x c /dev/null \
        -o ${final_install_dir}/lib/libc.so

    touch ${final_install_dir}/include/gnu/stubs.h
}

