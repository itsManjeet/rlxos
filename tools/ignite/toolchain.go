/*
 * Copyright (c) 2025 Manjeet Singh <itsmanjeet1998@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package main

import (
	"path/filepath"

	"rlxos.dev/tools/ignite/ensure"
)

var (
	toolchainOptions = []string{
		"BR2_TOOLCHAIN_BUILDROOT_VENDOR=\"rlxos\"",
		"BR2_TOOLCHAIN_BUILDROOT_MUSL=y",
		"BR2_TOOLCHAIN_BUILDROOT_CXX=y",
		"BR2_GCC_ENABLE_GRAPHITE=y",
		"BR2_PACKAGE_HOST_GDB=y",
		"BR2_ENABLE_LTO=y",
		"BR2_SHARED_LIBS=y",
		"BR2_TARGET_GENERIC_PASSWD_SHA512=y",
		"BR2_INIT_NONE=y",
		"BR2_ROOTFS_SKELETON_CUSTOM=y",
		"BR2_ROOTFS_SKELETON_CUSTOM_PATH=\"$(RLXOS_PROJECT_PATH)/tools/ignite/skeleton\"",
		"BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV=y",
		"BR2_ROOTFS_DEVICE_TABLE_SUPPORTS_EXTENDED_ATTRIBUTES=y",
		"BR2_ROOTFS_MERGED_USR=y",
		"BR2_TARGET_TZ_INFO=y",
		"BR2_LINUX_KERNEL=y",
		"BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG=y",
		"BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=\"$(RLXOS_DEVICE_PATH)/kernel.conf\"",
		"BR2_LINUX_KERNEL_INSTALL_TARGET=y",
		"BR2_PACKAGE_BUSYBOX_CONFIG=\"$(RLXOS_PROJECT_PATH)/config/busybox.conf\"",
		"BR2_PACKAGE_SQUASHFS=y",
		"BR2_PACKAGE_CA_CERTIFICATES=y",
		"BR2_PACKAGE_SEATD_DAEMON=y",
		"BR2_PACKAGE_LIBGLVND=y",
		"BR2_PACKAGE_MESA3D=y",
		"BR2_PACKAGE_MESA3D_OSMESA_GALLIUM=y",
		"BR2_PACKAGE_MESA3D_OPENGL_ES=y",
		"BR2_PACKAGE_XKEYBOARD_CONFIG=y",
		"BR2_PACKAGE_WLROOTS=y",
		"BR2_PACKAGE_XORG7=y",
		"BR2_PACKAGE_XWAYLAND=y",
		"BR2_PACKAGE_WLROOTS_X11=y",
		"BR2_PACKAGE_WLROOTS_XWAYLAND=y",
		"BR2_PACKAGE_MESA3D_OPENGL_GLX=y",
		"BR2_PACKAGE_FOOT=y",
		"# BR2_TARGET_ROOTFS_TAR is not set",
		"BR2_TARGET_GRUB2=y",
		"BR2_TARGET_GRUB2_I386_PC=y",
		"BR2_TARGET_GRUB2_X86_64_EFI=y",
		"BR2_TARGET_GRUB2_INSTALL_TOOLS=y",
		"BR2_TARGET_SYSLINUX=y",
	}
)

func toolchain(args ...string) {
	ensure.RunAt(toolchainPath,
		append([]string{"make",
			"BR2_DEFCONFIG=" + defconfig,
			"BR2_EXTERNAL=" + filepath.Join(projectPath, "external"),
			"RLXOS_PROJECT_PATH=" + projectPath,
			"RLXOS_CACHE_PATH=" + cachePath,
			"RLXOS_DEVICE_PATH=" + filepath.Join(projectPath, "devices", devicePath),
			"RLXOS_DEVICE_CACHE_PATH=" + deviceCachePath,
			"BR2_DL_DIR=" + sourcesPath,
			"O=" + deviceCachePath,
		},
			args...)...,
	)
}
