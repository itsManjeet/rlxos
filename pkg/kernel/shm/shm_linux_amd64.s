// +build amd64

#include "textflag.h"

// func toPointer(addr uintptr) unsafe.Pointer
TEXT ·toPointer(SB), NOSPLIT, $0
    MOVQ addr+0(FP), AX     // Load argument into AX
    MOVQ AX, ret+8(FP)      // Set return value
    RET
