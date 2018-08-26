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

const version = "1.0.3"

type cost struct {
	time    uint32
	memory  uint32
	threads uint8
	length  uint32
}

// argon2 cost settings [approx. benchmark on i5-5200U]
var quick = cost{8, 8 * 1024, 1, 32}    // [70 msec]
var normal = cost{16, 64 * 1024, 2, 32} // [650 msec]
var hard = cost{32, 256 * 1024, 4, 32}  // [4 seconds]

// commandline flags
var costFlag = flag.String("cost", "normal", "cost setting: {quick|normal|hard}")
var saltFlag = flag.String("salt", "", "salt string (required)")
var rawFlag = flag.Bool("raw", false, "output raw bytes instead of base64")

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
				fmt.Fprintf(os.Stderr, "stdkdf v%s (compiled with %s on %s/%s)\n",
					version, runtime.Version(), runtime.GOOS, runtime.GOARCH)
				flag.Usage()
			}
			os.Exit(1)
		}
	}

	// check that salt is given
	if *saltFlag == "" {
		fatal(fmt.Errorf("salt is required"), true)
	}

	// check cost flag string
	var cost cost
	switch *costFlag {
	case "normal":
		cost = normal
	case "quick":
		cost = quick
	case "hard":
		cost = hard
	default:
		fatal(fmt.Errorf("unknown cost setting"), true)
	}

	// hash the given string to bytes
	salt := blake2b.Sum256([]byte(*saltFlag))

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
	key := argon2.Key(passwd, salt[:], cost.time, cost.memory, cost.threads, cost.length)

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
