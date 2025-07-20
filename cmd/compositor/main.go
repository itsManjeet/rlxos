package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/user"
	"path/filepath"
	"runtime"
	"strconv"
	"syscall"
)

var (
	userID string
	groups = []string{
		"input",
		"video",
		"audio",
		"seat",
	}
	startup string
)

func init() {
	runtime.LockOSThread()

	flag.StringVar(&userID, "user", "", "Run display as user")
	flag.StringVar(&startup, "startup", "", "Starup command")
}

func main() {
	var s Server

	flag.Parse()
	if err := switchUser(); err != nil {
		log.Fatal(err)
	}

	if err := s.Init(); err != nil {
		log.Fatal(err)
	}
	defer s.Destroy()

	if err := s.Run(); err != nil {
		log.Fatal(err)
	}
}

func switchUser() error {
	if userID == "" {
		if os.Getenv("XDG_RUNTIME_DIR") == "" {
			return fmt.Errorf("XDG_RUNTIME_DIR not set")
		}
		return nil
	}
	u, err := user.Lookup(userID)
	if err != nil {
		return err
	}

	var gids []int

	xdgRuntimeDir := filepath.Join("/run/user/", u.Uid)
	uid, _ := strconv.Atoi(u.Uid)
	gid, _ := strconv.Atoi(u.Gid)

	if err := os.MkdirAll(xdgRuntimeDir, 0755); err != nil {
		return fmt.Errorf("failed to prepare XDG_RUNTIME_DIR %v", err)
	}

	if err := os.Chown(xdgRuntimeDir, uid, gid); err != nil {
		return fmt.Errorf("failed to chown XDG_RUNTIME_DIR %v", err)
	}

	for _, group := range groups {
		g, err := user.LookupGroup(group)
		if err != nil {
			return fmt.Errorf("missing required group %s %v", group, err)
		}
		groupId, _ := strconv.Atoi(g.Gid)
		gids = append(gids, groupId)
	}

	if err := syscall.Setgroups(gids); err != nil {
		return fmt.Errorf("failed to setgroups %v", err)
	}

	if err := syscall.Setgid(gid); err != nil {
		return fmt.Errorf("failed to setgid %v", err)
	}

	if err := syscall.Setuid(uid); err != nil {
		return fmt.Errorf("failed to setuid %v", err)
	}

	os.Setenv("XDG_RUNTIME_DIR", xdgRuntimeDir)
	os.Setenv("HOME", u.HomeDir)

	return nil
}
