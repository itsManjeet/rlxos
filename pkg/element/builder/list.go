package builder

import (
	"fmt"
	"os"
	"rlxos/pkg/color"
	"rlxos/pkg/element"
)

func (b *Builder) List(dependencyType element.DependencyType, ids ...string) ([]Pair, error) {

	visited := map[string]bool{}
	pairs := []Pair{}

	var dfs func(p string) error
	dfs = func(p string) error {
		visited[p] = true

		e := b.pool[p]
		if e == nil {
			return fmt.Errorf("MISSING %s", p)
		}

		for _, dep := range e.AllDepends(dependencyType) {
			if visited[dep] {
				continue
			}

			if err := dfs(dep); err != nil {
				return fmt.Errorf("%s\n\tTRACEBACK %s", err, p)
			}
		}
		cachePath, _ := b.CacheFile(e)
		state := BuildStatusWaiting
		if _, err := os.Stat(cachePath); err == nil {
			state = BuildStatusCached
		}
		isCached := func(id string) bool {
			for _, p := range pairs {
				if p.Path == id {
					if p.State != BuildStatusCached {
						return false
					}
				}
			}
			return true
		}
		for _, dep := range e.AllDepends(element.DependencyAll) {
			if !isCached(dep) {
				state = BuildStatusWaiting
				break
			}
		}

		pairs = append(pairs, Pair{
			Path:  p,
			Value: e,
			State: state,
		})
		return nil
	}

	for _, id := range ids {
		color.Process("Resolving dependencies for %s", id)
		if err := dfs(id); err != nil {
			return nil, err
		}
	}

	return pairs, nil
}
