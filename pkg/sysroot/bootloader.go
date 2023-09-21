package sysroot

import (
	"os"
	"os/exec"
	"path"
)

func (s *Sysroot) UpdateBootloader(root string) error {
	cmd := exec.Command("grub-mkconfig", "-o", path.Join(root, "boot", "grub", "grub.cfg"))
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
