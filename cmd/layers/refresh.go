package main

import (
	"fmt"
	"path"
	"syscall"
)

func Refresh() error {
	layers, active, writable, err := List()
	if err != nil {
		return err
	}

	rwPath := path.Join(LAYERS_PATH, ".rw")
	workPath := path.Join(LAYERS_PATH, ".work")

	flags := 0
	options := "lowerdir="
	for _, layer := range layers {
		if layer.Disabled {
			continue
		}
		options += layer.Id + ":"
	}
	options += "/usr"

	if writable {
		options += ",upperdir=" + rwPath + ",workdir=" + workPath
	} else {
		flags |= syscall.MS_RDONLY
	}

	if active {
		flags |= syscall.MS_REMOUNT
	}

	if err := syscall.Mount("overlay", "/usr", "overlay", uintptr(flags), options); err != nil {
		return fmt.Errorf("failed to mount overlay: %v", err)
	}

	return nil
}
