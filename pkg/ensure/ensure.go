package ensure

import "log"

func Output[T comparable](actual, expected T, format string, args ...interface{}) {
	if actual != expected {
		log.Fatalf(format, args...)
	}
}

func Foreach[T any](l []T, f func(l T) error) error {
	for _, v := range l {
		if err := f(v); err != nil {
			return err
		}
	}
	return nil
}
