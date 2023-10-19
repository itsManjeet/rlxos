package builder

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

type Builder struct {
	Container   string            `yaml:"container"`
	Variables   map[string]string `yaml:"variables"`
	Environ     []string          `yaml:"environ"`
	BuildTools  []BuildTool       `yaml:"build-tools"`
	Merge       []string          `yaml:"merge"`
	projectPath string
	cachePath   string
	pool        map[string]*element.Element
}

type BuildTool struct {
	Id          string   `yaml:"id"`
	TargetFiles []string `yaml:"target-files"`
	Script      string   `yaml:"script"`
}

func (b *Builder) Get(id string) (*element.Element, bool) {
	e, ok := b.pool[id]
	return e, ok
}

func (b *Builder) CachePath() string {
	return path.Join(b.cachePath, "cache")
}

func (b *Builder) CacheFile(e *element.Element) (string, error) {
	sum := fmt.Sprint(e)
	s := sha256.New()
	s.Write([]byte(sum))
	depends := e.AllDepends(element.DependencyRunTime)

	for _, dep := range depends {
		dep_e, ok := b.Get(dep)
		if !ok {
			return "", fmt.Errorf("missing required package %s", dep)
		}
		s.Write([]byte(fmt.Sprint(dep_e)))
	}

	value := s.Sum(nil)

	return path.Join(b.cachePath, "cache", fmt.Sprintf("%x", value)), nil
}

func (b *Builder) setEnv(environ []string, env string) []string {
	envVar := strings.Split(env, "=")[0]
	for i, e := range environ {
		if strings.HasPrefix(e, envVar+"=") {
			environ[i] = env
			return environ
		}
	}
	environ = append(environ, env)
	return environ
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
