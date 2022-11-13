/*
Copyright © 2022 Dieter Bocklandt <dieterbocklandt@gmail.com>

*/
package cmd

import (
	"github.com/spf13/cobra"
)

// createCmd represents the create command
var createCmd = &cobra.Command{
	Use: "create",
}

func init() {
	rootCmd.AddCommand(createCmd)
}
