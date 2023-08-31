package osinfo

import (
	"os"
	"strings"
)

type OsInfo map[string]string

func Open(filepath string) (OsInfo, error) {
	data, err := os.ReadFile(filepath)
	if err != nil {
		return nil, err
	}
	o := OsInfo{}
	for _, line := range strings.Split(string(data), "\n") {
		line = strings.Trim(line, " \n")
		if len(line) == 0 || !strings.Contains(line, "=") {
			continue
		}
		key, value := strings.Split(line, "=")[0], strings.Trim(strings.Split(line, "=")[1], "\" ")
		o[key] = value
	}
	return o, nil
}
