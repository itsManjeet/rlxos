package sysroot

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path"
	"rlxos/pkg/updates/config"
	"rlxos/pkg/utils"
	"sort"
)

func (s *Sysroot) request(url string, target interface{}) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return json.NewDecoder(resp.Body).Decode(target)
}

type UpdatesResponse struct {
	Updates []config.UpdateInfo `json:"updates"`
}

func (s *Sysroot) listUpdates() ([]config.UpdateInfo, error) {
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

func (s *Sysroot) Check() (*config.UpdateInfo, error) {
	list, err := s.listUpdates()
	if err != nil {
		return nil, err
	}

	return &list[0], nil
}

func (s *Sysroot) Update(updateInfo *config.UpdateInfo) error {
	if s.Images[0] == updateInfo.Version {
		if s.Images[0] != s.InUse {
			log.Println("latest system image is already avaiable on system")
			return nil
		}
		log.Println("system is already upto date")
		return nil
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
