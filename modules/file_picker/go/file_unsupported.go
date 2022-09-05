// +build !darwin,!linux,!windows

package file_picker

import (
	"github.com/pkg/errors"
)

func fileFilter(method string) (string, error) {
	return "", errors.New("platform unsupported")
}

func fileDialog(title string, filter string) (string, error) {
	return "", errors.New("platform unsupported")
}

func dirDialog(title string, filter string) (string, error) {
	return "", errors.New("platform unsupported")
}
