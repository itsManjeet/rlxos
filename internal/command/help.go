package command

import "fmt"

func (c *Command) Help() error {
	fmt.Printf("%s: %s\n", c.selfPath, c.Usage)
	fmt.Println(c.About)
	fmt.Printf("TASK:\n")
	for _, s := range c.SubCommands {
		fmt.Printf("  %s%*.s %s\n", s.Id, 20-len(s.Id), " ", s.About)
	}
	fmt.Printf("\nFLAGS:\n")
	for _, f := range c.Flags {
		fmt.Printf("  -%s%*.s%s\n", f.Id, 20-len(f.Id), " ", f.About)
	}
	return nil
}
