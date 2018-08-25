package main

import (
	"encoding/base64"
	"flag"
	"fmt"
	"io/ioutil"
	"os"

	"golang.org/x/crypto/argon2"
	"golang.org/x/crypto/blake2b"
	"golang.org/x/crypto/ssh/terminal"
)

type cost struct {
	time    uint32
	memory  uint32
	threads uint8
	length  uint32
}

// argon2 cost settings [approx. benchmark on i5-5200U]
var quick = cost{8, 8 * 1024, 1, 32}    // [79 msec]
var normal = cost{16, 64 * 1024, 2, 32} // [650 msec]
var hard = cost{32, 256 * 1024, 4, 32}  // [4 seconds]

// commandline flags
var costFlag = flag.String("cost", "normal", "cost setting: [quick|normal|hard]")
var saltFlag = flag.String("salt", "", "salt string")

// stdin / stdout file descriptors for terminal checks
var stdinFd = int(os.Stdin.Fd())
var stdoutFd = int(os.Stdout.Fd())

func main() {

	flag.Parse()

	// print usage
	usage := func(err string) {
		if err != "" {
			fmt.Fprintln(os.Stderr, "ERR:", err)
		}
		flag.Usage()
		os.Exit(1)
	}

	// check that salt is given
	if *saltFlag == "" {
		usage("salt is required")
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
		usage("unknown cost setting")
	}

	// hash the given string to bytes
	salt := blake2b.Sum256([]byte(*saltFlag))

	// read password
	var passwd []byte
	var err error
	if terminal.IsTerminal(stdinFd) {
		fmt.Fprint(os.Stderr, "Enter password: ")
		passwd, err = terminal.ReadPassword(stdinFd)
		fmt.Fprint(os.Stderr, "\n")
	} else {
		passwd, err = ioutil.ReadAll(os.Stdin)
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "ERR:", err)
		os.Exit(2)
	}

	// derive key
	key := argon2.Key(passwd, salt[:], cost.time, cost.memory, cost.threads, cost.length)

	// encode in base64
	encoding := base64.StdEncoding.EncodeToString(key)

	// output to stdout, with newline if tty
	if terminal.IsTerminal(stdoutFd) {
		fmt.Println(encoding)
	} else {
		fmt.Print(encoding)
	}

}
