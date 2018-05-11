package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"golang.org/x/crypto/argon2"
	"golang.org/x/crypto/blake2b"
)

const (
	// argon2 settings
	// https://tools.ietf.org/html/draft-irtf-cfrg-argon2-03#section-9.3
	time    = 3
	memory  = 32 * 1024
	threads = 4
	length  = 32
)

func main() {

	// check that exactly one argument is present
	args := os.Args
	if len(args) != 2 {
		fmt.Fprintf(os.Stderr, "usage: $ printf password | %s saltstring\n", args[0])
		os.Exit(1)
	}

	// hash the given string as salt
	salt := blake2b.Sum256([]byte(args[1]))

	// read stdin as password
	passwd, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		fmt.Fprintln(os.Stderr, "couldn't read stdin")
		os.Exit(2)
	}

	// derive key
	key := argon2.Key(passwd, salt[:], time, memory, threads, length)

	// output key in bytes (careful on terminals)
	_, err = os.Stdout.Write(key)
	if err != nil {
		fmt.Fprintln(os.Stderr, "couldn't write to stdout")
		os.Exit(3)
	}

}
