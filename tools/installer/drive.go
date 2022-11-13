/*
Copyright © 2022 Dieter Bocklandt <dieterbocklandt@gmail.com>

*/
package installer

import (
	"bufio"
	"io"
	"os"

	"github.com/schollz/progressbar/v3"
)

func CopyToUSB(src string, devicePath string) error {
	data := make([]byte, 4*1024*1024)

	in, err := os.Open(src)
	if err != nil {
		return err
	}
	reader := bufio.NewReader(in)
	defer in.Close()
	fi, err := in.Stat()
	if err != nil {
		return err
	}

	out, err := os.OpenFile(devicePath, os.O_WRONLY, 0644)
	if err != nil {
		return err
	}

	bar := progressbar.DefaultBytes(
		fi.Size(),
		"Writing to USB",
	)

	writer := io.MultiWriter(bufio.NewWriter(out), bar)
	defer out.Close()

	for {
		count, err := reader.Read(data)
		data = data[:count]

		if err == io.EOF {
			break
		} else if err != nil {
			return err
		}

		_, err = writer.Write(data)
		if err != nil {
			return err
		}
	}

	return nil
}
