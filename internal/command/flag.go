package command

type FlagHandler func([]string) error

type Flag struct {
	Id      string
	About   string
	Count   int
	Handler FlagHandler
}
