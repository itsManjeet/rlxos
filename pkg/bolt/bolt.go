package bolt

import (
	"math/rand"
	"rlxos/pkg/bolt/logic"
	"rlxos/pkg/bolt/storage"
)

type Bolt struct {
	Logics  []logic.Logic
	Storage storage.Storage

	previousResponse string
}

func (b *Bolt) Init(filepath string) error {
	if err := b.Storage.Init(filepath); err != nil {
		return err
	}

	for _, logic := range b.Logics {
		if err := logic.Init(b.Storage); err != nil {
			return err
		}
	}
	return nil
}

func (b *Bolt) selectResponse(list []string) string {
	if len(list) == 1 {
		return list[0]
	}

	counter := 0
	for {
		if counter > 10 {
			return b.previousResponse
		}
		selectedResponse := list[rand.Intn(len(list))]
		if selectedResponse != b.previousResponse {
			b.previousResponse = selectedResponse
			return selectedResponse
		}
		counter++
	}
}

func (b *Bolt) Predict(query string) string {
	for _, i := range b.Logics {
		if i.CanPredict(query) {
			return b.selectResponse(i.Predict(query))
		}
	}
	return "sorry I have no idea about that"
}
