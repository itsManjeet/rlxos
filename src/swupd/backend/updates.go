package backend

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
	r := &UpdatesResponse{}
	if err := b.request(path.Join(b.config.Server, "updates", b.config.Channel), r); err != nil {
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

func (b *Backend) getCurrentVersion() (int, error) {
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
	curver, err := b.getCurrentVersion()
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
	log.Printf("dowloading '%d' %s", updateInfo.Version, updateInfo.Url)
	if err := utils.DownloadFile(cachefile, updateInfo.Url); err != nil {
		return err
	}
	defer os.Remove(cachefile)

	log.Println("cleaning up previous release")
	if err := os.RemoveAll(path.Join("/", "usr.0")); err != nil {
		return fmt.Errorf("failed to cleanup previous release")
	}

	log.Println("unpacking update file")
	if err := exec.Command("unsquashfs", "-f", "-d", path.Join("/", "usr.1"), cachefile); err != nil {
		return fmt.Errorf("failed to extract updates")
	}

	return nil
}
