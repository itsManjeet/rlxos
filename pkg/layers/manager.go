package layers

type Manager struct {
	ServerUrl  string
	SearchPath []string
	RootDir    string
}

func (m *Manager) isDisabled(layerid string) bool {
	for _, id := range []string{".", "..", "rw", "work"} {
		if id == layerid {
			return true
		}

	}
	return false
}
