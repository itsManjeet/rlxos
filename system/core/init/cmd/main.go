package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
)

const (
	serviceManagerPath = "/system/core/cmd/service"
)

func main() {
	if os.Getpid() != 1 {
		log.Fatal("ERROR init must run as PID 1")
	}

	ctxt, cancel := context.WithCancel(context.Background())

	signalHandler := make(chan os.Signal, 1)
	signal.Notify(signalHandler, syscall.SIGUSR1, syscall.SIGCHLD, syscall.SIGINT, syscall.SIGALRM)

	_ = syscall.Reboot(syscall.LINUX_REBOOT_CMD_CAD_OFF)

	var reboot int

	serviceManagerProcess, err := startServiceManager()
	go func() {
		if err == nil {
			if _, err := serviceManagerProcess.Wait(); err != nil {
				log.Println("system initialization failed", err)
			}
		} else {
			log.Println("failed to start service manager", err)
		}
		cancel()
	}()

	// Wait for service manager to complete
	// or os signals
	for reboot == 0 {
		select {
		case sig := <-signalHandler:
			switch sig {
			case syscall.SIGUSR1:
				reboot = syscall.LINUX_REBOOT_CMD_POWER_OFF
			case syscall.SIGINT:
				reboot = syscall.LINUX_REBOOT_CMD_RESTART

			case syscall.SIGCHLD, syscall.SIGALRM:
				for {
					if pid, _ := syscall.Wait4(-1, nil, syscall.WNOHANG, nil); pid <= 0 {
						break
					}
				}
			}
		case <-ctxt.Done():
			reboot = syscall.LINUX_REBOOT_CMD_POWER_OFF
		}
	}

	if serviceManagerProcess != nil {
		_ = serviceManagerProcess.Signal(syscall.SIGINT)
	}
	_ = syscall.Reboot(syscall.LINUX_REBOOT_CMD_CAD_ON)

	log.Println("waiting for service manager to finish")
	// Wait for service manager to finish
	<-ctxt.Done()

	if reboot == 0 {
		reboot = syscall.LINUX_REBOOT_CMD_POWER_OFF
	}

	syscall.Sync()

	if err := syscall.Reboot(reboot); err != nil {
		log.Fatal("failed to exec reboot syscall", err)
	}
}

func startServiceManager() (*os.Process, error) {
	cmd := &exec.Cmd{
		Path:   serviceManagerPath,
		Args:   []string{serviceManagerPath, "startup"},
		Stdin:  os.Stdin,
		Stderr: os.Stderr,
		Stdout: os.Stdout,
		Dir:    "/",
		Env:    append(os.Environ(), "PATH=/usr/bin:/usr/sbin"),
	}

	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("failed to start service manager %v", err)
	}

	return cmd.Process, nil
}
