# Original https://github.com/Lucretia/meta-ada/blob/master/recipes-test/hello/hello.bb

DESCRIPTION = "Test Ada layer - Simple hello, world application in Ada"
SECTION = "examples"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = ""

PR = "r0"

SRC_URI = "\
    file://hello.adb \
    file://hello.gpr \
    "

S = "${WORKDIR}"

inherit gnat

do_compile() {
    oe_run_gnatmake ${S}/hello.adb
}

do_install() {
    install -d ${D}/${bindir}
    cp ${S}/hello ${D}/${bindir}/hello-ada
}

