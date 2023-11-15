package pkgupd

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"rlxos/internal/hierarchy"
	"rlxos/internal/utils"
	"time"
)

func (p *Pkgupd) reloadMetadata() error {
	var metafile = hierarchy.LocalPath(hierarchy.CACHE_DIR, APPID, "meta")
	data, err := os.ReadFile(metafile)
	if err != nil {
		return fmt.Errorf("failed to read metadata from '%s': %v", metafile, err)
	}
	p.metadata = nil
	if err := json.Unmarshal(data, &p.metadata); err != nil {
		return fmt.Errorf("failed to parse metadata from '%s': %v", metafile, err)
	}
	log.Println("FOUND:", len(p.metadata))
	return nil
}

func (p *Pkgupd) Sync(force bool) error {
	var metafile = hierarchy.LocalPath(hierarchy.CACHE_DIR, APPID, "meta")
	stat, err := os.Stat(metafile)
	if err == nil {
		if time.Since(stat.ModTime()).Minutes() < 5 && !force {
			return p.reloadMetadata()
		}
	}

	var metaurl = fmt.Sprintf("%s/channel/%s", p.Server, p.Channel)
	if err := utils.DownloadFile(metafile, metaurl); err != nil {
		return fmt.Errorf("failed to get metadata from '%s': %v", metaurl, err)
	}
	return nil
}
