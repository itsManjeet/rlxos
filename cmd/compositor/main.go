package main

import (
	"log"
	"rlxos/desktop/compositor"
)

func main() {
	c, err := compositor.New()
	if err != nil {
		log.Fatal(err)
	}
	defer c.Destroy()
	
	c.Start()
}
