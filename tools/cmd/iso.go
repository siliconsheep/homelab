/*
Copyright © 2022 Dieter Bocklandt <dieterbocklandt@gmail.com>

*/
package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/siliconsheep/homelab/tools/installer"
	"github.com/siliconsheep/homelab/tools/utils"

	"github.com/spf13/cobra"
)

// isoCmd represents the usb command
var isoCmd = &cobra.Command{
	Use:   "iso",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: RunCommand,
}

func init() {
	createCmd.AddCommand(isoCmd)
	isoCmd.Flags().StringP("ubuntu-version", "U", "", "Ubuntu version to use as base image.")
	isoCmd.Flags().StringP("hostname", "H", "", "Hostname to use for the new system.")
	isoCmd.Flags().StringP("ip", "i", "", "IP address to use for the new system.")
	isoCmd.Flags().StringP("username", "u", "k3s", "Username for the default user.")
	isoCmd.Flags().StringP("password", "p", "k3s", "Password for the default user.")
	isoCmd.Flags().StringP("ssh-key-filename", "", "", "SSH public key to allow in the new system.")
	isoCmd.Flags().StringP("ssh-key-github", "", "", "GitHub user whose SSH public key to allow in the new system.")
	isoCmd.Flags().StringP("workspace-directory", "w", "../workspace", "Workspace directory. Defaults to ../workspace")
	isoCmd.MarkFlagRequired("ubuntu-version")
	isoCmd.MarkFlagRequired("hostname")
	isoCmd.MarkFlagRequired("ip")
	isoCmd.MarkFlagsMutuallyExclusive("ssh-key-filename", "ssh-key-github")
}

func RunCommand(cmd *cobra.Command, args []string) {
	ubuntuVersion, _ := cmd.Flags().GetString("ubuntu-version")
	hostname, _ := cmd.Flags().GetString("hostname")
	ip, _ := cmd.Flags().GetString("ip")
	username, _ := cmd.Flags().GetString("username")
	password, _ := cmd.Flags().GetString("password")
	wsPath, _ := cmd.Flags().GetString("workspace-directory")

	outputPath := filepath.Join(wsPath, "output")
	extractPath := filepath.Join(wsPath, "extracted")

	utils.CreateDirs(outputPath, extractPath)

	isoPath, err := installer.DownloadUbuntuISO(ubuntuVersion, wsPath)
	if err != nil {
		fmt.Printf("ERROR: downloading Ubuntu ISO, %v", err)
		os.Exit(1)
	}

	partInfo, err := installer.GetEFIPartitionInfo(isoPath)
	if err != nil {
		fmt.Printf("ERROR: getting EFI partition info, %v", err)
		os.Exit(1)
	}

	// Extract MBR from ISO
	mbrPath, _ := filepath.Abs(filepath.Join(wsPath, "boot_hybrid.img"))
	if err = installer.ExtractBytesFromImage(isoPath, 1, 0, 432, mbrPath); err != nil {
		fmt.Printf("ERROR: extracting MBR partition, %v", err)
		os.Exit(1)
	}

	// Extract EFI partition from ISO
	efiPath, _ := filepath.Abs(filepath.Join(wsPath, "efi.img"))
	if err = installer.ExtractBytesFromImage(isoPath, 512, partInfo.OffsetStart, partInfo.Count(), efiPath); err != nil {
		fmt.Printf("ERROR: extracting EFI partition, %v", err)
		os.Exit(1)
	}

	// Extract ISO
	if err = installer.ExtractISO(isoPath, extractPath); err != nil {
		fmt.Printf("ERROR: extracting ISO, %v", err)
		os.Exit(1)
	}

	// Update grub.cfg and loopback.cfg
	filesToUpdate := []string{"boot/grub/grub.cfg", "boot/grub/loopback.cfg"}
	for _, file := range filesToUpdate {
		fullPath := filepath.Join(extractPath, file)
		if err = installer.ReplaceLinesInFile(fullPath, `\s---`, `autoinstall ds=nocloud\;s=/cdrom/nocloud/ ---`); err != nil {
			fmt.Printf("ERROR: updating %q, %v", file, err)
			os.Exit(1)
		}

		if err = installer.ReplaceLinesInFile(fullPath, `timeout=30`, `timeout=5`); err != nil {
			fmt.Printf("ERROR: updating %q, %v", file, err)
			os.Exit(1)
		}

		if err = installer.ReplaceLinesInFile(fullPath, `Try\sor\sInstall\sUbuntu\sServer`, fmt.Sprintf("Install Ubuntu Server for host %s", hostname)); err != nil {
			fmt.Printf("ERROR: updating %q, %v", file, err)
			os.Exit(1)
		}

		// Files have changed, calculte new checksums
		var newHash string
		if newHash, err = utils.CalculateMD5Hash(fullPath); err != nil {
			fmt.Printf("ERROR: calculating MD5 checksum of %s, %v", file, err)
			os.Exit(1)
		}

		if err = installer.ReplaceLinesInFile(filepath.Join(extractPath, "md5sum.txt"), `^\w+\s+\./`+file, fmt.Sprintf("%s  ./%s", newHash, file)); err != nil {
			fmt.Printf("ERROR: updating MD5 hash of %q in md5sum.txt, %v", file, err)
			os.Exit(1)
		}
	}

	// Add userdata and metadata (after templating it)
	var sshPublicKey string

	if sshKeyFilename, _ := cmd.Flags().GetString("ssh-key-filename"); sshKeyFilename != "" {
		sshPublicKeyBytes, err := os.ReadFile(sshKeyFilename)
		if err != nil {
			fmt.Printf("ERROR: reading SSH public key from file, %v", err)
			os.Exit(1)
		}
		sshPublicKey = strings.TrimSpace(string(sshPublicKeyBytes))
	} else if sshKeyGithub, _ := cmd.Flags().GetString("ssh-key-github"); sshKeyGithub != "" {
		sshPublicKey, err = utils.DownloadGHSSHKey(sshKeyGithub)
		if err != nil {
			fmt.Printf("ERROR: downloading SSH public key from GitHub, %v", err)
			os.Exit(1)
		}
	} else {
		fmt.Printf("ERROR: No SSH public key specified.\n")
		cmd.Usage()
		os.Exit(1)
	}

	templateVars := map[string]interface{}{
		"Hostname":     hostname,
		"IP":           ip,
		"SSHPublicKey": sshPublicKey,
		"Username":     username,
		"PasswordHash": utils.GeneratePassword(password),
	}

	autoInstallContent, err := installer.GenerateAutoInstallFile(templateVars)
	if err != nil {
		fmt.Printf("ERROR: Could not generate autoinstall file, %v", err)
		os.Exit(1)
	}

	utils.WriteFile(filepath.Join(extractPath, "nocloud/user-data"), autoInstallContent)
	utils.WriteFile(filepath.Join(extractPath, "nocloud/meta-data"), []byte(""))

	// Repackage ISO
	isoParams := &installer.ISOParams{
		SourceFiles:      extractPath,
		Name:             fmt.Sprintf("ubuntu-%s-%s.iso", ubuntuVersion, hostname),
		GrubImagePath:    mbrPath,
		EFIImagePath:     efiPath,
		EFIPartitionInfo: partInfo,
	}

	if err = installer.RepackISO(isoParams, outputPath); err != nil {
		fmt.Printf("ERROR: Repacking ISO, %v", err)
		os.Exit(1)
	}
}
