package ignite

import (
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/internal/color"
	"rlxos/internal/container"
	"rlxos/internal/element"
	"rlxos/internal/utils"
	"strings"
)

// TODO: Need heavy refactoring

func (b *Ignite) Build(id string) error {
	e, ok := b.Get(id)
	if !ok {
		return fmt.Errorf("missing %s", id)
	}

	cachefile, _ := b.CacheFile(e)
	log.Println("CACHE_FILE:", cachefile)
	forceNeedRebuild := "false"
	if val, ok := e.Variables["force-rebuild"]; ok {
		forceNeedRebuild = val
	}

	if _, err := os.Stat(cachefile); err == nil && forceNeedRebuild == "false" && len(os.Getenv("REBUILD_PACKAGE")) == 0 {
		log.Printf("Element '%s' already cached '%s'\n", id, cachefile)
		return nil
	}

	tolist := []string{}
	if len(e.Include) > 0 {
		tolist = append(tolist, e.Include...)
	}
	tolist = append(tolist, id)

	list, err := b.Resolve(element.DependencyBuildTime, tolist...)
	if err != nil {
		return err
	}

	if len(list) > 1 {
		if len(list) > 1 {
			list = list[:len(list)-1]
		}

		for _, l := range list {
			color.Process("[%s] %s\n", l.State, l.Path)
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

func (b *Ignite) buildElement(e *element.Element, id string) error {
	cachefile, err := b.CacheFile(e)
	if err != nil {
		return err
	}

	color.Process("Setting up container for %s", id)

	cntr, err := b.Setup(SETUP_TYPE_BUILD, id, e)
	if err != nil {
		return fmt.Errorf("failed to setup container: %v", err)
	}
	defer cntr.Delete()

	color.Process("Building %s", e.Id)

	variables := map[string]string{}
	for key, value := range e.Variables {
		variables[key] = value
	}

	variables["configure"] = e.Configure
	variables["compile"] = e.Compile
	variables["install"] = e.Install
	variables["build-dir"] = "_rlxos_build_dir"

	variables["build-root"] = cntr.ContainerPath(container.BUILD_ROOT)
	variables["install-root"] = cntr.ContainerPath(container.INSTALL_ROOT)

	builddir := e.BuildDir
	for _, url := range e.Sources {
		filename := path.Base(url)
		if idx := strings.Index(url, "::"); idx != -1 {
			filename = url[:idx]
			url = url[idx+2:]
		}
		filepath := path.Join(b.SourceDir(), filename)
		if _, err := os.Stat(filepath); err != nil {
			if isUrl(url) {
				color.Process("Getting %s from %s\n", filename, url)
				if err := utils.DownloadFile(filepath, url); err != nil {
					return err
				}
			} else {
				url = path.Join(b.projectPath, url)
				color.Process("Copying %s from %s\n", filename, url)
				if err := utils.CopyFile(url, filepath); err != nil {
					return err
				}
			}
		}

		var bin string
		var args []string
		if isArchive(filepath) && e.Variables["no-extract"] != "true" {
			bin = "bsdtar"
			args = []string{
				"-xf", filepath, "-C", cntr.HostPath(container.BUILD_ROOT),
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
			args = []string{filepath, cntr.HostPath(container.BUILD_ROOT)}
		}

		if data, err := exec.Command(bin, args...).CombinedOutput(); err != nil {
			return fmt.Errorf("ERROR: %s, %v", string(data), err)
		}

	}

	containerBuildRoot := path.Join(cntr.ContainerPath(container.BUILD_ROOT), builddir)
	hostBuildRoot := path.Join(cntr.HostPath(container.BUILD_ROOT), builddir)
	if len(e.PreScript) != 0 {
		if err := cntr.ExecuteAt(containerBuildRoot, "sh", "-ec", resolveVariables(e.PreScript, variables)); err != nil {
			return cntr.ShellAt(containerBuildRoot, err)
		}
	}

	switch e.BuildType {
	case "system":
		if len(e.Script) > 0 {
			if err := cntr.Execute("chroot", cntr.ContainerPath(container.INSTALL_ROOT), "/bin/bash", "-ec", resolveVariables(e.Script, variables)); err != nil {
				return cntr.Shell(err)
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
						color.Error("unknown error file checking file existince %v", err)
					}
				}
				return false
			}
			if len(e.BuildType) == 0 {
				for _, tool := range b.BuildTools {
					if isFileExists(hostBuildRoot, tool.TargetFiles) {
						t = &tool
						break
					}
				}
				if t == nil {
					return cntr.Shell(fmt.Errorf("no suitable build file found at %s", hostBuildRoot))
				}

			} else {
				for _, tool := range b.BuildTools {
					if tool.Id == e.BuildType {
						t = &tool
						break
					}
				}
				if t == nil {
					return cntr.Shell(fmt.Errorf("invalid buildtool %s specified", e.BuildType))
				}

			}

			script = t.Script
		}
		scriptCode := resolveVariables(script, variables)
		args := []string{"sh", "-ec", scriptCode}
		if len(scriptCode) > 10000 {
			scriptCodePath := path.Join(hostBuildRoot, "_swupd_script_code")
			if err := ioutil.WriteFile(scriptCodePath, []byte(scriptCode), 0755); err != nil {
				return fmt.Errorf("script code is too large and failed to write script code %s %v", scriptCodePath, err)
			}
			args = []string{"sh", "-e", containerBuildRoot + "/_swupd_script_code"}
		}

		if err := cntr.ExecuteAt(containerBuildRoot, args...); err != nil {
			return cntr.ShellAt(containerBuildRoot, err)
		}
	}

	if len(e.PostScript) != 0 {
		if err := cntr.ExecuteAt(containerBuildRoot, "sh", "-ec", resolveVariables(e.PostScript, variables)); err != nil {
			return cntr.ShellAt(containerBuildRoot, err)
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
		color.Process("Compressing image %s from %s", path.Base(cachefile), cntr.ContainerPath(container.INSTALL_ROOT))
		if err := cntr.Execute("mksquashfs", cntr.ContainerPath(container.INSTALL_ROOT), path.Join("/cache", path.Base(cachefile)), "-comp", "zstd", "-Xcompression-level", "12", "-noappend"); err != nil {
			return cntr.ShellAt(containerBuildRoot, err)
		}
	} else {
		if strip := e.Variables["strip"]; strip != "false" {
			if err := cntr.ScriptAt(cntr.ContainerPath(container.INSTALL_ROOT), fmt.Sprintf("nostrip='%s' %s", strings.Join(e.SkipStrip, " "), resolveVariables(STRIP_COMMAND, variables))); err != nil {
				return cntr.Shell(err)
			}
		}

		color.Process("Compressing package %s from %s", path.Base(cachefile), cntr.ContainerPath(container.INSTALL_ROOT))
		if err := cntr.Execute("tar", "-I", "zstd", "-caf", path.Join("/cache", path.Base(cachefile)), "-C", cntr.ContainerPath(container.INSTALL_ROOT), "."); err != nil {
			return cntr.ShellAt(containerBuildRoot, err)
		}
	}
	color.Process("%s built at %s", e.Id, cachefile)

	return nil

}
