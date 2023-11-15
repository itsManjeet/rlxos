package element

import (
	"strings"
)

// Element holds the build configuration of rlxos package
type Element struct {
	Id      string `yaml:"id"`
	Version string `yaml:"version"`
	About   string `yaml:"about"`
	Release int    `yaml:"release"`

	Imports []string `yaml:"merge,omitempty"`

	Variables map[string]string `yaml:"variables,omitempty"`

	// Depends dependencies are required both during buildtime and runtime
	Depends []string `yaml:"depends,omitempty"`

	// BuildDepends dependencies are required during buildtime only
	BuildDepends []string `yaml:"build-depends,omitempty"`

	// BuildDepends dependencies are required during runtime only
	RunTimeDepends []string `yaml:"runtime-depends,omitempty"`

	BuildDir string `yaml:"build-dir,omitempty"`

	BuildType string `yaml:"build-type,omitempty"`

	Check []string `yaml:"check,omitempty"`

	Config struct {
		Source string `yaml:"source,omitempty"`
		Target string `yaml:"target,omitempty"`
	} `yaml:"config,omitempty"`

	Sources []string `yaml:"sources,omitempty"`
	Environ []string `yaml:"environ,omitempty"`
	Include []string `yaml:"include,omitempty"`

	PreScript  string `yaml:"pre-script,omitempty"`
	Script     string `yaml:"script,omitempty"`
	PostScript string `yaml:"post-script,omitempty"`

	Configure string `yaml:"configure,omitempty"`
	Compile   string `yaml:"compile,omitempty"`
	Install   string `yaml:"install,omitempty"`

	Integration string `yaml:"integration,omitempty"`

	Split []ElementSplit `yaml:"split,omitempty"`

	NoStrip   bool     `yaml:"no-strip,omitempty"`
	SkipStrip []string `yaml:"skip-strip,omitempty"`
}

// ElementSplit holds the information of sub package that can be
// seperated from rlxos Element
type ElementSplit struct {
	// Into defines the suffix name of package
	// for example Element 'gcc' contains sub package 'gcc:lib'
	Into string `yaml:"into"`

	// About provide a basic description about the sub package
	About string `yaml:"about"`

	// Files holds the list of files that need to be seperated from parent Element
	Files []string `yaml:"files"`
}

// Open open the rlxos package element file
func Open(filepath string, environ []string, variables map[string]string) (*Element, error) {
	elmnt := &Element{
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

	if err := elmnt.Import(filepath); err != nil {
		return nil, err
	}

	updatedVariables := map[string]string{}
	for key, value := range variables {
		updatedVariables[key] = value
	}

	if elmnt.Variables != nil {
		for key, value := range elmnt.Variables {
			updatedVariables[key] = value
		}
	}
	elmnt.Variables = updatedVariables
	if _, ok := elmnt.Variables["id"]; !ok {
		elmnt.Variables["id"] = elmnt.Id
	}
	if _, ok := elmnt.Variables["version"]; !ok {
		elmnt.Variables["version"] = elmnt.Version
	}

	// elmnt.Variables["release"] = fmt.Sprint(elmnt.Release)

	mergedEnviron := []string{}
	if environ != nil {
		mergedEnviron = append(mergedEnviron, environ...)
	}
	if elmnt.Environ != nil {
		mergedEnviron = append(mergedEnviron, elmnt.Environ...)
	}
	elmnt.Environ = mergedEnviron

	for i := range elmnt.Sources {
		elmnt.Sources[i] = elmnt.resolveVariable(elmnt.Sources[i])
	}

	for i := range elmnt.Environ {
		elmnt.Environ[i] = elmnt.resolveVariable(elmnt.Environ[i])
	}

	for key, value := range elmnt.Variables {
		elmnt.Variables[key] = elmnt.resolveVariable(value)
	}

	elmnt.BuildDir = elmnt.resolveVariable(elmnt.BuildDir)

	elmnt.PreScript = elmnt.resolveVariable(elmnt.PreScript)
	elmnt.Script = elmnt.resolveVariable(elmnt.Script)
	elmnt.PostScript = elmnt.resolveVariable(elmnt.PostScript)

	elmnt.Configure = elmnt.resolveVariable(elmnt.Configure)
	elmnt.Compile = elmnt.resolveVariable(elmnt.Compile)
	elmnt.Install = elmnt.resolveVariable(elmnt.Install)

	if collection, ok := elmnt.Variables["include-collection"]; ok {
		elmnt.Include = append(elmnt.Include, collection)
	}

	return elmnt, nil
}

func (elmnt *Element) resolveVariable(v string) string {
	for key, value := range elmnt.Variables {
		if len(value) != 0 {
			v = strings.ReplaceAll(v, "%{"+key+"}", value)
			v = strings.ReplaceAll(v, "%{"+key+":/-}", strings.ReplaceAll(key, "/", "-"))
		}
	}

	if version, ok := elmnt.Variables["version"]; ok {
		versionInfo := strings.Split(version, ".")
		if len(versionInfo) > 1 {
			v = strings.ReplaceAll(v, "%{version:1}", strings.Join(versionInfo[:len(versionInfo)-1], "."))
		}
		if len(versionInfo) > 2 {
			v = strings.ReplaceAll(v, "%{version:2}", strings.Join(versionInfo[:len(versionInfo)-2], "."))
		}
		v = strings.ReplaceAll(v, "%{version:_}", strings.ReplaceAll(version, ".", "_"))
		v = strings.ReplaceAll(v, "%{version:-}", strings.ReplaceAll(version, ".", "-"))
	}
	return v
}

type DependencyType int

const (
	DependencyBuildTime DependencyType = iota
	DependencyRunTime
	DependencyAll
	DependencyNone
)

func (elmnt *Element) GetDepends(dep DependencyType) []string {
	depends := []string{}
	if dep == DependencyNone {
		return depends
	}
	if elmnt.Depends != nil {
		depends = append(depends, elmnt.Depends...)
	}

	if dep == DependencyBuildTime || dep == DependencyAll {
		if elmnt.BuildDepends != nil {
			depends = append(depends, elmnt.BuildDepends...)
		}
	}

	if dep == DependencyRunTime || dep == DependencyAll {
		if elmnt.RunTimeDepends != nil {
			depends = append(depends, elmnt.RunTimeDepends...)
		}
	}

	return depends
}
