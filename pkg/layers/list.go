package layers

import (
	"path"
	"rlxos/pkg/osinfo"
	"rlxos/pkg/utils"
	"strings"
)

func (m *Manager) List() ([]Layer, error) {
	mounts, err := osinfo.GetMounts(path.Join(m.RootDir, "proc", "mounts"))
	if err != nil {
		return nil, err
	}

	var overlayMountInfo *osinfo.MountInfo

	for _, mountInfo := range mounts {
		if mountInfo.Target == "/usr" && mountInfo.Type == "overlay" {
			overlayMountInfo = &mountInfo
			break
		}
	}
	layers, err := m.LoadLayers()
	resLayers := layers

	if overlayMountInfo == nil {
		return resLayers, nil
	}

	mountedLayers := []string{}
	for _, option := range overlayMountInfo.Options {
		if strings.HasPrefix(option, "lowerdir=") {
			mountedLayers = strings.Split(strings.TrimPrefix(option, "lowerdir="), ",")
			break
		}
	}
	if len(mountedLayers) == 0 {
		return resLayers, nil
	}

	for i, layer := range resLayers {
		if utils.Contains(mountedLayers, layer.Path) {
			resLayers[i].Active = true
		}
	}

	return resLayers, nil
}
