package localize

import (
	"gopkg.in/yaml.v3"
	"log"
	"os"
	"strings"
)

type Translation struct {
	String      string `yaml:"string"`
	Translation string `yaml:"translation"`
}

var translations = map[string]map[string]string{}

func Open(s string) (map[string]string, error) {
	if _, err := os.Stat(s); os.IsNotExist(err) {
		return map[string]string{}, nil
	}
	data, err := os.ReadFile(s)
	if err != nil {
		return nil, err
	}
	var ts []Translation
	if err := yaml.Unmarshal(data, &ts); err != nil {
		log.Fatal(err)
	}
	m := map[string]string{}
	for _, t := range ts {
		m[t.String] = t.Translation
	}
	return m, nil
}

func Save(s string, m map[string]string) error {
	var ts []Translation
	for k, v := range m {
		ts = append(ts, Translation{
			String:      k,
			Translation: v,
		})
	}
	data, err := yaml.Marshal(&ts)
	if err != nil {
		return err
	}
	return os.WriteFile(s, data, 0644)
}

func Add(id string, data []byte) {
	var ts []Translation
	if err := yaml.Unmarshal(data, &ts); err != nil {
		log.Fatal(err)
	}
	if _, ok := translations[id]; !ok {
		translations[id] = map[string]string{}
	}
	for _, t := range ts {
		translations[id][t.String] = t.Translation
	}
}

func TranslateIn(id, str string) string {
	ts, ok := translations[id]
	if !ok {
		return str
	}

	s, ok := ts[str]
	if !ok {
		return str
	}
	return s
}

func Translate(str string) string {
	id := os.Getenv("LANG")
	if id == "" {
		return str
	}

	s := strings.Split(id, "_")
	return TranslateIn(s[0], str)
}
