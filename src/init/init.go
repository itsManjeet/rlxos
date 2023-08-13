package main

import (
	"bufio"
	"fmt"
	"io/fs"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/moby/sys/mountinfo"
)

var (
	CMDLINE_ARGS []string
)

func main() {
	log.Println("INIT", VERSION)
	if err := syscall.Mount("/", "/", "auto", syscall.MS_REMOUNT, ""); err != nil {
		log.Println("failed to remount system as readwrite")
	}

	log.Println("Mounting virtual file system")
	mount("/run", 1777, "tmpfs", "tmpfs", "", syscall.MS_NOSUID|syscall.MS_NODEV)
	mount("/proc", 0755, "proc", "proc", "", syscall.MS_NOSUID|syscall.MS_NOEXEC|syscall.MS_NODEV)
	mount("/sys", 0755, "sysfs", "sysfs", "", syscall.MS_NOSUID|syscall.MS_NOEXEC|syscall.MS_NODEV)
	mount("/dev", 0755, "devtmpfs", "devtmpfs", "mode=0755", syscall.MS_NOSUID)
	mount("/dev/pts", 0755, "devpts", "devpts", "gid=5,mode=620", 0)
	mount("/dev/shm", 0755, "tmpfs", "tmpfs", "", syscall.MS_NOSUID|syscall.MS_NODEV)

	if cmdline, err := os.ReadFile("/proc/cmdline"); err != nil {
		CMDLINE_ARGS = strings.Split(string(cmdline), " ")
	} else {
		CMDLINE_ARGS = []string{}
	}

	log.Println("Loading modules")
	modules := map[string]string{}
	if _, err := os.Stat(MODULES_CONFIG); err == nil {

		file, err := os.Open(MODULES_CONFIG)
		if err == nil {
			defer file.Close()

			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				line := scanner.Text()
				line = strings.Trim(line, " \n")
				if len(line) == 0 || line[0] == '#' {
					continue
				}

				data := strings.Split(line, " ")
				if len(data) == 0 {
					continue
				}

				modules[data[0]] = getConfig("rd."+data[0], strings.Join(data[1:], ","))
			}
		}
	}

	if cmdlineModules := getConfig("rd.modules", ""); len(cmdlineModules) != 0 {
		for _, i := range strings.Split(cmdlineModules, ",") {
			modules[i] = getConfig("rd."+i, "")
		}
	}

	for module, args := range modules {
		cmdargs := []string{module}
		cmdargs = append(cmdargs, strings.Split(args, ",")...)
		if data, err := exec.Command("modprobe", cmdargs...).CombinedOutput(); err != nil {
			log.Printf("failed to load module (%s, %s) %s, %v", module, args, string(data), err)
		}
	}

	if err := exec.Command("udevd", "--daemon").Run(); err == nil {
		log.Println("Populating /dev with device nodes")

		exec.Command("udevadm", "trigger", "--action=add", "--type=subsystems").Run()
		exec.Command("udevadm", "trigger", "--action=add", "--type=devices").Run()
		exec.Command("udevadm", "trigger", "--action=change", "--type=devices").Run()

		exec.Command("udevadm", "settle").Run()

	} else {
		log.Println("failed to start udevd daemon", err)
	}

	log.Println("Activating swap")
	exec.Command("swapon", "-a")

	log.Println("Loading system clock")
	exec.Command("hwclock", "--hctosys", getConfig("rd.clock", "--localtime")).Run()

	if getConfig("rd.fastboot", "") != "skip" {
		if err := syscall.Mount("/", "/", "auto", syscall.MS_REMOUNT|syscall.MS_RDONLY, ""); err != nil {
			log.Println("failed to remount system as readwrite")
		}

		cmd := exec.Command("fsck", getConfig("rd.fsck", ""), "-a", "-A", "-C", "T")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				switch exitErr.ExitCode() {
				case 0:
				case 1:
					log.Println("filesystem errors were found and have been corrected")
				case 2, 3:
					log.Println("filesystem errors were found and have been corrected, but need to reboot system")
					time.Sleep(5 * time.Second)
					syscall.Reboot(syscall.LINUX_REBOOT_CMD_RESTART)
				default:
					log.Println("filesystem error were found and could not be fixed, system will restart in 10sec")
					time.Sleep(10 * time.Second)
					syscall.Reboot(syscall.LINUX_REBOOT_CMD_RESTART)
				}
			}
		}

		if err := syscall.Mount("/", "/", "auto", syscall.MS_REMOUNT, ""); err != nil {
			log.Println("failed to remount system as readwrite")
		}
	}

	log.Println("Mounting remaining file systems")
	exec.Command("mount", "--all", "--test-opts", "no_netdev").Run()

	hostname, err := os.Create("/proc/sys/kernel/hostname")
	if err == nil {
		defer hostname.Close()
		hostname.Write([]byte(getConfig("rd.hostname", "workstation")))
	}

	go func() {
		for {
			var status syscall.WaitStatus
			for i := 0; i < 10; i++ {
				syscall.Wait4(-1, &status, syscall.WNOHANG, nil)
			}
			syscall.Wait4(-1, &status, 0, nil)
		}
	}()

	startAllServices()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGUSR1, syscall.SIGCHLD, syscall.SIGALRM, syscall.SIGINT)

	go func() {
		sig := <-sigCh
		switch sig {
		case syscall.SIGUSR1, syscall.SIGCHLD, syscall.SIGALRM:
			cleanup(syscall.LINUX_REBOOT_CMD_POWER_OFF)
		case syscall.SIGINT:
			cleanup(syscall.LINUX_REBOOT_CMD_RESTART)
		}
	}()

	wg := sync.WaitGroup{}
	for i := 1; i <= 7; i++ {
		wg.Add(1)
		go startGetty(i, &wg)
	}
	wg.Wait()

}

func mount(dir string, mode fs.FileMode, source, fstype, opt string, flags uintptr) error {
	os.MkdirAll(dir, mode)
	if isMounted, _ := mountinfo.Mounted(dir); isMounted {
		if err := syscall.Mount(source, dir, fstype, flags, opt); err != nil {
			log.Println("failed to mount /run", err)
			return err
		}
	}
	return nil
}

func getConfig(key, fallback string) string {
	for _, i := range CMDLINE_ARGS {
		if strings.HasPrefix(i, key+"=") {
			return strings.Trim(i[len(key)+1:], " ")
		}
	}
	return fallback
}

func getAllProcess() (allProcess []*os.Process, err error) {
	if proc, err := ioutil.ReadDir("/proc"); err == nil {
		for _, f := range proc {
			if !f.IsDir() {
				continue
			}

			pid, err := strconv.Atoi(f.Name())
			if err != nil || pid < 2 {
				continue
			}

			cmdline := fmt.Sprintf("/proc/%d/cmdline", pid)
			if _, err := os.Stat(cmdline); os.IsNotExist(err) {
				continue
			}

			contents, err := os.ReadFile(cmdline)
			if err != nil || len(contents) == 0 {
				continue
			}
			p, err := os.FindProcess(pid)
			if err != nil {
				log.Printf("failed to get process %d, %v\n", pid, err)
				continue
			}
			allProcess = append(allProcess, p)
		}
	}
	return
}

func startGetty(i int, wg *sync.WaitGroup) {
	defer wg.Done()

	for {
		tty := fmt.Sprintf("tty%d", i)
		flags := getConfig("rd."+tty, "")
		cmd := exec.Command("getty", "--noclear", tty, flags)
		cmd.SysProcAttr = &syscall.SysProcAttr{
			Setsid: true,
		}
		cmd.Stdout = os.Stdout
		cmd.Stdin = os.Stdin
		cmd.Stderr = os.Stderr

		if err := cmd.Run(); err != nil {
			fmt.Printf("getty %s exit with error: %v\n", tty, err)
		}
		time.Sleep(time.Second * 2)
	}
}

func cleanup(code int) {
	processes, _ := getAllProcess()

	for _, proc := range processes {
		proc.Signal(syscall.SIGKILL)
	}

	for i := 0; i < 10; i++ {
		processes, _ = getAllProcess()
		if len(processes) == 0 {
			break
		}
		log.Println("Waiting for processes to die", len(processes))
		time.Sleep(1 * time.Second)
	}

	log.Println("Setting hardware clock")
	exec.Command("hwclock", "--systohc", getConfig("rd.clock", "--localtime")).Run()

	log.Println("Deactivating swap")
	exec.Command("swapoff", "-a")

	syscall.Reboot(code)
}
