SUMMARY = "Data collector for SHT31-D temperature and humidity reader"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
DEPENDS = 'mosquitto'

SRC_URI = "git://git@github.com/zokiobsi/aeld-final-project-app.git;protocol=ssh;branch=main"
PV = "1.0+git${SRCPV}"
SRCREV = "ebc1bb6d8ab0d3e0586bc15d7cda98eac4e99de1"
S = "${WORKDIR}/git/rdc/collector-app"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} collector.c -o collector -lmosquitto
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 collector ${D}${bindir}/collector
}