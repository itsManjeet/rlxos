package appimage

type AppImage struct {
	filepath string
	config   map[string]string
}

func Load(filepath string) (*AppImage, error) {
	config, err := readConfig(filepath)
	if err != nil {
		return nil, err
	}

	return &AppImage{
		filepath: filepath,
		config:   config,
	}, nil
}
