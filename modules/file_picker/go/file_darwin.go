package file_picker

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/pkg/errors"
)

func fileFilter(method string, extensions []string, size int, multi bool) (string, error) {
	switch method {
	case "any":
		if multi {
			return "*", nil
		}
		return `"public.item"`, nil
	case "image":
		if multi {
			return "jpg, jpeg, bmp, gif, png", nil
		}
		return `"public.image"`, nil
	case "audio":
		if multi {
			return "mp3, wav, midi, ogg, aac", nil
		}
		return `"public.audio"`, nil
	case "video":
		if multi {
			return "webm, mpeg, mkv, mp4, avi, mov, flv", nil
		}
		return `"public.movie"`, nil
	case "media":
		if multi {
			return "webm, mpeg, mkv, mp4, avi, mov, flv, jpg, jpeg, bmp, gif, png", nil
		}
		return `"public.audiovisual-content"`, nil
	case "custom":
		var i int
		var filters = ""
		for i = 0; i < size; i++ {
			filters += extensions[i]
			if i < size-1 {
				filters += ", "
			}
		}
		return filters, nil
	default:
		return "", errors.New("unknown method")
	}

}

func fileDialog(title string, filter string) (string, error) {
	osascript, err := exec.LookPath("osascript")
	if err != nil {
		return "", err
	}

	output, err := exec.Command(osascript, "-e", `choose file of type {`+filter+`} with prompt "`+title+`"`).Output()
	if err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			fmt.Printf("miguelpruivo/plugins_flutter_file_picker/go: file dialog exited with code %d and output `%s`\n", exitError.ExitCode(), string(output))
			return "", nil // user probably canceled or closed the selection window
		}
		return "", errors.Wrap(err, "failed to open file dialog")
	}

	trimmedOutput := strings.TrimSpace(string(output))

	pathParts := strings.Split(trimmedOutput, ":")
	path := string(filepath.Separator) + filepath.Join(pathParts[1:]...)
	return path, nil
}

func dirDialog(title string) (string, error) {
	osascript, err := exec.LookPath("osascript")
	if err != nil {
		return "", err
	}

	output, err := exec.Command(osascript, "-e", `choose folder with prompt "`+title+`"`).Output()
	if err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			fmt.Printf("miguelpruivo/plugins_flutter_file_picker/go: folder dialog exited with code %d and output `%s`\n", exitError.ExitCode(), string(output))
			return "", nil // user probably canceled or closed the selection window
		}
		return "", errors.Wrap(err, "failed to open folder dialog")
	}

	trimmedOutput := strings.TrimSpace(string(output))

	pathParts := strings.Split(trimmedOutput, ":")
	path := string(filepath.Separator) + filepath.Join(pathParts[1:]...)
	return path, nil
}
