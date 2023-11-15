package pkgupd

import (
	"rlxos/internal/element"
	"strings"
)

func (pkgupd *Pkgupd) Search(info string) []element.Metadata {
	var found []element.Metadata
	for _, p := range pkgupd.metadata {
		if strings.Contains(p.Id, info) || strings.Contains(p.About, info) {
			found = append(found, p)
		}
	}
	return found
}
