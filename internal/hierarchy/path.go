package hierarchy

import (
	"fmt"
	"os"
	"path"
	"strings"
)

const (
	LOCAL_STATE_DIR = "/var/"
	SHARED_DATA_DIR = "/usr/share"
	DATA_DIR        = "lib"
	CACHE_DIR       = "cache"
	LOG_DIR         = "log"
)

func LocalPath(p string, app string, h ...string) string {
	if val := os.Getenv(fmt.Sprintf("%s_%s_DIR", strings.ToUpper(app), strings.ToUpper(p))); val != "" {
		return path.Join(val, path.Join(h...))
	}
	return path.Join(LOCAL_STATE_DIR, p, app, path.Join(h...))
}

func SharedDataPath(app string, h ...string) string {
	if val := os.Getenv(fmt.Sprintf("%s_DIR", strings.ToUpper(app))); val != "" {
		return val
	}
	return path.Join(SHARED_DATA_DIR, app, path.Join(h...))
}
