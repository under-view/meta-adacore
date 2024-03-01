SUMMARY = "Adacore community gnat compiler and tools"
HOMEPAGE = "https://www.adacore.com"
LICENSE = "CLOSED"
SECTION = "utils/devel"

inherit ada-sources glibc-headers native

DEPENDS = ""
RDEPENDS:${PN} = ""

PROVIDES += "virtual/gprbuild1"
PROVIDES += "virtual/gnat1"

INHIBIT_DEFAULT_DEPS = "1"

GNATC_NAME = "gnat-${PV}-${TARGET_ARCH}"
GNATC_DOWNLOAD_FNAME ?= "${GNATC_NAME}-linux-bin"

GNATC_DOWNLOAD_HASH ?= "f3a99d283f7b3d07293b2e1d07de00e31e332325"
GNATC_DOWNLOAD_SRC = "${ADACORE_COMMUNITY}/v1/${GNATC_DOWNLOAD_HASH}?filename=${GNATC_DOWNLOAD_FNAME}"
GNATC_INSTALL_SCRIPT = "git://git@github.com/AdaCore/gnat_community_install_script.git"

SRCREV_FORMAT .= "_${GNATC}"
SRCREV_FORMAT .= "_${GNATC}-bin"

SRC_URI = "\
    ${GNATC_INSTALL_SCRIPT};protocol=https;branch=master;name=${GNATC};subdir=${GNATC} \
    ${GNATC_DOWNLOAD_SRC};name=${GNATC}-bin;downloadfilename=${GNATC_NAME} \
    "

SRCREV_gnat-community ?= "f74ecb07969938978c32a666b4c58790f3cf2e7d"
SRC_URI[gnat-community-bin.sha256sum] ?= "5fc98a8eea7232ae2170266875d537c1707adc827b4a1bd0893b805414f40837"

PATH:prepend = "${WORKDIR}/${GNATC_NAME}/bin:"

do_install() {
    final_install_dir=${D}/${bindir}/${GNATC}
    install -d ${WORKDIR}/${GNATC}-extract ${final_install_dir}

    cd ${WORKDIR}/${GNATC}

    ./install_package.sh \
        ${WORKDIR}/${GNATC_NAME} \
        ${WORKDIR}/${GNATC}-extract \
        com.adacore,com.adacore.gnat || ret=$?

    make -C ${WORKDIR}/${GNATC}-extract ins-all prefix=${final_install_dir}

    find ${final_install_dir} -name ld -exec mv -v {} {}.old \; || ret=$?
    find ${final_install_dir} -name as -exec mv -v {} {}.old \; || ret=$?

    rm -rf ${WORKDIR}/${GNATC}-extract
    do_install_glibc_headers ${final_install_dir}
}

PACKAGES = "${PN}"
INSANE_SKIP:${PN} += "already-stripped"
