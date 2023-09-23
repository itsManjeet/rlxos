package sysroot

import (
	"fmt"
	"log"
	"path"
	"regexp"
	"rlxos/pkg/osinfo"
	"rlxos/pkg/utils"
	"sort"
	"strconv"
	"strings"
)

func (s *Sysroot) ParseRemoteReleases(sha256sums string) ([]int, error) {
	images := []int{}
	arch, _ := osinfo.Arch()
	rgx := regexp.MustCompile(fmt.Sprintf(`%s\/([0-9]+)\/sysroot\.img`, arch))
	for _, match := range rgx.FindAllStringSubmatch(sha256sums, -1) {
		if len(match) == 2 {
			version, _ := strconv.Atoi(match[1])
			images = append(images, version)
		}
	}
	sort.Slice(images, func(i, j int) bool { return images[i] > images[j] })
	return images, nil
}

func (s *Sysroot) ListRemoteReleases() ([]int, error) {
	url := fmt.Sprintf("%s/%s/SHA256SUMS", s.config.Server, s.config.Channel)
	response, err := utils.Get(url)
	if err != nil {
		return nil, err
	}

	return s.ParseRemoteReleases(strings.Trim(string(response), " \n"))
}

func (s *Sysroot) GetChangelog(version int) (string, error) {
	arch, _ := osinfo.Arch()
	url := fmt.Sprintf("%s/%s/%s/%d/changelog", s.config.Server, s.config.Channel, arch, version)
	response, err := utils.Get(url)
	if err != nil {
		return "", err
	}
	return string(response), nil
}

func (s *Sysroot) GetSystemImage(version int) error {
	arch, _ := osinfo.Arch()
	url := fmt.Sprintf("%s/%s/%s/%d/sysroot.img", s.config.Server, s.config.Channel, arch, version)

	if err := utils.DownloadFile(path.Join(SYSTEM_IMAGES_PATH, fmt.Sprint(version)), url); err != nil {
		return err
	}
	return nil
}

func (s *Sysroot) HasUpdates(releases []int) bool {
	if len(releases) == 0 {
		log.Fatal("unexpected error, failed to retrieve any release information from server, please contact to rlxos community groups or checkout website for more information")
	}

	return releases[0] > s.Images[0]
}

func (s *Sysroot) Update() error {
	releases, err := s.ListRemoteReleases()
	if err != nil {
		return err
	}
	if !s.HasUpdates(releases) {
		return fmt.Errorf("system is already upto date")
	}

	log.Printf("Downloading system image [%d]\n", releases[0])
	if err := s.GetSystemImage(releases[0]); err != nil {
		return err
	}

	log.Printf("Updating bootloader")
	if err := s.UpdateBootloader("/"); err != nil {
		return err
	}
	return nil
}
