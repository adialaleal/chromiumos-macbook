# Copyright (c) 2026 ChromiumOS Apple MacBook Project. All rights reserved.
# Distributed under the terms of the BSD License.

EAPI=7

inherit eutils systemd

DESCRIPTION="Hardware configuration, keymappings, and backlight controls for Apple MacBooks"
HOMEPAGE="https://github.com/macbook-chromiumos/overlay-macbook"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/systemd
	media-libs/alsa-lib"

S="${WORKDIR}"

src_install() {
	# Install systemd hwdb rules
	insinto /lib/udev/hwdb.d
	newins "${FILESDIR}/60-macbook-keyboard.hwdb" 60-macbook-keyboard.hwdb

	# Install udev permissions rules
	insinto /lib/udev/rules.d
	newins "${FILESDIR}/90-macbook-keys.rules" 90-macbook-keys.rules

	# Install keyboard backlight script
	exeinto /usr/bin
	doexe "${FILESDIR}/macbook-backlight.sh"

	# Install systemd service
	systemd_dounit "${FILESDIR}/macbook-backlight.service"
}

pkg_postinst() {
	ebegin "Updating systemd udev hwdb database..."
	systemd-hwdb update || true
	eend $?
}
