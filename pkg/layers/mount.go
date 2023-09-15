package layers

import (
	"syscall"
)

func (m *Manager) Mount(target string, layers []Layer, remount bool) error {
	var flags uintptr = 0
	if remount {
		flags |= syscall.MS_REMOUNT
	}

	options := "lowerdir="
	for _, layer := range layers {
		options += layer.Path + ","
	}
	options += target

	return syscall.Mount("overlay", target, "overlay", flags, options)
}
