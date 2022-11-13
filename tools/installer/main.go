/*
Copyright © 2022 Dieter Bocklandt <dieterbocklandt@gmail.com>

*/
package installer

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"text/template"

	"github.com/schollz/progressbar/v3"
)

const autoInstallTemplate = "templates/autoinstall-user-data.tpl"
const saltSize = 16

var defaultTemplateVars = map[string]interface{}{
	"Gateway":      "172.27.20.1",
	"DNS":          "172.27.20.1",
	"SearchDomain": "siliconsheep.se",
}

func GenerateAutoInstallFile(templateVars map[string]interface{}) ([]byte, error) {
	tmpl, err := template.New(filepath.Base(autoInstallTemplate)).ParseFiles(autoInstallTemplate)
	if err != nil {
		return nil, err
	}

	mergedTemplateVars := make(map[string]interface{})

	for key, value := range defaultTemplateVars {
		mergedTemplateVars[key] = value
	}

	for key, value := range templateVars {
		mergedTemplateVars[key] = value
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, mergedTemplateVars); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func DownloadUbuntuISO(ubuntuVersion string, isoPath string) (string, error) {
	output, _ := filepath.Abs(filepath.Join(isoPath, fmt.Sprintf("ubuntu-%s.iso", ubuntuVersion)))
	if _, err := os.Stat(output); err == nil {
		fmt.Println("INFO: Ubuntu ISO already downloaded, reusing file.")
		return output, nil
	}

	req, _ := http.NewRequest("GET", fmt.Sprintf("http://se.releases.ubuntu.com/%s/ubuntu-%s-live-server-amd64.iso", ubuntuVersion, ubuntuVersion), nil)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Println("ERROR: Could not download Ubuntu ISO.")
		return "", err
	}
	defer resp.Body.Close()

	f, err := os.OpenFile(output, os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Printf("ERROR: Could not write to destination file: %s\n", output)
		return "", err
	}
	defer f.Close()

	bar := progressbar.DefaultBytes(
		resp.ContentLength,
		fmt.Sprintf("Downloading Ubuntu %s", ubuntuVersion),
	)
	io.Copy(io.MultiWriter(f, bar), resp.Body)

	return output, nil
}
