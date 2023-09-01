package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"path"
	"rlxos/pkg/bolt"
	"rlxos/pkg/bolt/logic"
	"rlxos/pkg/bolt/logic/bestmatch"
	"rlxos/pkg/bolt/storage/memory"
	"strings"
)

func main() {
	bot := bolt.Bolt{
		Logics: []logic.Logic{
			&bestmatch.Logic{},
		},
		Storage: &memory.Storage{},
	}

	responses := os.Getenv("BOLT_RESPONSES")
	if len(responses) == 0 {
		responses = path.Join("/", "var", "lib", "bolt", "responses.txt")
	}

	if err := bot.Init(responses); err != nil {
		log.Fatal("failed to init bolt", err)
	}

	reader := bufio.NewReader(os.Stdin)
	for {
		fmt.Print(">> ")
		query, _ := reader.ReadString('\n')
		query = strings.Trim(query, " \n")
		if query == "quit" || query == "q" {
			break
		}
		fmt.Println("bot:", bot.Predict(query))
	}
}
