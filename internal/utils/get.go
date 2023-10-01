package utils

import (
	"fmt"
	"io"
	"log"
	"net/http"
)

func Get(url string) ([]byte, error) {
	client := http.Client{
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			log.Println("Redirected to:", req.URL)
			return nil
		},
	}

	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf(resp.Status)
	}

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return data, nil
}
