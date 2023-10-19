package builder

import "path"

func (builder *Builder) SourceDir() string {
	return path.Join(builder.cachePath, "sources")
}

func (builder *Builder) ArtifactDir() string {
	return path.Join(builder.cachePath, "cache")
}

func (builder *Builder) TempDir() string {
	return path.Join(builder.cachePath, "temp")
}

func (builder *Builder) LogDir() string {
	return path.Join(builder.cachePath, "logs")
}
