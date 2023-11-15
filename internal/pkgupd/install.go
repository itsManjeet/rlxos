package pkgupd

import (
	"fmt"
	"os"
	"os/exec"
	"path"
	"rlxos/internal/element"
	"rlxos/internal/hierarchy"
	"rlxos/internal/utils"
	"strings"
)

// TODO: verify chatgpt code
func findMissingStrings(list1, list2 []string) []string {
	// Create a map to store the strings from list2 for faster lookup
	list2Map := make(map[string]bool)
	for _, str := range list2 {
		list2Map[str] = true
	}

	// Iterate through list1 and check if each string is present in list2Map
	var missingStrings []string
	for _, str := range list1 {
		if !list2Map[str] {
			missingStrings = append(missingStrings, str)
		}
	}

	return missingStrings
}

func (pkgupd *Pkgupd) IsInstalled(el element.Metadata) (bool, error) {
	cachePath := hierarchy.SharedDataPath(APPID, el.Id, "cache")
	if _, err := os.Stat(cachePath); err != nil {
		return false, nil
	}

	cacheId, err := os.ReadFile(cachePath)
	if err != nil {
		return false, fmt.Errorf("failed to read cache file '%s': %v", cachePath, err)
	}

	if string(cacheId) == el.Cache {
		return true, nil
	}

	return false, nil
}

func (pkgupd *Pkgupd) Install(root string, elements []element.Metadata) error {
	for _, el := range elements {
		cachefile := hierarchy.LocalPath(hierarchy.CACHE_DIR, APPID, "cache", el.Cache)
		if err := utils.DownloadFile(cachefile, fmt.Sprintf("%s/cache/%s", pkgupd.Server, el.Cache)); err != nil {
			return err
		}
	}

	var filesToClean []string

	for _, el := range elements {
		cachefile := hierarchy.LocalPath(hierarchy.CACHE_DIR, APPID, "cache", el.Cache)

		var fileslist []string
		if output, err := exec.Command("tar", "-tf", cachefile).CombinedOutput(); err != nil {
			return fmt.Errorf("failed to list files '%s': %v %s", el.Id, err, string(output))
		} else {
			fileslist = strings.Split(string(output), "\n")
		}

		if output, err := exec.Command("tar", "-xhPf", cachefile, "-C", root).CombinedOutput(); err != nil {
			return fmt.Errorf("failed to install '%s': %v %s", el.Id, err, string(output))
		}

		dataPath := path.Join(root, "usr", "share", "pkgupd", el.Id)

		if _, err := os.Stat(path.Join(dataPath, "files")); err == nil {
			filesdata, err := os.ReadFile(path.Join(dataPath, "files"))
			if err == nil {
				oldfilesList := strings.Split(string(filesdata), "\n")
				filesToClean = append(filesToClean, findMissingStrings(fileslist, oldfilesList)...)
			}
		}

		if err := os.MkdirAll(dataPath, 0755); err != nil {
			return fmt.Errorf("failed to create database dir '%s': %v", dataPath, err)
		}

		if err := os.WriteFile(path.Join(dataPath, "files"), []byte(strings.Join(fileslist, "\n")), 0644); err != nil {
			return fmt.Errorf("failed to write installed file information '%s': %v", el.Id, err)
		}

		if err := os.WriteFile(path.Join(dataPath, "cache"), []byte(el.Cache), 0644); err != nil {
			return fmt.Errorf("failed to write installed file information '%s': %v", el.Id, err)
		}

		if err := os.WriteFile(path.Join(dataPath, "integration"), []byte(el.Integration), 0644); err != nil {
			return fmt.Errorf("failed to write installed file information '%s': %v", el.Id, err)
		}
	}

	for _, el := range elements {
		if len(el.Integration) > 0 {
			if output, err := exec.Command("sh", "-c", el.Integration).CombinedOutput(); err != nil {
				fmt.Printf("failed to execute integration '%s': %v %s\n", el.Id, err, string(output))
			} else {
				if err := os.MkdirAll(hierarchy.LocalPath(hierarchy.DATA_DIR, APPID, el.Id), 0755); err != nil {
					fmt.Printf("failed to write integration status '%s': %v\n", el.Id, err)
				}
				if err := os.WriteFile(hierarchy.LocalPath(hierarchy.DATA_DIR, APPID, el.Id, "integration"), []byte(""), 0644); err != nil {
					fmt.Printf("failed to write integration status '%s': %v\n", el.Id, err)
				}
			}
		}

	}

	for _, file := range filesToClean {
		filepath := path.Join(root, file)
		if _, err := os.Stat(filepath); err == nil {
			os.Remove(filepath)
		}
	}

	return nil
}
