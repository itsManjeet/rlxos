package flag

type Handler func([]string) error

type Flag struct {
	id      string
	about   string
	count   int
	handler Handler
}

func New(id string) *Flag {
	return &Flag{
		id: id,
	}
}

func (f *Flag) GetId() string {
	return f.id
}

func (f *Flag) GetAbout() string {
	return f.about
}

func (f *Flag) GetCount() int {
	return f.count
}

func (f *Flag) GetHandler() Handler {
	return f.handler
}

func (c *Flag) About(about string) *Flag {
	c.about = about
	return c
}

func (c *Flag) Count(count int) *Flag {
	c.count = count
	return c
}

func (c *Flag) Handler(handler Handler) *Flag {
	c.handler = handler
	return c
}
