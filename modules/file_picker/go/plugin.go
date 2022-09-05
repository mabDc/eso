package file_picker

import (
	"encoding/json"
	"github.com/gen2brain/dlgs"
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	"github.com/pkg/errors"
	"os"
	"path/filepath"
)

const channelName = "miguelruivo.flutter.plugins.filepicker"

type FilePickerPlugin struct{}

var _ flutter.Plugin = &FilePickerPlugin{} // compile-time type check

func (p *FilePickerPlugin) InitPlugin(messenger plugin.BinaryMessenger) error {
	channel := plugin.NewMethodChannel(messenger, channelName, plugin.JSONMethodCodec{})
	channel.CatchAllHandleFunc(p.handleFilePicker)
	return nil
}

func (p *FilePickerPlugin) handleFilePicker(methodCall interface{}) (reply interface{}, err error) {
	method := methodCall.(plugin.MethodCall).Method

	if "dir" == method {
		dirPath, err := dirDialog("Select a directory")
		if err != nil {
			return nil, errors.Wrap(err, "failed to open dialog picker")
		}
		return dirPath, nil
	}

	var arguments map[string]interface{}

	err = json.Unmarshal(methodCall.(plugin.MethodCall).Arguments.(json.RawMessage), &arguments)
	if err != nil {
		return nil, errors.Wrap(err, "failed to decode arguments")
	}

	var allowedExtensions []string

	// Parse extensions
	if arguments != nil && arguments["allowedExtensions"] != nil {
		allowedExtensions = make([]string, len(arguments["allowedExtensions"].([]interface{})))
		for i := range arguments["allowedExtensions"].([]interface{}) {
			allowedExtensions[i] = arguments["allowedExtensions"].([]interface{})[i].(string)
		}
	}

	selectMultiple, ok := arguments["allowMultipleSelection"].(bool) //method.Arguments.(bool)
	if !ok {
		return nil, errors.Wrap(err, "invalid format for argument, not a bool")
	}

	filter, err := fileFilter(method, allowedExtensions, len(allowedExtensions), selectMultiple)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get filter")
	}

	withData, ok := arguments["withData"].(bool)

	var selectedFilePaths []string

	if selectMultiple {
		filePaths, _, err := dlgs.FileMulti("Select one or more files", filter)
		if err != nil {
			return nil, errors.Wrap(err, "failed to open dialog picker")
		}

		selectedFilePaths = make([]string, len(filePaths))

		for i, filePath := range filePaths {
			selectedFilePaths[i] = filePath
		}
	} else {
		selectedFilePaths = make([]string, 1)

		filePath, err := fileDialog("Select a file", filter)
		if err != nil {
			return nil, errors.Wrap(err, "failed to open dialog picker")
		}

		selectedFilePaths[0] = filePath
	}

	result := make([]map[string]interface{}, len(selectedFilePaths))

	for i, filePath := range selectedFilePaths {
		file, err := os.Open(filePath)
		if err != nil {
			return nil, errors.Wrap(err, "Can't open selected file")
		}

		fi, err := file.Stat()
		if err != nil {
			return nil, errors.Wrap(err, "Can't open selected file")
		}

		var bytes []byte

		if withData {
			_, err := file.Read(bytes)
			if err != nil {
				return nil, errors.Wrap(err, "Can't read selected file")
			}
		}

		result[i] = map[string]interface{}{
			"path":  filePath,
			"name":  filepath.Base(filePath),
			"bytes": bytes,
			"size":  fi.Size(),
		}

		err = file.Close()
		if err != nil {
			return nil, errors.Wrap(err, "Can't close selected file after reading")
		}
	}

	return result, nil
}
