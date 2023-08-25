package storage

type Storage interface {
	Init(string) error
	Add(string, string) error
	Size() int
	Get(int) (string, []string)
	Store(string) error
}
