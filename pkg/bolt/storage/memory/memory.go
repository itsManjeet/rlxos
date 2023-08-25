package memory

import (
	"io/ioutil"
	"log"
	"strings"
)

const (
	ID string = "MEMORY"
)

type Storage struct {
	responses map[string][]string
	keys      []string
}

func (s *Storage) Init(filepath string) error {
	log.Printf("Loading %s storage from %s\n", ID, filepath)
	s.responses = map[string][]string{}
	s.keys = []string{}
	data, err := ioutil.ReadFile(filepath)
	if err != nil {

		return nil
	}

	lastQuery := "hello"
	for _, line := range strings.Split(string(data), "\n") {
		line = strings.Trim(line, " \n")
		if len(line) == 0 {
			continue
		}

		if line[0] == '-' {
			lastQuery = strings.Trim(line[1:], " ")
			s.keys = append(s.keys, lastQuery)
		} else {
			s.responses[lastQuery] = append(s.responses[lastQuery], line)
		}
	}

	log.Printf("Found %d responses\n", len(s.responses))

	return nil
}

func contains(list []string, key string) (int, bool) {
	for i, k := range list {
		if k == key {
			return i, true
		}
	}
	return -1, false
}

func (s *Storage) Add(query, response string) error {
	s.responses[query] = append(s.responses[query], response)
	if _, ok := contains(s.keys, query); !ok {
		s.keys = append(s.keys, query)
	}
	return nil
}

func (s *Storage) Store(filepath string) error {
	return nil
}

func (s *Storage) Size() int {
	return len(s.responses)
}

func (s *Storage) Get(idx int) (string, []string) {
	key := s.keys[idx]
	return key, s.responses[key]
}
