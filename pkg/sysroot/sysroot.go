package sysroot

import (
	"fmt"
	"io/ioutil"
	"path"
	"rlxos/pkg/osinfo"
	"sort"
	"strconv"
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

	images, err := ioutil.ReadDir("/rlxos/system/")
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
		return sysroot.Images[a] < sysroot.Images[b]
	})

	mountInfo, err := osinfo.GetMounts()
	if err != nil {
		return nil, fmt.Errorf("failed to get mount info, %v", err)
	}

	for _, mount := range mountInfo {
		if mount.Target == "/usr" && mount.Type == "squashfs" {
			imageVersion, err := strconv.Atoi(path.Base(mount.Source))
			if err != nil {
				return nil, fmt.Errorf("failed to read system image version, must be integer but %s, %v", path.Base(mount.Source), err)
			}
			sysroot.InUse = imageVersion
			break
		}
	}
	return sysroot, nil
}
