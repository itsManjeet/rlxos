package bestmatch

import (
	"log"
	"math"
	"math/rand"
	"rlxos/pkg/bolt/storage"
	"time"
)

type Logic struct {
	responses storage.Storage
}

func init() {
	rand.NewSource(time.Now().UnixNano())
}

func (l *Logic) Init(s storage.Storage) error {
	l.responses = s
	return nil
}

func (l *Logic) CanPredict(query string) bool {
	return true
}

func levenshteinDistance(str1, str2 string) int {
	s1len := len(str1)
	s2len := len(str2)
	column := make([]int, len(str1)+1)

	min := func(a, b, c int) int {
		if a < b {
			if a < c {
				return a
			}
		} else {
			if b < c {
				return b
			}
		}
		return c
	}

	for y := 1; y <= s1len; y++ {
		column[y] = y
	}
	for x := 1; x <= s2len; x++ {
		column[0] = x
		lastkey := x - 1
		for y := 1; y <= s1len; y++ {
			oldkey := column[y]
			var incr int
			if str1[y-1] != str2[x-1] {
				incr = 1
			}

			column[y] = min(column[y]+1, column[y-1]+1, lastkey+incr)
			lastkey = oldkey
		}
	}
	return column[s1len]
}

func (l *Logic) Predict(query string) []string {
	distance := math.MaxFloat64
	responses := []string{}
	for i := 0; i < l.responses.Size(); i++ {
		key, values := l.responses.Get(i)
		localDistance := (float64(levenshteinDistance(key, query)) / float64(len(query)))
		log.Printf("Got distance %s, %s = %f\n", key, query, localDistance)
		if localDistance < distance {
			distance = localDistance
			responses = values
		}
		if localDistance == 0 {
			break
		}
	}
	if len(responses) == 0 {
		responses = []string{
			"sorry i have no idea about that",
		}
	}

	return responses
}
