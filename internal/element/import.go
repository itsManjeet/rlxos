package element

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v2"
)

func (elmnt *Element) Import(filepath string) error {
	data, err := os.ReadFile(filepath)
	if err != nil {
		return fmt.Errorf("failed to import %s: %v", filepath, err)
	}

	local := &Element{
		Variables:      map[string]string{},
		Imports:        []string{},
		Depends:        []string{},
		BuildDepends:   []string{},
		RunTimeDepends: []string{},
		Check:          []string{},
		Sources:        []string{},
		Environ:        []string{},
		Include:        []string{},
		SkipStrip:      []string{},
	}
	if err := yaml.Unmarshal(data, local); err != nil {
		return fmt.Errorf("failed to import %s: %v", filepath, err)
	}

	for _, importfile := range local.Imports {
		if err := local.Import(importfile); err != nil {
			return fmt.Errorf("failed to import %s: %v", filepath, err)
		}
	}

	updateIfMissing := func(orig, updated string) string {
		if len(updated) == 0 {
			return orig
		}
		return updated
	}

	elmnt.Id = updateIfMissing(elmnt.Id, local.Id)
	elmnt.Version = updateIfMissing(elmnt.Version, local.Version)
	elmnt.About = updateIfMissing(elmnt.About, local.About)

	elmnt.BuildDir = updateIfMissing(elmnt.BuildDir, local.BuildDir)
	elmnt.BuildType = updateIfMissing(elmnt.BuildType, local.BuildType)

	elmnt.Depends = append(elmnt.Depends, local.Depends...)
	elmnt.BuildDepends = append(elmnt.BuildDepends, local.BuildDepends...)
	elmnt.RunTimeDepends = append(elmnt.RunTimeDepends, local.RunTimeDepends...)

	elmnt.Sources = append(elmnt.Sources, local.Sources...)
	elmnt.Include = append(elmnt.Include, local.Include...)

	elmnt.Check = append(local.Check, elmnt.Check...)
	elmnt.Environ = append(local.Environ, elmnt.Environ...)

	elmnt.Configure = local.Configure + elmnt.Configure
	elmnt.Compile = local.Compile + elmnt.Compile
	elmnt.Install = local.Install + elmnt.Install

	for key, value := range local.Variables {
		if _, ok := elmnt.Variables[key]; !ok {
			elmnt.Variables[key] = value
		}
	}

	return nil
}
