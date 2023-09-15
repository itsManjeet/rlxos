package osinfo

import (
	"reflect"
	"testing"
)

func TestGetMounts(t *testing.T) {
	mounts, err := GetMounts("mtab")
	if err != nil {
		t.Fatal(err)
	}

	expectedMountInfo := []MountInfo{
		{
			Source:  "sysfs",
			Target:  "/sys",
			Type:    "sysfs",
			Options: []string{"rw", "nosuid", "nodev", "noexec", "relatime"},
		},
		{
			Source:  "proc",
			Target:  "/proc",
			Type:    "proc",
			Options: []string{"rw", "relatime", "hidepid=invisible"},
		},
		{
			Source:  "devpts",
			Target:  "/dev/pts",
			Type:    "devpts",
			Options: []string{"rw", "nosuid", "noexec", "relatime", "gid=5", "mode=620", "ptmxmode=000"},
		},
	}

	if !reflect.DeepEqual(mounts, expectedMountInfo) {
		t.Fatalf("%v != %v", mounts, expectedMountInfo)
	}
}
