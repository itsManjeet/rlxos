package ignite

import (
	"fmt"
	"os"
	"path"
	"rlxos/internal/color"
	"rlxos/internal/element"
	"rlxos/internal/utils"
)

func (bldr *Ignite) Pull(elementInfo *element.Element) error {
	cachefile, err := bldr.CacheFile(elementInfo)
	if err != nil {
		return err
	}

	if _, err := os.Stat(cachefile); err == nil {
		return nil
	}

	cacheid := path.Base(cachefile)
	color.Titled(color.Blue, "FETCHING", "%s:%s", cacheid, elementInfo.Id)
	if err := utils.DownloadFile(cachefile, fmt.Sprintf("%s/cache/%s", bldr.ArtifactServer, cacheid)); err != nil {
		return err
	}
	return nil
}
