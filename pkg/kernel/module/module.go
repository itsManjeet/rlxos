package module

import (
	"debug/elf"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"syscall"
	"unsafe"
)

type Info struct {
	Name    string   `json:"name"`
	License string   `json:"license"`
	Aliases []string `json:"aliases"`
	Depends []string `json:"depends"`
	Path    string   `json:"path"`
}

func Parse(path string) (Info, error) {
	f, err := os.OpenFile(path, os.O_RDONLY, 0)
	if err != nil {
		return Info{}, err
	}
	defer f.Close()

	e, err := elf.NewFile(f)
	if err != nil {
		return Info{}, fmt.Errorf("elf.Parse %v", err)
	}
	defer e.Close()

	var sec *elf.Section
	for _, s := range e.Sections {
		if s.Name == ".modinfo" {
			sec = s
			break
		}
	}

	if sec == nil {
		return Info{}, fmt.Errorf(".modinfo not found")
	}

	d, err := sec.Data()
	if err != nil {
		return Info{}, fmt.Errorf(".modinfo.Data %v", err)
	}
	entries := strings.Split(string(d), "\x00")

	var m Info
	for _, en := range entries {
		if en == "" {
			continue
		}
		switch {
		case strings.HasPrefix(en, "license="):
			m.License = strings.TrimPrefix(en, "license=")
		case strings.HasPrefix(en, "alias="):
			m.Aliases = append(m.Aliases, strings.TrimPrefix(en, "alias="))
		case strings.HasPrefix(en, "depends="):
			deps := strings.TrimPrefix(en, "depends=")
			if deps != "" {
				m.Depends = strings.Split(deps, ",")
			}
		case strings.HasPrefix(en, "name="):
			m.Name = strings.TrimPrefix(en, "name=")
		}
	}

	m.Path = path
	return m, nil
}

func Insert(path string, options string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	p, _ := syscall.BytePtrFromString(options)

	if _, _, errno := syscall.Syscall(syscall.SYS_INIT_MODULE, uintptr(unsafe.Pointer(&data[0])), uintptr(len(data)), uintptr(unsafe.Pointer(p))); errno != 0 {
		return fmt.Errorf("syscall.INIT_MODULE %v", errno)
	}
	return nil
}

func Delete(name string, flags int) error {
	ptr, _ := syscall.BytePtrFromString(name)
	if _, _, errno := syscall.Syscall(syscall.SYS_DELETE_MODULE, uintptr(unsafe.Pointer(ptr)), uintptr(flags), 0); errno != 0 {
		return errno
	}
	return nil
}

func Load(path string, searchPath string, loaded map[string]bool) error {
	if !strings.HasPrefix(path, "/") {
		var err error
		path, err = Search(path, searchPath)
		if err != nil {
			return err
		}
	}

	if _, ok := loaded[path]; ok {
		return nil
	}

	info, err := Parse(path)
	if err != nil {
		return err
	}

	for _, dep := range info.Depends {
		if err := Load(dep, searchPath, loaded); err != nil {
			return err
		}
	}

	if err := Insert(path, ""); err != nil {
		return err
	}
	return nil
}

func Search(name string, searchPath string) (string, error) {
	var p string
	if err := filepath.Walk(searchPath, func(path string, info fs.FileInfo, err error) error {
		if err != nil || info.IsDir() || !strings.HasSuffix(path, ".ko") {
			return err
		}
		if filepath.Base(path) == name+".ko" {
			p = path
			return filepath.SkipAll
		}
		return nil
	}); err != nil {
		return "", err
	}

	if p == "" {
		return "", errors.New("not found")
	}
	return p, nil
}

func LoadCache(searchPath string) ([]Info, error) {
	data, err := os.ReadFile(filepath.Join(searchPath, "cache.json"))
	if err != nil {
		return nil, err
	}

	var is []Info
	if err := json.Unmarshal(data, &is); err != nil {
		return nil, err
	}
	return is, nil
}
