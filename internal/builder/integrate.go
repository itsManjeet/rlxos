package builder

import (
	"fmt"
	"path"
	"rlxos/internal/color"
	"rlxos/internal/container"
	"rlxos/internal/element"
)

func (b *Builder) Integrate(container *container.Container, e *element.Element, rootdir string) error {
	cachefile, err := b.CacheFile(e)
	if err != nil {
		return err
	}

	if e.BuildType == "system" {
		if err := container.Execute("cp", path.Join("/", "cache", path.Base(cachefile)), path.Join(rootdir, e.Id)); err != nil {
			return container.Shell(err)
		}
	} else {
		color.Process("Integrating %s, %s", e.Id, path.Base(cachefile))
		if err := container.Execute("tar", "-xf", path.Join("/", "cache", path.Base(cachefile)), "-C", rootdir); err != nil {
			return container.Shell(err)
		}
	}

	if len(e.Integration) > 0 {
		if err := container.Execute("mkdir", "-p", path.Join(rootdir, "var", "lib", "integrations")); err != nil {
			return fmt.Errorf("failed to create intergations dir %v", err)
		}

		if err := container.Script(fmt.Sprintf("echo '%s' | tee %s", resolveVariables(e.Integration, e.Variables), path.Join(rootdir, "var", "lib", "integrations", e.Id))); err != nil {
			return fmt.Errorf("failed to create intergations dir %v", err)
		}
	}

	if rootdir == "/" {
		if len(e.Integration) != 0 {
			color.Process("Executing integration command")
			if err := container.Execute("sh", "-ec", resolveVariables(e.Integration, e.Variables)); err != nil {
				return container.Shell(err)
			}
		}
	}

	return nil
}
