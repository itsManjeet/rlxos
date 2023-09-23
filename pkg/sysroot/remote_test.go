package sysroot

import (
	"reflect"
	"testing"
)

func TestParseRemoteReleases(t *testing.T) {
	s := &Sysroot{}

	outputVersions, err := s.ParseRemoteReleases(`046877f60fc7e0191cd0bfd2b0d4daa0c2c7d2c9bb7d063c19e0ff788820dcbe  x86_64/230922/sysroot.img`)
	if err != nil {
		t.Fatal(err)
	}

	expectedVersions := []int{230922}
	if !reflect.DeepEqual(outputVersions, expectedVersions) {
		t.Fatalf("%v != %v", outputVersions, expectedVersions)
	}
}

func TestListRemoteReleases(t *testing.T) {
	s := &Sysroot{
		config: &Config{
			Server:  "https://updates.rlxos.dev",
			Channel: "rolling",
		},
	}

	outputVersions, err := s.ListRemoteReleases()
	if err != nil {
		t.Fatal(err)
	}

	expectedVersions := []int{230922}
	if !reflect.DeepEqual(outputVersions, expectedVersions) {
		t.Fatalf("%v != %v", outputVersions, expectedVersions)
	}
}
