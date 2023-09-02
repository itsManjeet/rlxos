package main

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Println("Usage:", os.Args[0], "source-dir", "target-dir")
		os.Exit(1)
	}

	sourceDir := os.Args[1]
	targetDir := os.Args[2]

	sourceData := map[string]string{}
	targetData := map[string]string{}

	fillUpData := func(p string, m *map[string]string) error {
		if err := filepath.Walk(sourceDir, func(path string, info fs.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if info.IsDir() {
				return nil
			}
			// TODO: Use HASH of file
			(*m)[path] = fmt.Sprint(info.Size())
			return nil
		}); err != nil {
			return err
		}
		return nil
	}

	if err := fillUpData(sourceDir, &sourceData); err != nil {
		log.Fatal(err)
	}

	if err := fillUpData(targetDir, &targetData); err != nil {
		log.Fatal(err)
	}

	requiredfiles := []string{}

	for key, hash := range targetData {
		if shash, ok := sourceData[key]; !ok || hash != shash {
			requiredfiles = append(requiredfiles, path.Join(targetDir, key))
		}
	}

	if len(requiredfiles) == 0 {
		log.Println("No patch needed")
		os.Exit(0)
	}

	tmpdir, err := os.MkdirTemp("/tmp", "patch-*")
	if err != nil {
		log.Fatal(err)
	}
	defer os.RemoveAll(tmpdir)

	args := []string{"-rap", tmpdir}
	args = append(args, requiredfiles...)
	if err := exec.Command("cp", args...).Run(); err != nil {
		log.Fatal(err)
	}

	log.Printf("Patched %d files\n", len(requiredfiles))
	if err := exec.Command("tar", "-caf", "update.tar.xz", "-C", tmpdir, ".").Run(); err != nil {
		log.Fatal(err)
	}
}
