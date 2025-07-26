package main

import (
	"encoding/json"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"rlxos.dev/pkg/kernel/module"
)

func cache(args []string) error {
	var is []module.Info
	if err := filepath.Walk(modulesPath, func(path string, info fs.FileInfo, err error) error {
		if err != nil || info.IsDir() || filepath.Ext(path) != ".ko" {
			return err
		}

		i, err := module.Parse(path)
		if err != nil {
			return nil
		}
		i.Path = strings.TrimPrefix(i.Path, root)
		is = append(is, i)
		return nil
	}); err != nil {
		return err
	}

	out, err := json.Marshal(is)
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(modulesPath, "cache.json"), out, 0644)
}
