package utils

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"path"
	"strings"
	"time"

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
	if _, err := os.Stat(filepath); err == nil {
		return nil
	}
	if _, err := os.Stat(path.Dir(filepath)); err != nil {
		if err := os.MkdirAll(path.Dir(filepath), 0755); err != nil {
			return fmt.Errorf("failed to create required parent directory '%s': %v", path.Dir(filepath), err)
		}
	}
	out, err := os.Create(filepath + ".tmp")
	if err != nil {
		return err
	}

	transport := &http.Transport{
		Dial: (&net.Dialer{
			Timeout:   60 * time.Second,
			KeepAlive: 30 * time.Second,
		}).Dial,
		TLSHandshakeTimeout: 60 * time.Second,
	}

	client := http.Client{
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			log.Println("Redirected to:", req.URL)
			for k := range req.Header {
				delete(req.Header, k)
			}
			return nil
		},
		Transport: transport,
	}

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		out.Close()
		return err
	}

	resp, err := client.Do(req)
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
