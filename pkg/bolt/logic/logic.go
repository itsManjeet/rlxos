package logic

import "rlxos/pkg/bolt/storage"

type Logic interface {
	Init(storage.Storage) error
	CanPredict(string) bool
	Predict(string) []string
}
