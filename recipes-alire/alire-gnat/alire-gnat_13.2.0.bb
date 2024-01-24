SUMMARY = "The GNAT Ada compiler - Native"
HOMEPAGE = "https://github.com/alire-project/GNAT-FSF-builds/releases/"
LICENSE = "CLOSED"

SECTION = "utils/devel"

DEPENDS = ""
RDEPENDS:${PN} = ""

inherit ada-sources

PR = "1"

GNATC_FNAME = "gnat-x86_64-linux-${PV}-${PR}"

GNATC_DOWNLOAD_FNAME ?= "${GNATC_FNAME}.tar.gz"
GNATC_DOWNLOAD_SRC = "${ALIRE_GNAT_FSF}/releases/download/gnat-${PV}-${PR}"

SRCREV_FORMAT .= "_${ALIREC}-tarball"
SRC_URI = "${GNATC_DOWNLOAD_SRC}/${GNATC_DOWNLOAD_FNAME};name=${ALIREC}-tarball;downloadfilename=${GNATC_FNAME}"

SRC_URI[alire-community-tarball.sha256sum] = "788a01f91f54259a6a9fb44f0c1f36b83cbf0ef06a8e6a9c601a4c46581a07a8"

do_install() {
    install -d ${D}/${bindir}/${ALIREC}
    tar xf ${WORKDIR}/${GNATC_FNAME} -C ${WORKDIR}
    cp -a ${WORKDIR}/${GNATC_FNAME}/* ${D}/${bindir}/${ALIREC}
}

PACKAGES = "${BPN}"
INSANE_SKIP:${PN} += "already-skipped"
BBCLASSEXTEND = "native"
