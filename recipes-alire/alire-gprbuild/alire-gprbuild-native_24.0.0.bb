SUMMARY = "The GNAT Ada compiler - Native"
HOMEPAGE = "https://github.com/alire-project/GNAT-FSF-builds/releases/"
LICENSE = "CLOSED"

SECTION = "utils/devel"

inherit ada-sources native

DEPENDS = ""
RDEPENDS:${PN} = ""

INHIBIT_DEFAULT_DEPS = "1"

PROVIDES += "virtual/gprbuild1"

PR = "1"

GPRBUILD_NAME = "gprbuild-x86_64-linux-${PV}-${PR}"

GPRBUILD_DOWNLOAD_FNAME ?= "${GPRBUILD_NAME}.tar.gz"
GPRBUILD_DOWNLOAD_SRC = "${ALIRE_GNAT_FSF}/releases/download/gprbuild-${PV}-${PR}"

SRCREV_FORMAT .= "_${ALIREC}-tarball"

SRC_URI = "\
    ${GPRBUILD_DOWNLOAD_SRC}/${GPRBUILD_DOWNLOAD_FNAME};name=${ALIREC}-tarball;downloadfilename=${GPRBUILD_DOWNLOAD_FNAME};unpack=0 \
    "

SRC_URI[alire-community-tarball.sha256sum] ?= "4bb020f375a90bdec348390c44e517af42d2724fb439b00c4738992c42a931c6"

do_install() {
    final_install_dir=${D}/${bindir}/${ALIREC}

    install -d ${final_install_dir}
    tar xf ${WORKDIR}/${GPRBUILD_DOWNLOAD_FNAME} -C ${WORKDIR}

    cd ${WORKDIR}/${GPRBUILD_NAME}
    ./doinstall ${final_install_dir}
}

PACKAGES = "${BPN}"
INSANE_SKIP:${PN} += "already-stripped"
