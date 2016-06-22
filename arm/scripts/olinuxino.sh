#!/usr/bin/env zsh
#
# Copyright (c) 2016 Dyne.org Foundation
# ARM SDK is written and maintained by parazyd <parazyd@dyne.org>
#
# This file is part of ARM SDK
#
# This source code is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this source code. If not, see <http://www.gnu.org/licenses/>.
#
# ARM SDK build script for Olimex Olinuxino devices (armhf)

# -- settings --
device_name="olinuxino"
arch="armhf"
size=1337
extra_packages=()
# Ones below should not need changing
parted_boot=(fat32 2048s 264191s)
parted_root=(ext4 264192s 100%)
inittab="T1:12345:respawn:/sbin/agetty -L ttyS0 115200 vt100"
custmodules=(sunxi_emac)
# source common commands
workdir="$R/arm/${device_name}-build"
strapdir="${workdir}/${os}-${arch}"
source $common
image_name="${os}_${release}_${version}_${arch}_${device_name}"
# -- end settings --


${device_name}-build-kernel() {
	fn ${device_name}-build-kernel

	notice "Grabbing kernel sources"

	cd ${workdir}
	git clone --depth 1 https://github.com/linux-sunxi/u-boot-sunxi
	git clone --depth 1 https://github.com/linux-sunxi/sunxi-tools
	git clone --depth 1 https://github.com/linux-sunxi/sunxi-boards
	sudo mkdir ${strapdir}/usr/src/kernel && sudo chown $USER ${strapdir}/usr/src/kernel
	git clone --depth 1 https://github.com/linux-sunxi/linux-sunxi -b stage/sunxi-3.4 ${strapdir}/usr/src/kernel

	cd ${workdir}/sunxi-tools
	make fex2bin
	sudo ./fex2bin ${workdir}/sunxi-boards/sys_config/a10/a10-olinuxino-lime.fex ${workdir}/bootp/script.bin

	copy-kernel-config

	make -j `grep -c processor /proc/cpuinfo` uImage modules
	make-kernel-modules

	sudo rm -r ${strapdir}/lib/firmware
	sudo chown $USER ${strapdir}/lib
	get-kernel-firmware
	cp -ra $R/tmp/firmware ${strapdir}/lib/firmware

	cd $strapdir/usr/src/kernel

	make INSTALL_MOD_PATH=${strapdir} firmware_install
	sudo cp -v arch/arm/boot/uImage ${workdir}/bootp/
	make mrproper

	cp -v ../${device_name}.config .config
	make modules_prepare

	notice "Building u-boot..."
	cd ${workdir}/u-boot-sunxi/
	make distclean
	make A10-OLinuXino-Lime_config
	make -j $(grep -c processor /proc/cpuinfo)
	notice "dd-ing to image..."
	sudo $DD if=u-boot-sunxi-with-spl.bin of=$loopdevice bs=1024 seek=8

	notice "Fixing up firmware..."
	rm -rf ${strapdir}/lib/firmware
	cp -ra $R/tmp/firmware ${strapdir}/lib/firmware

	notice "Creating boot.cmd..."
	cat <<EOF | sudo tee ${workdir}/bootp/boot.cmd
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10 ${extra} rw rootfstype=ext4 net.ifnames=0
fatload mmc 0 0x43000000 script.bin
fatload mmc 0 0x48000000 uImage
bootm 0x48000000
EOF

	notice "Creating u-boot script image..."
	sudo mkimage -A arm -T script -C none -d ${workdir}/bootp/boot.cmd ${workdir}/bootp/boot.scr

	notice "Finished building kernel"
	notice "Next step is: ${device_name}-finalize"
}
