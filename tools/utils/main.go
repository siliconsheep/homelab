package utils

import (
	"crypto/md5"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/tredoe/osutil/user/crypt/sha512_crypt"
)

func DownloadGHSSHKey(username string) (string, error) {
	response, err := http.Get(fmt.Sprintf("https://github.com/%s.keys", username))

	if err != nil {
		fmt.Println("ERROR: Could not download SSH key from GitHub.")
		return "", err
	}

	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		fmt.Println("ERROR: Could not read HTTP response from GitHub.")
		return "", err
	}

	return strings.TrimSpace(string(body)), nil
}

func CreateDirs(path ...string) error {
	for _, p := range path {
		os.RemoveAll(p)

		err := os.MkdirAll(p, 0755)
		if err != nil {
			return err
		}
	}
	return nil
}

func WriteFile(path string, content []byte) error {
	err := os.MkdirAll(filepath.Dir(path), 0755)
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(path, content, 0644)
	if err != nil {
		return err
	}
	return nil
}

func GeneratePassword(password string) string {
	c := sha512_crypt.New()

	hash, err := c.Generate([]byte(password), nil)
	if err != nil {
		panic(err)
	}

	return hash
}

func CalculateMD5Hash(path string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer file.Close()

	hash := md5.New()
	_, err = io.Copy(hash, file)

	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%x", hash.Sum(nil)), nil
}

func ChmodR(path string, filemode os.FileMode) error {
	return filepath.Walk(path, func(name string, info os.FileInfo, err error) error {
		if err == nil {
			err = os.Chmod(name, filemode)
		}
		return err
	})
}
