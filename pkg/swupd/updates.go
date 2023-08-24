package swupd

import (
	"fmt"
	"log"
	"os"
	"path"
	"rlxos/pkg/updates/config"
	"sort"
	"strconv"

	zsync "github.com/AppImageCrafters/libzsync-go"
)

const (
	ROLLING_RELEASE = 0
)

type UpdatesResponse struct {
	Updates []config.UpdateInfo `json:"updates"`
}

func (b *Backend) listUpdates() ([]config.UpdateInfo, error) {
	r := UpdatesResponse{}
	url := fmt.Sprintf("%s/%s", b.config.Server, b.config.Channel)
	log.Println("url", url)
	if err := b.request(url, &r); err != nil {
		return nil, err
	}
	if len(r.Updates) == 0 {
		return nil, fmt.Errorf("no release available")
	}
	sort.Slice(r.Updates[:], func(i, j int) bool {
		return r.Updates[i].Version < r.Updates[j].Version
	})
	return r.Updates, nil
}

func GetCurrentVersion() (int, error) {
	data, err := os.ReadFile(path.Join("/", "usr", ".version"))
	if err != nil {
		return 0, err
	}
	version, err := strconv.Atoi(string(data))
	return version, err
}

func (b *Backend) Check() (*config.UpdateInfo, error) {
	list, err := b.listUpdates()
	if err != nil {
		return nil, err
	}
	curver, err := GetCurrentVersion()
	if err != nil {
		return nil, err
	}

	if list[0].Version == curver && curver != ROLLING_RELEASE {
		return nil, nil
	}

	return &list[0], nil
}

func (b *Backend) Update(updateInfo *config.UpdateInfo) error {
	curver, err := GetCurrentVersion()
	if err != nil {
		return fmt.Errorf("failed to read current version")
	}
	if curver == updateInfo.Version && curver != ROLLING_RELEASE {
		return fmt.Errorf("internal error, already update date system")
	}

	updatefile := path.Base(updateInfo.Url)
	cachefile := path.Join("/", "var", "cache", "updates", updatefile)
	if _, err := os.Stat(path.Dir(cachefile)); os.IsNotExist(err) {
		if err := os.MkdirAll(path.Dir(cachefile), 0755); err != nil {
			return fmt.Errorf("failed to create cache file path %s, %v", path.Dir(cachefile), err)
		}
	}
	sync, err := zsync.NewZSync(updateInfo.Url + ".zsync")
	if err != nil {
		return fmt.Errorf("failed to create zsync %v", err)
	}
	systemPath := path.Join("/", "run", "initramfs", "rlxos", "system")

	oldPath := path.Join(systemPath, fmt.Sprint(curver))
	newPath := path.Join(systemPath, fmt.Sprint(updateInfo.Version))
	var imagefile *os.File

	imagefile, err = os.Create(newPath + ".tmp")
	if err != nil {
		return fmt.Errorf("failed to create %s, %v", oldPath, err)
	}

	log.Println("Syning image")
	if err := sync.Sync(oldPath, imagefile); err != nil {
		return fmt.Errorf("failed to sync image file %v", err)
	}

	if err := os.Rename(newPath+".tmp", newPath); err != nil {
		return fmt.Errorf("failed to install new image file")
	}

	return nil
}
