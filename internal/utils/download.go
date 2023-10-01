package utils

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/dustin/go-humanize"
)

type WriteCounter struct {
	Total uint64
	Size  uint64
}

func (wc *WriteCounter) Write(p []byte) (int, error) {
	n := len(p)
	wc.Total += uint64(n)
	if os.Getenv("NO_PRINT_PROGRESS") == "" {
		wc.PrintProgress()
	}

	return n, nil
}

func (wc WriteCounter) PrintProgress() {
	fmt.Printf("\r%s", strings.Repeat(" ", 35))
	fmt.Printf("\rDownloading... %s/%s complete", humanize.Bytes(wc.Total), humanize.Bytes(wc.Size))
}

func DownloadFile(filepath string, url string) error {
	out, err := os.Create(filepath + ".tmp")
	if err != nil {
		return err
	}

	client := http.Client{
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			log.Println("Redirected to:", req.URL)
			return nil
		},
	}

	resp, err := client.Get(url)
	if err != nil {
		out.Close()
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf(resp.Status)
	}

	counter := &WriteCounter{
		Size: uint64(resp.ContentLength),
	}
	if _, err = io.Copy(out, io.TeeReader(resp.Body, counter)); err != nil {
		out.Close()
		return err
	}

	fmt.Print("\n")
	out.Close()

	if err = os.Rename(filepath+".tmp", filepath); err != nil {
		return err
	}
	return nil
}
