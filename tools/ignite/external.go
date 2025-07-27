package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"

	"rlxos.dev/pkg/ensure"
)

type External struct {
	Provides string   `json:"provides"`
	Depends  []string `json:"depends"`
	Sources  []string `json:"sources"`
	Script   []string `json:"script"`
}

func LoadExternal(p string) (External, error) {
	data, err := os.ReadFile(p)
	if err != nil {
		return External{}, fmt.Errorf("LoadExternal %v %v", p, err)
	}
	data = []byte(os.ExpandEnv(string(data)))

	var ext External
	if err := json.Unmarshal(data, &ext); err != nil {
		return External{}, fmt.Errorf("LoadExternal %v %v", p, err)
	}

	return ext, nil
}

func (e External) Build() error {
	for _, url := range e.Sources {
		sourceFile := filepath.Join(sourcesPath, filepath.Base(url))
		if err := ensure.Target(sourceFile, ensure.Cmd(
			"wget", "-nc", url, "-O", sourceFile,
		)); err != nil {
			return err
		}

		if isArchive(sourceFile) {
			target := filepath.Join(buildPath, "."+filepath.Base(sourceFile))
			if err := ensure.Target(target, func() error {
				if err := ensure.Cmd("tar", "-xmf", sourceFile, "-C", buildPath)(); err != nil {
					return err
				}
				return os.WriteFile(target, []byte(""), 0644)
			}); err != nil {
				return err
			}
		}
	}

	extSourcePath := filepath.Join(buildPath, e.getSourceDir())
	for i, s := range e.Script {
		log.Println(extSourcePath, s)
		cmd := exec.Command("sh", "-e", "-c", s)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin
		cmd.Dir = extSourcePath

		if err := cmd.Run(); err != nil {
			return fmt.Errorf("%d failed %v", i, err)
		}
	}

	return nil
}

func (e External) getSourceDir() string {
	if len(e.Sources) <= 0 {
		return ""
	}
	sourceFile := filepath.Join(sourcesPath, filepath.Base(e.Sources[0]))
	output, err := exec.Command("tar", "-tf", sourceFile).CombinedOutput()
	if err != nil {
		return ""
	}
	p := strings.Split(string(output), "\n")
	if len(p) >= 1 {
		if idx := strings.Index(p[0], "/"); idx != -1 {
			return p[0][:idx]
		}
		return p[0]
	}
	return ""
}

func isArchive(f string) bool {
	return slices.Contains([]string{
		".tar", ".xz", ".gz", ".tgz", ".bzip2", ".zip", ".zst",
	}, filepath.Ext(f))
}

func Sort(externals []External, targets []string) ([]External, error) {
	provideToIndex := make(map[string]int)
	for i, ext := range externals {
		if _, exists := provideToIndex[ext.Provides]; exists {
			return nil, fmt.Errorf("duplicate provide: %s", ext.Provides)
		}
		provideToIndex[ext.Provides] = i
	}

	visited := make(map[int]bool)
	tempMark := make(map[int]bool)
	var result []int

	var visit func(int) error
	visit = func(i int) error {
		if visited[i] {
			return nil
		}
		if tempMark[i] {
			return errors.New("cyclic dependency detected")
		}
		tempMark[i] = true

		for _, dep := range externals[i].Depends {
			providerIdx, ok := provideToIndex[dep]
			if !ok {
				return fmt.Errorf("missing provider for dependency: %s", dep)
			}
			if err := visit(providerIdx); err != nil {
				return err
			}
		}

		visited[i] = true
		tempMark[i] = false
		result = append(result, i)
		return nil
	}

	seen := make(map[int]bool)
	for _, target := range targets {
		idx, ok := provideToIndex[target]
		if !ok {
			return nil, fmt.Errorf("no provider found for target: %s", target)
		}
		if !seen[idx] {
			if err := visit(idx); err != nil {
				return nil, err
			}
			seen[idx] = true
		}
	}

	sorted := make([]External, 0, len(result))
	added := make(map[int]bool)
	for _, i := range result {
		if !added[i] {
			sorted = append(sorted, externals[i])
			added[i] = true
		}
	}
	return sorted, nil
}
