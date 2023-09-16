package swupd

import (
	"fmt"
	"log"
	"os"
	"path"
	"rlxos/pkg/updates/config"
	"rlxos/pkg/utils"
	"sort"
	"strconv"
)

const (
	ROLLING_RELEASE = 999
)

type UpdatesResponse struct {
	Updates []config.UpdateInfo `json:"updates"`
}

func (s *Swupd) listUpdates() ([]config.UpdateInfo, error) {
	r := UpdatesResponse{}
	url := fmt.Sprintf("%s/%s", s.config.Server, s.config.Channel)
	log.Println("url", url)
	if err := s.request(url, &r); err != nil {
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

func (s *Swupd) Check() (*config.UpdateInfo, error) {
	list, err := s.listUpdates()
	if err != nil {
		return nil, err
	}
	curver_str, ok := s.OsInfo["IMAGE_VERSION"]
	if !ok {
		return nil, fmt.Errorf("missing required key 'IMAGE_VERSION' in os-release")
	}

	curver, err := strconv.Atoi(curver_str)
	if err != nil {
		return nil, err
	}

	if list[0].Version == curver && curver != ROLLING_RELEASE {
		return nil, nil
	}

	return &list[0], nil
}

func (s *Swupd) Update(updateInfo *config.UpdateInfo) error {
	curver_str, ok := s.OsInfo["IMAGE_VERSION"]
	if !ok {
		return fmt.Errorf("missing required key 'IMAGE_VERSION' in os-release")
	}

	curver, err := strconv.Atoi(curver_str)
	if err != nil {
		return err
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

	systemPath := path.Join("/", "rlxos", "system")

	newPath := path.Join(systemPath, fmt.Sprint(updateInfo.Version))

	log.Println("Syning image")
	if err := utils.DownloadFile(newPath, updateInfo.Url); err != nil {
		return fmt.Errorf("failed to sync image file %v", err)
	}

	return nil
}
