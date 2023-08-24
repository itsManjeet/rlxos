package main

import (
	. "rlxos/kernel/bootboot"
	"rlxos/kernel/font"
	_ "unsafe"
)

var (
	//go:cgo_export_static bootboot bootboot
	//go:linkname bootboot bootboot
	bootboot BOOTBOOT

	//go:cgo_export_static fb fb
	//go:linkname fb fb
	fb uint32
)

//go:cgo_export_static _start _start
//go:linkname _start _start
//go:nosplit
func _start() {

	_ = font.Load()

	for {
	}
}

func main() {
}
