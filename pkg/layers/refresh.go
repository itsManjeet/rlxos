package layers

import (
	"fmt"
	"log"
	"os"
	"path"
	"strings"
	"syscall"
)

func (m *Manager) Refresh() error {
	m.Sync()

	if len(m.Layers) == 0 {
		log.Println("no layer found, skipping")
		return nil
	}

	var flag uintptr = 0
	isMounted, err := checkIsMounted()
	if err != nil {
		return err
	}
	if isMounted {
		flag = syscall.MS_REMOUNT
	}

	lower := ""
	withReadWrite := ""
	for _, l := range m.Layers {
		if strings.HasPrefix(l.Id, ".") || strings.HasPrefix(path.Base(l.Path), ".") {
			continue
		}

		if l.Id == "rw" || path.Base(l.Path) == "rw" {
			withReadWrite = path.Join(m.RootDir, l.Path)
			continue
		}

		if l.Id == "work" || path.Base(l.Path) == "work" {
			continue
		}

		log.Printf("enabling layer %s\n", l.Id)
		lower += path.Join(m.RootDir, l.Path) + ":"
	}
	lower += m.RootDir + "/usr"
	options := "lowerdir=" + lower
	if len(withReadWrite) != 0 {
		workdir := path.Join(path.Dir(withReadWrite), "work")
		if err := os.MkdirAll(workdir, 0755); err != nil {
			log.Printf("failed to create workdir %s, %v", workdir, err)
		}
		options = fmt.Sprintf("%s,upperdir=%s,workdir=%s", options, withReadWrite, workdir)
	} else {
		flag |= syscall.MS_RDONLY
	}
	log.Println("OPTIONS", options)
	if err := syscall.Mount("overlay", m.RootDir+"/usr", "overlay", flag, options); err != nil {
		return err
	}
	return nil
}
