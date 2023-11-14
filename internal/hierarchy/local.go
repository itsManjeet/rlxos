package hierarchy

import (
	"fmt"
	"os"
	"path"
	"strings"
)

const (
	LOCAL_STATE_DIR = "/var/"
	DATA_DIR        = "lib"
	CACHE_DIR       = "cache"
	LOG_DIR         = "log"
)

func LocalPath(p string, app string, h ...string) string {
	if val := os.Getenv(fmt.Sprintf("%s_%s_DIR", strings.ToUpper(app), strings.ToUpper(p))); val != "" {
		return val
	}
	hp := path.Join(h...)
	return path.Join(LOCAL_STATE_DIR, p, app, hp)
}
