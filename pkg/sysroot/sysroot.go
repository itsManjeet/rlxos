package sysroot

import (
	"fmt"
	"io/ioutil"
	"os"
	"path"
	"rlxos/pkg/osinfo"
	"sort"
	"strconv"
	"strings"
)

const (
	SYSTEM_IMAGES_PATH = "/sysroot/images"
)

type Sysroot struct {
	InUse  int
	Images []int
	config *Config
}

func Init(configfile string) (*Sysroot, error) {
	sysroot := &Sysroot{
		Images: []int{},
	}
	var err error
	sysroot.config, err = LoadConfig(configfile)
	if err != nil {
		return nil, fmt.Errorf("failed to read configuration file %s, %v", configfile, err)
	}

	images, err := ioutil.ReadDir(SYSTEM_IMAGES_PATH)
	if err != nil {
		return nil, fmt.Errorf("failed to read system images path, %v", err)
	}

	for _, image := range images {
		if !image.IsDir() {
			imageVersion, err := strconv.Atoi(image.Name())
			if err != nil {
				continue
			}
			sysroot.Images = append(sysroot.Images, imageVersion)
		}
	}

	sort.Slice(sysroot.Images, func(a, b int) bool {
		return sysroot.Images[a] > sysroot.Images[b]
	})

	mountInfo, err := osinfo.GetMounts()
	if err != nil {
		return nil, fmt.Errorf("failed to get mount info, %v", err)
	}

	for _, mount := range mountInfo {
		if mount.Target == "/usr" && mount.Type == "squashfs" {
			var imageVersionString string
			switch {
			case strings.HasPrefix(mount.Source, "/dev/loop"):
				loopid := path.Base(mount.Source)
				loopBackingFile := path.Join("/sys/class/block/", loopid, "/loop/backing_file")
				data, err := os.ReadFile(loopBackingFile)
				if err != nil {
					return nil, fmt.Errorf("mount device is loop %s, and failed to read loop device backing_file %s, %v", mount.Source, loopBackingFile, err)
				}
				imageVersionString = path.Base(strings.Trim(string(data), " \n"))
			case strings.HasPrefix(mount.Source, "LABEL=RLXOS_"):
				imageVersionString = strings.TrimPrefix(mount.Source, "LABEL=RLXOS_")
			case strings.HasPrefix(mount.Source, SYSTEM_IMAGES_PATH):
				imageVersionString = path.Base(mount.Source)
			}
			imageVersion, err := strconv.Atoi(imageVersionString)
			if err != nil {
				return nil, fmt.Errorf("failed to read system image version, must be integer but %s, %v", path.Base(mount.Source), err)
			}
			sysroot.InUse = imageVersion
			break
		}
	}
	return sysroot, nil
}
