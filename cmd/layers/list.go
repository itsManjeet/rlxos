package main

import (
	"bufio"
	"fmt"
	"os"
	"rlxos/internal/utils"
	"strings"
)

type Layer struct {
	Id       string
	Disabled bool
	Active   bool
}

const (
	LAYERS_PATH = "/var/lib/layers/"
)

func List() ([]Layer, bool, bool, error) {
	var l []Layer
	iter, err := os.ReadDir(LAYERS_PATH)
	if err != nil {
		return nil, false, false, fmt.Errorf("failed to read layers path '%s': %v", LAYERS_PATH, err)
	}

	activeLayers, err := getActiveLayers()
	if err != nil {
		return nil, false, false, fmt.Errorf("failed to get active layers: %v", err)
	}

	writable := false

	for _, p := range iter {
		if !p.IsDir() && utils.Contains([]string{".rw", ".work"}, p.Name()) {
			if p.Name() == ".rw" {
				writable = true
			}
			continue
		}

		l = append(l, Layer{
			Id:       p.Name(),
			Disabled: false,
			Active:   utils.Contains(activeLayers, p.Name()),
		})
	}

	return l, len(activeLayers) != 0, writable, nil
}

func getActiveLayers() ([]string, error) {
	file, err := os.Open("/proc/mounts")
	if err != nil {
		return nil, fmt.Errorf("failed to read mount info: %v", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		data := strings.Split(scanner.Text(), " ")
		if len(data) != 6 {
			continue
		}

		// Check for Target = "/usr" and Source = "overlay"
		if data[0] == "overlay" && data[1] == "/usr" {
			options := strings.Split(data[3], ",")
			for _, opt := range options {
				if strings.HasPrefix(opt, "lowerdir=") {
					return strings.Split(opt[9:], ":"), nil
				}
			}
		}
	}
	return []string{}, nil
}
