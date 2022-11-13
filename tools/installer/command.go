/*
Copyright © 2022 Dieter Bocklandt <dieterbocklandt@gmail.com>

*/
package installer

import (
	"bytes"
	"errors"
	"fmt"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"

	"github.com/schollz/progressbar/v3"
	"github.com/siliconsheep/homelab/tools/utils"
)

const partitionInfoRegex string = `-append_partition\s+(?P<Number>\d+)\s+(?P<ID>\w+)\s+--interval:local_fs:(?P<OffsetStart>\d+)d-(?P<OffsetEnd>\d+)d`

type commandResult struct {
	Stdout     string
	Stderr     string
	Resultcode int
	Error      error
}

type partitionInfo struct {
	PartitionNumber int
	Id              string
	OffsetStart     int
	OffsetEnd       int
}

type ISOParams struct {
	SourceFiles      string
	Name             string
	GrubImagePath    string
	EFIImagePath     string
	EFIPartitionInfo *partitionInfo
}

func (p *partitionInfo) Count() int {
	return p.OffsetEnd - p.OffsetStart + 1
}

func runCommandWithWorkingDir(command string, params []string, workingDir string, description string) *commandResult {
	var stdout, stderr bytes.Buffer
	result := commandResult{}

	_, err := exec.LookPath(command)
	if err != nil {
		result.Error = err
		result.Resultcode = 255
		return &result
	}

	if description == "" {
		description = fmt.Sprintf("Running command %s %s", command, strings.Join(params, " "))
	}

	bar := progressbar.Default(-1, description)

	cmd := exec.Command(command, params...)
	cmd.Dir = workingDir
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err = cmd.Run()

	bar.Finish()

	if err != nil {
		result.Error = err
		if exitError, ok := err.(*exec.ExitError); ok {
			result.Resultcode = exitError.ExitCode()
		} else {
			result.Resultcode = 1
		}

		return &result
	}

	result.Stdout, result.Stderr = string(stdout.Bytes()), string(stderr.Bytes())

	return &result
}

func runCommand(command string, params []string, description string) *commandResult {
	return runCommandWithWorkingDir(command, params, "", description)
}

func GetEFIPartitionInfo(isoPath string) (*partitionInfo, error) {
	r, err := regexp.Compile(partitionInfoRegex)
	if err != nil {
		return nil, err
	}

	cmdResult := runCommand("xorriso", []string{
		"-indev",
		isoPath,
		"-report_el_torito",
		"as_mkisofs",
	}, "Getting EFI partition info")

	if cmdResult.Error != nil {
		return nil, cmdResult.Error
	}

	match := r.FindStringSubmatch(cmdResult.Stdout)

	results := map[string]string{}
	for i, name := range match {
		results[r.SubexpNames()[i]] = name
	}

	if len(results) == 0 {
		return nil, errors.New("Could not find EFI partition")
	}

	partitionNumber, _ := strconv.Atoi(results["Number"])
	offsetStart, _ := strconv.Atoi(results["OffsetStart"])
	offsetEnd, _ := strconv.Atoi(results["OffsetEnd"])

	return &partitionInfo{
		PartitionNumber: partitionNumber,
		Id:              results["ID"],
		OffsetStart:     offsetStart,
		OffsetEnd:       offsetEnd,
	}, nil
}

func ExtractBytesFromImage(isoPath string, byteSize int, offset int, count int, destinationPath string) error {
	commandParams := []string{
		fmt.Sprintf("if=%s", isoPath),
		fmt.Sprintf("bs=%d", byteSize),
		fmt.Sprintf("count=%d", count),
		fmt.Sprintf("of=%s", destinationPath),
	}

	if offset > 0 {
		commandParams = append(commandParams, fmt.Sprintf("skip=%d", offset))
	}

	cmdResult := runCommand("dd", commandParams, fmt.Sprintf("Extracting %d bytes from %s to %s", count*byteSize, filepath.Base(isoPath), filepath.Base(destinationPath)))

	if cmdResult.Error != nil {
		return cmdResult.Error
	}

	return nil
}

func ExtractISO(isoPath string, destinationPath string) error {
	isoPath, err := filepath.Abs(isoPath)
	if err != nil {
		return err
	}

	destinationPath, err = filepath.Abs(destinationPath)
	if err != nil {
		return err
	}

	cmdResult := runCommand("xorriso", []string{
		"-osirrox",
		"on",
		"-indev",
		isoPath,
		"-extract",
		"/",
		destinationPath,
	}, "Extracting Ubuntu ISO")

	if cmdResult.Error != nil {
		return cmdResult.Error
	}

	// Chmod the extracted files as some of them are read-only
	if err = utils.ChmodR(destinationPath, 0755); err != nil {
		return err
	}

	return nil
}

func RepackISO(isoParams *ISOParams, outputDir string) error {
	outputPath, _ := filepath.Abs(filepath.Join(outputDir, isoParams.Name))
	workingDirectory, _ := filepath.Abs(isoParams.SourceFiles)

	cmdResult := runCommandWithWorkingDir("xorriso", []string{
		"-as",
		"mkisofs",
		"-r",
		"-V",
		isoParams.Name,
		"-o",
		outputPath,
		"--grub2-mbr",
		isoParams.GrubImagePath,
		"-partition_offset",
		"16",
		"--mbr-force-bootable",
		"-append_partition",
		fmt.Sprint(isoParams.EFIPartitionInfo.PartitionNumber),
		isoParams.EFIPartitionInfo.Id,
		isoParams.EFIImagePath,
		"-appended_part_as_gpt",
		"-iso_mbr_part_type",
		"a2a0d0ebe5b9334487c068b6b72699c7",
		"-c",
		"/boot.catalog",
		"-b",
		"/boot/grub/i386-pc/eltorito.img",
		"-no-emul-boot",
		"-boot-load-size",
		"4",
		"-boot-info-table",
		"--grub2-boot-info",
		"-eltorito-alt-boot",
		"-e",
		"--interval:appended_partition_2:::",
		"-no-emul-boot",
		workingDirectory,
	}, workingDirectory, "Repacking Ubuntu ISO")

	if cmdResult.Error != nil {
		return cmdResult.Error
	}

	return nil
}
