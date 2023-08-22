package swupd

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/updates/config"
	"rlxos/pkg/utils"
	"sort"
	"strconv"
)

type UpdatesResponse struct {
	Updates []config.UpdateInfo `json:"updates"`
}

func (b *Backend) listUpdates() ([]config.UpdateInfo, error) {
	r := UpdatesResponse{}
	url := fmt.Sprintf("%s/releases/%s", b.config.Server, b.config.Channel)
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

	if list[0].Version == curver {
		return nil, nil
	}

	return &list[0], nil
}

func (b *Backend) Update(updateInfo *config.UpdateInfo) error {
	updatefile := path.Base(updateInfo.Url)
	cachefile := path.Join("/", "var", "cache", "updates", updatefile)
	if _, err := os.Stat(path.Dir(cachefile)); os.IsNotExist(err) {
		if err := os.MkdirAll(path.Dir(cachefile), 0755); err != nil {
			return fmt.Errorf("failed to create cache file path %s, %v", path.Dir(cachefile), err)
		}
	}
	log.Printf("dowloading '%d' %s", updateInfo.Version, updateInfo.Url)
	if err := utils.DownloadFile(cachefile, updateInfo.Url); err != nil {
		return err
	}

	log.Printf("installing system image %d\n", updateInfo.Version)
	if err := exec.Command("mv", cachefile, path.Join("/", "run", "initramfs", "rlxos", "system", fmt.Sprint(updateInfo.Version))); err != nil {
		return fmt.Errorf("failed to extract updates")
	}

	return nil
}
