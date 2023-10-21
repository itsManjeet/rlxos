package ignite

import "path"

func (builder *Ignite) SourceDir() string {
	return path.Join(builder.CachePath, "sources")
}

func (builder *Ignite) ArtifactDir() string {
	return path.Join(builder.CachePath, "cache")
}

func (builder *Ignite) TempDir() string {
	return path.Join(builder.CachePath, "temp")
}

func (builder *Ignite) LogDir() string {
	return path.Join(builder.CachePath, "logs")
}
