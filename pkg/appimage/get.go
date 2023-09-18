package appimage

import (
	"os"
	"os/exec"
	"path"
)

func getFile(appfile, filepath string) ([]byte, error) {
	stat, err := os.Stat(appfile)
	if err != nil {
		return nil, err
	}

	// If AppImage is executable by all
	if stat.Mode()&0111 != 0111 {
		if err := os.Chmod(appfile, 0755); err != nil {
			return nil, err
		}
	}

	tmpdir, err := os.MkdirTemp(os.TempDir(), "appimage-*")
	if err != nil {
		return nil, err
	}
	defer os.RemoveAll(tmpdir)

	cmd := exec.Command(appfile, "--appimage-extract", filepath)
	cmd.Dir = tmpdir

	if err := cmd.Run(); err != nil {
		return nil, err
	}

	data, err := os.ReadFile(path.Join(tmpdir, "squashfs-root", filepath))
	if err != nil {
		return nil, err
	}

	return data, nil
}
