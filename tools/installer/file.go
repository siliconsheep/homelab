/*
Copyright © 2022 Dieter Bocklandt <dieterbocklandt@gmail.com>

*/
package installer

import (
	"bufio"
	"os"
	"regexp"
)

func ReplaceLinesInFile(filename string, pattern string, replacement string) error {
	r, err := regexp.Compile(pattern)
	if err != nil {
		return err
	}

	input, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer input.Close()

	output, err := os.Create(filename + ".tmp")
	if err != nil {
		return err
	}
	defer output.Close()

	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		replacedText := r.ReplaceAllString(scanner.Text(), replacement)
		output.WriteString(replacedText + "\n")
	}

	if err := scanner.Err(); err != nil {
		return err
	}

	if err = os.Rename(filename+".tmp", filename); err != nil {
		return err
	}

	return nil
}
