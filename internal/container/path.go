package container

import "path"

const (
	BUILD_ROOT   = "build-root"
	INSTALL_ROOT = "install-root"
)

type PathId string

func (container *Container) HostPath(pathId PathId) string {
	return container.pathMapping(container.HostRoot, pathId)
}

func (container *Container) ContainerPath(pathId PathId) string {
	return container.pathMapping("/", pathId)
}

func (container *Container) pathMapping(root string, pathId PathId) string {
	return path.Join(root, string(pathId))
}
