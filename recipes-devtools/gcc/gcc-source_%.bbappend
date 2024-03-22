FILESEXTRAPATHS:prepend := "${THISDIR}/patches:"

SRC_URI:append:ada = "\
    file://2000-support-gnat-build.patch \
    "
