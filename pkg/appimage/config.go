package appimage

import (
	"strings"
)

func readConfig(filepath string) (map[string]string, error) {
	data, err := getFile(filepath, "info")
	if err != nil {
		return nil, err
	}
	config := map[string]string{}

	for _, line := range strings.Split(string(data), "\n") {
		line = strings.Trim(line, " \n")
		idx := strings.Index(line, ":")
		if idx == -1 {
			continue
		}
		config[strings.Trim(line[:idx], " ")] = strings.Trim(line[idx+1:], " ")
	}

	return config, nil
}
