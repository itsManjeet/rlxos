package pkgupd

import (
	"fmt"
	"rlxos/internal/element"
)

func (pkgupd *Pkgupd) Get(id string) (element.Metadata, bool) {
	for _, p := range pkgupd.metadata {
		if p.Id == id {
			return p, true
		}
	}
	return element.Metadata{}, false
}

func (pkgupd *Pkgupd) Resolve(ids ...string) ([]element.Metadata, error) {

	visited := map[string]bool{}
	pairs := []element.Metadata{}

	var dfs func(p string) error
	dfs = func(p string) error {
		visited[p] = true

		e, ok := pkgupd.Get(p)
		if !ok {
			return fmt.Errorf("MISSING %s", p)
		}

		isInstalled, err := pkgupd.IsInstalled(e)
		if err != nil {
			return err
		}
		if isInstalled {
			return nil
		}

		for _, dep := range e.Depends {
			if visited[dep] {
				continue
			}

			if err := dfs(dep); err != nil {
				return fmt.Errorf("%s\n\tTRACEBACK %s", err, p)
			}
		}

		pairs = append(pairs, e)
		return nil
	}

	for _, id := range ids {
		if err := dfs(id); err != nil {
			return nil, err
		}
	}

	return pairs, nil
}
