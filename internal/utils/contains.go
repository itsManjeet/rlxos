package utils

func Contains(list []string, value string) bool {
	for _, i := range list {
		if i == value {
			return true
		}
	}
	return false
}
