package builder

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

func (builder *Builder) Setup(setupType SetupType, elementId string, elementInfo *element.Element) (*container.Container, error) {
	hostRoot, err := os.MkdirTemp(builder.TempDir(), fmt.Sprintf("%s-*", elementInfo.Id))
	if err != nil {
		return nil, fmt.Errorf("failed to create temporary dir %s", err)
	}

	container := &container.Container{
		Image:    builder.Container,
		HostRoot: hostRoot,
		Environ: append(elementInfo.Environ,
			"GO111MODULE=auto",
			"GOPATH=/go",
			"SOURCE_DATA_EPOCH=1697043986"),

		Logfile: builder.LogDir() + "/" + elementInfo.Id + ".log",

		Binds: map[string]string{
			"/cache":           path.Join(builder.cachePath, "cache"),
			"/files:ro":        path.Join(builder.projectPath, "files"),
			"/patches:ro":      path.Join(builder.projectPath, "patches"),
			"/go/src/rlxos:ro": builder.projectPath,
		},
	}

	if err := container.New(); err != nil {
		return nil, fmt.Errorf("failed to create container %v", err)
	}

	list, err := builder.Resolve(element.DependencyAll, elementId)
	if err != nil {
		return nil, err
	}
	if len(list) > 1 {
		list = list[:len(list)-1]
		for _, l := range list {
			if err := builder.Integrate(container, l.Value, "/"); err != nil {
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
			if err := container.Mkdir(includeRootDir); err != nil {
				return nil, err
			}
			for _, l := range includeList {

				if err := builder.Integrate(container, l.Value, includeRootDir); err != nil {
					return nil, err
				}
			}
		}
	}

	if setupType == SETUP_TYPE_SHELL {
		if err := builder.Integrate(container, elementInfo, "/"); err != nil {
			return nil, err
		}
	}

	return container, nil
}
