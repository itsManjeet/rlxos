package pkgupd

import (
	"fmt"
	"os"
	"rlxos/internal/element"
	"rlxos/internal/hierarchy"
	"strings"
)

func (pkgupd *Pkgupd) Uninstall(root string, elements []element.Metadata) error {
	for _, el := range elements {
		cachePath := root + "/" + hierarchy.SharedDataPath(APPID, el.Id, "cache")
		filesPath := root + "/" + hierarchy.SharedDataPath(APPID, el.Id, "files")
		cacheId, err := os.ReadFile(cachePath)
		if err != nil {
			return fmt.Errorf("failed to read cache info '%s': %v %s", el.Id, err, string(cacheId))
		}

		filesListData, err := os.ReadFile(filesPath)
		if err != nil {
			return fmt.Errorf("failed to read files info '%s': %v %s", el.Id, err, string(filesListData))
		}

		filesList := strings.Split(string(filesListData), "\n")
		for i := range filesList {
			os.Remove(filesList[len(filesList)-i])
		}
	}
	return nil
}
