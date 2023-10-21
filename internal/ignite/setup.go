package ignite

import (
	"fmt"
	"os"
	"path"
	"rlxos/internal/container"
	"rlxos/internal/element"
)

type SetupType int

const (
	SETUP_TYPE_BUILD SetupType = iota
	SETUP_TYPE_SHELL
)

func (builder *Ignite) Setup(setupType SetupType, elementId string, elementInfo *element.Element) (*container.Container, error) {
	hostRoot, err := os.MkdirTemp(builder.TempDir(), fmt.Sprintf("%s-*", elementInfo.Id))
	if err != nil {
		return nil, fmt.Errorf("failed to create temporary dir %s", err)
	}

	cntr := &container.Container{
		Image:    builder.Container,
		HostRoot: hostRoot,
		Environ: append(elementInfo.Environ,
			"GO111MODULE=auto",
			"GOPATH=/go",
			"SOURCE_DATA_EPOCH=1697043986"),
		Logfile: builder.LogDir() + "/" + elementInfo.Id + ".log",
		Binds: map[string]string{
			"/cache": path.Join(builder.ArtifactDir()),
		},
	}

	if setupType == SETUP_TYPE_SHELL {
		for _, env := range builder.Shell.Environ {
			cntr.Environ = append(cntr.Environ, os.ExpandEnv(env))
		}
		for _, bind := range builder.Shell.Bind {
			target := bind.Target
			if target == "" {
				target = bind.Source
			}
			if bind.ReadOnly {
				target += ":ro"
			}
			cntr.Binds[os.ExpandEnv(target)] = os.ExpandEnv(bind.Source)
		}
	} else {
		cntr.Binds = map[string]string{
			"/cache":           path.Join(builder.ArtifactDir()),
			"/files:ro":        path.Join(builder.projectPath, "files"),
			"/patches:ro":      path.Join(builder.projectPath, "patches"),
			"/go/src/rlxos:ro": builder.projectPath,
		}

		for _, p := range []container.PathId{container.BUILD_ROOT, container.INSTALL_ROOT} {
			if err := os.MkdirAll(cntr.HostPath(p), 0755); err != nil {
				return nil, fmt.Errorf("failed to create required path %s: %v", string(p), err)
			}
			cntr.Binds[cntr.ContainerPath(p)] = cntr.HostPath(p)
		}
	}

	if err := cntr.New(); err != nil {
		return nil, fmt.Errorf("failed to create container %v", err)
	}

	list, err := builder.Resolve(element.DependencyAll, elementId)
	if err != nil {
		return nil, err
	}
	if len(list) > 1 {
		list = list[:len(list)-1]
		for _, l := range list {
			if err := builder.Integrate(cntr, l.Value, "/"); err != nil {
				return nil, err
			}
		}
	}

	if len(elementInfo.Include) > 0 {
		var dependencyType element.DependencyType = element.DependencyRunTime
		if val, ok := elementInfo.Variables["include-depends"]; ok {
			switch val {
			case "true", "yes":
				dependencyType = element.DependencyRunTime
			case "false", "no":
				dependencyType = element.DependencyNone
			}
		}

		includeList, err := builder.Resolve(dependencyType, elementInfo.Include...)
		if err != nil {
			return nil, err
		}

		if len(includeList) > 0 {
			includeRootDir, ok := elementInfo.Variables["include-root"]
			if !ok {
				includeRootDir = path.Join("/", "pkg", elementInfo.Id)
			}
			if err := cntr.Mkdir(includeRootDir); err != nil {
				return nil, err
			}
			for _, l := range includeList {

				if err := builder.Integrate(cntr, l.Value, includeRootDir); err != nil {
					return nil, err
				}
			}
		}
	}

	if setupType == SETUP_TYPE_SHELL {
		if err := builder.Integrate(cntr, elementInfo, "/"); err != nil {
			return nil, err
		}
	}

	return cntr, nil
}
