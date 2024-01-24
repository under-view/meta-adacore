SUMMARY = "Adacore community gnat compiler and tools"
HOMEPAGE = "https://www.adacore.com"
LICENSE = "CLOSED"
SECTION = "libs"

DEPENDS = ""
RDEPENDS = ""

GNATC = "gnat-community"
GNATC_FNAME ?= "gnat-${PV}-${TARGET_ARCH}-linux-bin"

GNATC_DOWNLOAD_HASH ?= "f3a99d283f7b3d07293b2e1d07de00e31e332325"
GNATC_DOWNLOAD_SRC = "https://community.download.adacore.com/v1/${GNATC_DOWNLOAD_HASH}?filename=gnat-${PV}-${TARGET_ARCH}-linux-bin"
GNATC_INSTALL_SCRIPT = "git://git@github.com/AdaCore/gnat_community_install_script.git"

SRCREV_FORMAT .= "_${GNATC}"
SRCREV_FORMAT .= "_${GNATC}-bin"

SRC_URI = "\
    ${GNATC_INSTALL_SCRIPT};protocol=https;branch=master;name=${GNATC};subdir=${GNATC} \
    ${GNATC_DOWNLOAD_SRC};name=${GNATC}-bin;downloadfilename=${GNATC_FNAME} \
    "

SRCREV_gnat-community = "f74ecb07969938978c32a666b4c58790f3cf2e7d"
SRC_URI[gnat-community-bin.sha256sum] = "5fc98a8eea7232ae2170266875d537c1707adc827b4a1bd0893b805414f40837"

# Core Install
do_install() {
    final_install_dir=${D}/${bindir}/${GNATC}
    install -d ${WORKDIR}/${GNATC}-extract ${final_install_dir}

    cd ${WORKDIR}/${GNATC}

    ./install_package.sh \
        ${WORKDIR}/${GNATC_FNAME} \
        ${WORKDIR}/${GNATC}-extract \
        com.adacore,com.adacore.gnat || ret=$?

    make -C ${WORKDIR}/${GNATC}-extract ins-all prefix=${final_install_dir}

    find ${final_install_dir} -name ld -exec mv -v {} {}.old \; || ret=$?
    find ${final_install_dir} -name as -exec mv -v {} {}.old \; || ret=$?

    rm -rf ${WORKDIR}/${GNATC}-extract
}

PACKAGES = "${PN}"
INSANE_SKIP:${PN} += "already-stripped"

BBCLASSEXTEND = "native"
