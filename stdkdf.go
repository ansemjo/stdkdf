// Copyright (c) 2018 Anton Semjonov
// Licensed under the MIT License

package main

import (
	"encoding/base64"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"runtime"

	"golang.org/x/crypto/argon2"
	"golang.org/x/crypto/blake2b"
	"golang.org/x/crypto/ssh/terminal"
)

var version = "1.0"
var commit = "$Format:%h$"

type Cost struct {
	Time    uint32
	Memory  uint32
	Threads uint8
	Length  uint32
}

// argon2 cost settings [approx. benchmark on i5-5200U]
var (
	QUICK  = Cost{8, 8 * 1024, 1, 32}    // [70 msec]
	NORMAL = Cost{16, 64 * 1024, 2, 32}  // [650 msec]
	HARD   = Cost{32, 256 * 1024, 4, 32} // [4 seconds]
)

// commandline flags
var costFlag = flag.String("cost", "normal", "cost setting: {low|normal|high}")
var saltFlag = flag.String("salt", "", "salt string (required)")
var rawFlag = flag.Bool("raw", false, "output raw bytes instead of base64")
var versionFlag = flag.Bool("version", false, "print version and exit")

// stdin / stdout file descriptors for terminal checks
var stdinFd = int(os.Stdin.Fd())
var stdoutFd = int(os.Stdout.Fd())

func main() {

	// parse flags
	flag.Parse()

	// check for error, print usage and exit
	var err error
	fatal := func(err error, usage bool) {
		if err != nil {
			fmt.Fprintln(os.Stderr, "ERR:", err)
			if usage {
				flag.Usage()
			}
			os.Exit(1)
		}
	}

	// print version
	if *versionFlag {
		if commit[:7] == "$Format" {
			commit = "development"
		}
		fmt.Printf("stdkdf v%s, %s (%s/%s, runtime %s)\n",
			version, commit, runtime.GOOS, runtime.GOARCH, runtime.Version())
		os.Exit(0)
	}

	// check that salt is given
	if *saltFlag == "" {
		fatal(fmt.Errorf("salt is required"), true)
	}

	// check cost flag string
	var cost Cost
	switch *costFlag {
	case "normal":
		cost = NORMAL
	case "quick", "low":
		cost = QUICK
	case "hard", "high":
		cost = HARD
	default:
		fatal(fmt.Errorf("unknown cost setting"), true)
	}

	// read password
	var passwd []byte
	if terminal.IsTerminal(stdinFd) {
		fmt.Fprint(os.Stderr, "Enter password: ")
		passwd, err = terminal.ReadPassword(stdinFd)
		fmt.Fprint(os.Stderr, "\n")
	} else {
		passwd, err = ioutil.ReadAll(os.Stdin)
	}
	fatal(err, false)

	// derive key
	key := Stdkdf(passwd, []byte(*saltFlag), cost)

	// encode in base64
	encoding := base64.StdEncoding.EncodeToString(key)

	// output to stdout, raw if flag given, with newline if tty
	if *rawFlag {
		_, err = os.Stdout.Write(key)
	} else if terminal.IsTerminal(stdoutFd) {
		_, err = fmt.Println(encoding)
	} else {
		_, err = fmt.Print(encoding)
	}
	fatal(err, false)

}

func Stdkdf(password, salt []byte, costs Cost) (key []byte) {
	hashedsalt := blake2b.Sum256(salt)
	return argon2.Key(password, hashedsalt[:], costs.Time, costs.Memory, costs.Threads, costs.Length)
}
