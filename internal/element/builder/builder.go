package builder

import (
	"bufio"
	"crypto/sha256"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/internal/element"
	"rlxos/pkg/utils"
	"strings"
)

type BuildStatus int

const (
	BuildStatusWaiting BuildStatus = iota
	BuildStatusCached
)

func (b BuildStatus) String() string {
	switch b {
	case BuildStatusCached:
		return "CACHED"
	case BuildStatusWaiting:
		return "WAITING"
	}
	return "UNKNOWN"
}

type Pair struct {
	Path  string
	Value *element.Element
	State BuildStatus
}

type Builder struct {
	Container   string            `yaml:"container"`
	Variables   map[string]string `yaml:"variables"`
	Environ     []string          `yaml:"environ"`
	BuildTools  []BuildTool       `yaml:"build-tools"`
	Merge       []string          `yaml:"merge"`
	projectPath string
	cachePath   string
	pool        map[string]*element.Element
}

type BuildTool struct {
	Id          string   `yaml:"id"`
	TargetFiles []string `yaml:"target-files"`
	Script      string   `yaml:"script"`
}

func (b *Builder) Get(id string) (*element.Element, bool) {
	e, ok := b.pool[id]
	return e, ok
}

func (b *Builder) CacheFile(e *element.Element) (string, error) {
	sum := fmt.Sprint(e)
	s := sha256.New()
	s.Write([]byte(sum))
	depends := e.AllDepends(element.DependencyRunTime)

	for _, dep := range depends {
		dep_e, ok := b.Get(dep)
		if !ok {
			return "", fmt.Errorf("missing required package %s", dep)
		}
		s.Write([]byte(fmt.Sprint(dep_e)))
	}

	value := s.Sum(nil)

	return path.Join(b.cachePath, "cache", fmt.Sprintf("%x", value)), nil
}

func (b *Builder) Build(id string) error {
	e, ok := b.Get(id)
	if !ok {
		return fmt.Errorf("missing %s", id)
	}

	tolist := []string{}
	if len(e.Include) > 0 {
		tolist = append(tolist, e.Include...)
	}
	tolist = append(tolist, id)

	list, err := b.List(element.DependencyBuildTime, tolist...)
	if err != nil {
		return err
	}

	if len(list) > 1 {
		if len(list) > 1 {
			list = list[:len(list)-1]
		}

		for _, l := range list {
			log.Printf("[%s] %s\n", l.State, l.Path)
		}

		for _, l := range list {
			if l.State != BuildStatusCached {
				if err := b.buildElement(l.Value, l.Path); err != nil {
					return err
				}
			}
		}
	}

	if err := b.buildElement(e, id); err != nil {
		return err
	}
	return nil
}

func (b *Builder) buildElement(e *element.Element, id string) error {
	cachefile, err := b.CacheFile(e)
	if err != nil {
		return err
	}

	log.Println("setting up container for ", id)

	sourcesDir := path.Join(b.cachePath, "sources")
	packagesDir := path.Join(b.cachePath, "cache")
	tempdir := path.Join(b.cachePath, "temp")
	logDir := path.Join(b.cachePath, "logs")
	if err := os.MkdirAll(tempdir, 0755); err != nil {
		return fmt.Errorf("failed to create %s, %v", tempdir, err)
	}
	workdir, err := os.MkdirTemp(tempdir, fmt.Sprintf("%s-*", e.Id))
	if err != nil {
		return fmt.Errorf("failed to create temporary dir %s", err)
	}
	defer os.RemoveAll(workdir)
	srcdir := path.Join(workdir, "src")
	pkgdir := path.Join(workdir, "pkg", e.Id)
	for _, dir := range []string{sourcesDir, packagesDir, srcdir, logDir} {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return err
		}
	}

	logfile, err := os.OpenFile(path.Join(logDir, e.Id+".log"), os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0644)
	if err != nil {
		return fmt.Errorf("failed to open log file %v", err)
	}
	defer logfile.Close()

	logWriter := bufio.NewWriter(logfile)
	defer logWriter.Flush()

	errfile, err := os.OpenFile(path.Join(logDir, e.Id+".err"), os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0644)
	if err != nil {
		return fmt.Errorf("failed to open log file %v", err)
	}
	defer errfile.Close()

	errWriter := bufio.NewWriter(errfile)
	defer errWriter.Flush()

	environ := e.Environ
	environ = b.setEnv(environ, "pkgupd_pkgdir=/pkg/"+e.Id)
	environ = b.setEnv(environ, "pkgupd_srcdir=/src")
	environ = b.setEnv(environ, "FILES=/files")
	environ = b.setEnv(environ, "FILES_DIR=/files/"+e.Id)
	environ = b.setEnv(environ, "GO111MODULE=off")
	environ = b.setEnv(environ, "GOPATH=/go")

	container, err := CreateContainer(b.Container, environ, map[string]string{
		"/src":              srcdir,
		"/pkg":              path.Dir(pkgdir),
		"/cache":            packagesDir,
		"/files":            path.Join(b.projectPath, "files"),
		"/patches":          path.Join(b.projectPath, "patches"),
		"/go/src/rlxos/pkg": path.Join(b.projectPath, "pkg"),
		"/go/src/":          path.Join(b.projectPath, "vendor"),
		"/go/src/rlxos/src": path.Join(b.projectPath, "src"),
	})
	if err != nil {
		return fmt.Errorf("failed to create container %v", err)
	}
	defer container.Delete()

	list, err := b.List(element.DependencyAll, id)
	if err != nil {
		return err
	}
	if len(list) > 1 {
		list = list[:len(list)-1]
		for _, l := range list {
			if err := b.integrate(l.Value, "/", container, logWriter, errWriter, false); err != nil {
				return err
			}
		}
	}

	if len(e.Include) > 0 {
		includeList, err := b.List(element.DependencyRunTime, e.Include...)
		if err != nil {
			return err
		}
		if len(includeList) > 0 {
			includeRootDir, ok := e.Variables["include-root"]
			if !ok {
				includeRootDir = path.Join("/", "pkg", e.Id)
			}
			container.Run(logWriter, errWriter, []string{"mkdir", "-p", includeRootDir}, "/", []string{})
			for _, l := range includeList {

				if err := b.integrate(l.Value, includeRootDir, container, logWriter, errWriter, true); err != nil {
					return err
				}
			}
		}

	}

	log.Println("Building", e.Id)

	variables := map[string]string{}
	for key, value := range e.Variables {
		variables[key] = value
	}

	variables["configure"] = e.Configure
	variables["compile"] = e.Compile
	variables["install"] = e.Install
	variables["build-dir"] = "_pkgupd_build_dir"

	variables["build-root"] = "/src"
	variables["install-root"] = "/pkg/" + e.Id

	builddir := e.BuildDir
	for _, url := range e.Sources {
		filename := path.Base(url)
		if idx := strings.Index(url, "::"); idx != -1 {
			filename = url[:idx]
			url = url[idx+2:]
		}
		filepath := path.Join(sourcesDir, filename)
		if _, err := os.Stat(filepath); err != nil {
			if isUrl(url) {
				log.Printf("Getting %s from %s\n", filename, url)
				if err := utils.DownloadFile(filepath, url); err != nil {
					return err
				}
			} else {
				url = path.Join(b.projectPath, url)
				log.Printf("Copying %s from %s\n", filename, url)
				if err := utils.CopyFile(url, filepath); err != nil {
					return err
				}
			}
		}

		var bin string
		var args []string
		if isArchive(filepath) {
			bin = "bsdtar"
			args = []string{
				"-xf", filepath, "-C", srcdir,
			}
			if len(builddir) == 0 {
				builddir_, err := exec.Command("sh", "-c", "bsdtar -tf "+filepath+" | head -n1 | cut -d '/' -f1").CombinedOutput()
				if err != nil {
					return fmt.Errorf("%s, %s", string(builddir_), err)
				}
				builddir = strings.Trim(string(builddir_), "\n ")
			}

		} else {
			bin = "cp"
			args = []string{filepath, srcdir}
		}

		if data, err := exec.Command(bin, args...).CombinedOutput(); err != nil {
			return fmt.Errorf("ERROR: %s, %v", string(data), err)
		}

	}

	absBuildPath := path.Join(srcdir, builddir)
	containerWordDir := path.Join("/", "src", builddir)
	if len(e.PreScript) != 0 {
		if err := container.Run(logWriter, errWriter, []string{"sh", "-ec", resolveVariables(e.PreScript, variables)}, containerWordDir, environ); err != nil {
			container.RescueShell()
			return err
		}
	}

	switch e.BuildType {
	case "import":
		source := e.Config.Source
		target := e.Config.Target
		log.Println("import files")
		if data, err := exec.Command("fakeroot", "rsync", "-ar", path.Join(srcdir, source)+"/", path.Join(pkgdir, target)).CombinedOutput(); err != nil {
			return fmt.Errorf("%v, %s", string(data), err)
		}

	case "system":
		if len(e.Script) > 0 {
			if err := container.Run(logWriter, errWriter, []string{"chroot", path.Join("/", "pkg", path.Base(pkgdir)), "/bin/bash", "-ec", resolveVariables(e.Script, variables)}, "/", environ); err != nil {
				log.Println("ERROR:", err)
				container.RescueShell()
				return err
			}
		}

	default:
		var t *BuildTool
		script := e.Script
		if len(e.Script) == 0 {
			isFileExists := func(d string, list []string) bool {
				for _, f := range list {
					if _, err := os.Stat(path.Join(d, f)); err == nil {
						return true
					} else if errors.Is(err, os.ErrNotExist) {
						return false
					} else {
						log.Println("unknown error file checking file existince", err)
					}
				}
				return false
			}
			if len(e.BuildType) == 0 {
				for _, tool := range b.BuildTools {
					if isFileExists(absBuildPath, tool.TargetFiles) {
						t = &tool
						break
					}
				}
				if t == nil {
					err := fmt.Errorf("no suitable build file found at %s", absBuildPath)
					log.Println("ERROR:", err)
					container.RescueShell()
					return err
				}

			} else {
				for _, tool := range b.BuildTools {
					if tool.Id == e.BuildType {
						t = &tool
						break
					}
				}
				if t == nil {
					err := fmt.Errorf("invalid buildtool %s specified", e.BuildType)
					log.Println("ERROR:", err)
					container.RescueShell()
					return err
				}

			}

			script = t.Script
		}
		if err := container.Run(logWriter, errWriter, []string{"sh", "-ec", resolveVariables(script, variables)}, containerWordDir, environ); err != nil {
			container.RescueShell()
			return err
		}
	}

	if len(e.PostScript) != 0 {
		if err := container.Run(logWriter, errWriter, []string{"sh", "-ec", resolveVariables(e.PostScript, variables)}, containerWordDir, environ); err != nil {
			container.RescueShell()
			return err
		}
	}
	// Thanks to venom Linux https://github.com/venomlinux/scratchpkg/blob/master/pkgbuild#L214
	STRIP_COMMAND := `
	if [ "$nostrip" ]; then
	  for i in $nostrip; do
		xstrip="$xstrip -e $i"
	  done
	  FILTER="grep -v $xstrip"
	else
	  FILTER="cat"
	fi
		
	find . -type f -printf "%P\n" 2>/dev/null | $FILTER | while read -r binary ; do
	  case "$(file -bi "$binary")" in
		*application/x-sharedlib*)  # Libraries (.so)
		  ${CROSS_COMPILE}strip --strip-unneeded "$binary" 2>/dev/null ;;
		*application/x-pie-executable*)  # Libraries (.so)
		  ${CROSS_COMPILE}strip --strip-unneeded "$binary" 2>/dev/null ;;
		*application/x-archive*)    # Libraries (.a)
		  ${CROSS_COMPILE}strip --strip-debug "$binary" 2>/dev/null ;;
		*application/x-object*)
		  case "$binary" in
			*.ko)                   # Kernel module
			  ${CROSS_COMPILE}strip --strip-unneeded "$binary" 2>/dev/null ;;
			*)
			  continue;;
		  esac;;
		*application/x-executable*) # Binaries
		  ${CROSS_COMPILE}strip --strip-all "$binary" 2>/dev/null ;;
		*)
		  continue ;;
	  esac
	done`
	if e.BuildType == "system" {
		log.Println("compressing image", path.Base(cachefile), " from ", pkgdir)
		if err := container.Run(logWriter, errWriter, []string{"mksquashfs", path.Join("/", "pkg", path.Base(pkgdir)), path.Join("/", "cache", path.Base(cachefile)), "-comp", "zstd", "-Xcompression-level", "19", "-noappend"}, path.Join("/pkg"), environ); err != nil {
			container.RescueShell()
			return err
		}
	} else {
		if !e.NoStrip {
			environ := []string{}
			if len(e.SkipStrip) > 0 {
				environ = append(environ, "nostrip="+strings.Join(e.SkipStrip, " "))
			}
			if err := container.Run(logWriter, errWriter, []string{"sh", "-c", resolveVariables(STRIP_COMMAND, variables)}, path.Join("/pkg"), environ); err != nil {
				container.RescueShell()
				return err
			}
		}

		log.Println("compressing package", path.Base(cachefile), " from ", pkgdir)
		if err := container.Run(logWriter, errWriter, []string{"tar", "-caf", path.Join("/", "cache", path.Base(cachefile)), "-C", path.Join("/", "pkg", path.Base(pkgdir)), "."}, path.Join("/pkg"), environ); err != nil {
			container.RescueShell()
			return err
		}

		for _, split := range e.Split {
			splitDir := path.Join("/pkg", split.Into)
			if err := os.MkdirAll(splitDir, 0755); err != nil {
				return fmt.Errorf("failed to create split file dir, %s, %v", splitDir, err)
			}
			for _, file := range split.Files {
				splitSourceDir := path.Join("/", "pkg", e.Id, file)
				splitTargetDir := path.Join(splitDir, file)
				if err := container.Run(logWriter, errWriter, []string{"mkdir", "-p", path.Dir(splitTargetDir)}, "/", []string{}); err != nil {
					return fmt.Errorf("failed to create new dir %s %v", path.Dir(splitTargetDir), err)
				}

				if err := container.Run(logWriter, errWriter, []string{"mv", splitSourceDir, splitTargetDir}, "/", []string{}); err != nil {
					return fmt.Errorf("failed to move split file %s -> %s, %v", splitSourceDir, splitTargetDir, err)
				}
			}
			if err := container.Run(logWriter, errWriter, []string{"tar", "-caf", path.Join("/", "cache", path.Base(cachefile)+":"+split.Into), "-C", path.Join("/", "pkg", splitDir), "."}, path.Join("/pkg"), environ); err != nil {
				container.RescueShell()
				return err
			}
		}
	}
	log.Printf("%s built at %s", e.Id, cachefile)

	return nil

}

func (b *Builder) setEnv(environ []string, env string) []string {
	envVar := strings.Split(env, "=")[0]
	for i, e := range environ {
		if strings.HasPrefix(e, envVar+"=") {
			environ[i] = env
			return environ
		}
	}
	environ = append(environ, env)
	return environ
}

func resolveVariables(v string, variables map[string]string) string {
	for key, value := range variables {
		v = strings.ReplaceAll(v, "%{"+key+"}", value)
	}
	return v
}

func (b *Builder) integrate(e *element.Element, rootdir string, container *Container, logWriter *bufio.Writer, errWriter *bufio.Writer, noIntegrate bool) error {
	cachefile, err := b.CacheFile(e)
	if err != nil {
		return err
	}

	if e.BuildType == "system" {
		if err := container.Run(logWriter, errWriter, []string{"cp", path.Join("/", "cache", path.Base(cachefile)), path.Join(rootdir, e.Id)}, "/", []string{}); err != nil {
			container.RescueShell()
			return err
		}
	} else {
		log.Println("Integrating", e.Id, path.Base(cachefile))
		if err := container.Run(logWriter, errWriter, []string{"tar", "-xf", path.Join("/", "cache", path.Base(cachefile)), "-C", rootdir}, "/", []string{}); err != nil {
			container.RescueShell()
			return err
		}
	}

	if !noIntegrate {
		if len(e.Integration) != 0 {
			log.Println("Executing integration command")
			if err := container.Run(logWriter, errWriter, []string{"sh", "-ec", resolveVariables(e.Integration, e.Variables)}, "/", []string{}); err != nil {
				container.RescueShell()
				return err
			}
		}
	} else if len(e.Integration) > 0 {
		if err := container.Run(logWriter, errWriter, []string{"mkdir", "-p", path.Join(rootdir, "var", "lib", "integrations")}, "/", []string{}); err != nil {
			return fmt.Errorf("failed to create intergations dir %v", err)
		}

		if err := container.Run(logWriter, errWriter, []string{"sh", "-ce", fmt.Sprintf("echo '%s' | tee %s", resolveVariables(e.Integration, e.Variables), path.Join(rootdir, "var", "lib", "integrations", e.Id))}, "/", []string{}); err != nil {
			return fmt.Errorf("failed to create intergations dir %v", err)
		}
	}

	return nil
}

func isUrl(url string) bool {
	for _, i := range []string{"http", "ftp"} {
		if strings.HasPrefix(url, i+"://") || strings.HasPrefix(url, i+"s://") {
			return true
		}
	}
	return false
}

func isArchive(p string) bool {
	for _, i := range []string{".tar", ".xz", ".gz", ".tgz", ".bzip2", ".zip", ".bz2", ".lz"} {
		if path.Ext(p) == i {
			return true
		}
	}
	return false
}
