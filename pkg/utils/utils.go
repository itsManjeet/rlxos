package utils

import (
	"io"
	"log"
	"os"
	"os/exec"
)

func DownloadFile(filepath string, url string) error {
	cmd := exec.Command("wget", "-nc", "-c", "-O", filepath, url)
	if len(os.Getenv("GITHUB_ACTIONS")) == 0 {
		cmd.Stdout = os.Stdout
	}
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func CopyFile(src, dest string) error {
	buf := make([]byte, 1024)

	fin, err := os.Open(src)
	if err != nil {
		return err
	}
	defer fin.Close()

	fout, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer fout.Close()

	for {

		n, err := fin.Read(buf)
		if err != nil && err != io.EOF {
			log.Fatal(err)
		}

		if n == 0 {
			break
		}

		if _, err := fout.Write(buf[:n]); err != nil {
			log.Fatal(err)
		}
	}

	return nil
}
