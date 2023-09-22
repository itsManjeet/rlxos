package appimage

import "testing"

func TestIntegrate(t *testing.T) {
	inputDesktopFile := `
Comment=Desktop File comment
Exec=/bin/binary arg1 arg2
Icon=icon.png
	`

	expectedDesktopFile := `
Comment=Desktop File comment
Exec=/apps/appimage.app arg1 arg2
Icon=icon.png
	`

	outputDesktopFile := patchDesktopFile(inputDesktopFile, "Exec=[^ ]*", "Exec=/apps/appimage.app")
	if expectedDesktopFile != outputDesktopFile {
		t.Fatalf("%s != %s", expectedDesktopFile, outputDesktopFile)
	}

}
