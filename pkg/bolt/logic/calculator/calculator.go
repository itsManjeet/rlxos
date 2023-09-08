package calculator

import (
	"fmt"
	"go/token"
	"go/types"
	"log"
	"regexp"
	"rlxos/pkg/bolt/storage"
)

type Logic struct {
	regex *regexp.Regexp
}

func (l *Logic) Init(_ storage.Storage) error {
	l.regex = regexp.MustCompile(`\b\d+(\.\d+)?\s*[-+*/]\s*\d+(\.\d+)?\b`)
	return nil
}

func (l *Logic) CanPredict(query string) bool {
	stats := l.regex.MatchString(query)
	log.Println("Calculator can predict", stats, query)
	return stats
}

func (l *Logic) Predict(query string) []string {
	resp := ""
	sep := ""
	for _, m := range l.regex.FindAllString(query, -1) {
		fs := token.NewFileSet()
		log.Println("EQUATION", m)
		tv, err := types.Eval(fs, nil, token.NoPos, m)
		if err != nil {
			resp = fmt.Sprintf("invalid expression %v", err)
			break
		}
		resp += sep + tv.Value.String()
		sep = ", "
	}
	return []string{resp}
}
