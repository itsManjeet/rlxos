package ignite

import (
	"crypto/sha256"
	"fmt"
	"path"
	"rlxos/internal/element"
	"strings"
)

type BuildStatus int

const (
	BuildStatusWaiting BuildStatus = iota
	BuildStatusCached
)

func (b BuildStatus) String() string {
	switch b {
	case BuildStatusCached:
		return "CACHED"
	case BuildStatusWaiting:
		return "WAITING"
	}
	return "UNKNOWN"
}

type Pair struct {
	Path  string
	Value *element.Element
	State BuildStatus
}

type Shell struct {
	Environ []string `yaml:"environ"`
	Bind    []struct {
		Source   string `yaml:"source"`
		Target   string `yaml:"target"`
		ReadOnly bool   `yaml:"read-only"`
	} `yaml:"bind"`
}

type Ignite struct {
	Container      string            `yaml:"container"`
	ArtifactServer string            `yaml:"artifact-server"`
	Variables      map[string]string `yaml:"variables"`
	Environ        []string          `yaml:"environ"`
	BuildTools     []BuildTool       `yaml:"build-tools"`
	CachePath      string            `yaml:"cache-path"`
	Shell          Shell             `yaml:"shell"`
	Imports        []string          `yaml:"(@)"`

	projectPath string
	pool        map[string]*element.Element
}

type BuildTool struct {
	Id          string   `yaml:"id"`
	TargetFiles []string `yaml:"target-files"`
	Script      string   `yaml:"script"`
}

func (b *Ignite) Get(id string) (*element.Element, bool) {
	e, ok := b.pool[id]
	return e, ok
}

func (b *Ignite) CacheFile(e *element.Element) (string, error) {
	sum := fmt.Sprint(e)
	s := sha256.New()
	s.Write([]byte(sum))
	depends := e.GetDepends(element.DependencyRunTime)

	for _, dep := range depends {
		dep_e, ok := b.Get(dep)
		if !ok {
			return "", fmt.Errorf("missing required package %s", dep)
		}
		s.Write([]byte(fmt.Sprint(dep_e)))
	}

	value := s.Sum(nil)

	return path.Join(b.ArtifactDir(), fmt.Sprintf("%x", value)), nil
}

func resolveVariables(v string, variables map[string]string) string {
	for key, value := range variables {
		v = strings.ReplaceAll(v, "%{"+key+"}", value)
	}
	return v
}

func isUrl(url string) bool {
	for _, i := range []string{"http", "ftp"} {
		if strings.HasPrefix(url, i+"://") || strings.HasPrefix(url, i+"s://") {
			return true
		}
	}
	return false
}

func isArchive(p string) bool {
	for _, i := range []string{".tar", ".xz", ".gz", ".tgz", ".bzip2", ".zip", ".bz2", ".lz"} {
		if path.Ext(p) == i {
			return true
		}
	}
	return false
}
