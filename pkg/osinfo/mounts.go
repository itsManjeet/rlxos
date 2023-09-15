package osinfo

import (
	"fmt"
	"os"
	"strings"
)

type MountInfo struct {
	Source  string
	Target  string
	Type    string
	Options []string
}

func GetMounts(args ...string) ([]MountInfo, error) {
	mtab := "/proc/mounts"
	if len(args) == 1 {
		mtab = args[0]
	}

	data, err := os.ReadFile(mtab)
	if err != nil {
		return nil, fmt.Errorf("failed to read mtab info, %v", err)
	}

	mountInfo := []MountInfo{}

	for _, line := range strings.Split(string(data), "\n") {
		info := strings.Split(strings.Trim(line, " \n"), " ")
		if len(info) != 6 {
			continue
		}
		mountInfo = append(mountInfo, MountInfo{
			Source:  info[0],
			Target:  info[1],
			Type:    info[2],
			Options: strings.Split(info[3], ","),
		})
	}

	return mountInfo, nil
}
