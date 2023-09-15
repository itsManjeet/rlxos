package utils

func Contains[T comparable](list []T, value T) bool {
	for _, i := range list {
		if i == value {
			return true
		}
	}
	return false
}
