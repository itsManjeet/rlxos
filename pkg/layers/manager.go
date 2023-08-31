package layers

import (
	"fmt"
	"os/exec"
	"strings"
)

type Manager struct {
	ServerUrl  string
	SearchPath []string
	RootDir    string
	Layers     []Layer
}

func checkIsMounted() (bool, error) {
	_, isMounter, err := parseMountData()
	return isMounter, err
}

func parseMountData() ([]string, bool, error) {
	data, err := exec.Command("mount").CombinedOutput()
	if err != nil {
		return nil, false, fmt.Errorf("failed to read mount data %v", err)
	}

	for _, m := range strings.Split(string(data), "\n") {
		if strings.HasPrefix(m, "overlay on /usr type overlay") {
			parameters := strings.Split(strings.TrimPrefix(strings.TrimSuffix(strings.Trim(strings.TrimPrefix(m, "overlay on /usr type overlay"), " "), ")"), "("), ",")
			for _, p := range parameters {
				if strings.HasPrefix(p, "lowerdir=") {
					layers := strings.Split(strings.TrimPrefix(p, "lowerdir="), ":")
					layers = layers[1:] // skip /usr
					return layers, true, nil
				}
			}
		}
	}
	return nil, false, nil
}

func contains(lst []string, v string) bool {
	for _, i := range lst {
		if i == v {
			return true
		}
	}
	return false
}
