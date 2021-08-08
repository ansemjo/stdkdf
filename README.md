# stdkdf

A simple binary to derive a key from a salt and a password on the commandline with Argon2.

It uses a set of predefined options and only very few flags which makes it easy and quick to use.
Output is either Base64 encoded or raw bytes.

## install

Either simply use `go get`:

    go get github.com/ansemjo/stdkdf

Or, if you have `make` installed, use the makefile to compile and install a smaller static binary:

    make static
    sudo make install

## usage

The simplest mode is providing a salt via a flag and entering the password interactively:

    $ stdkdf -salt helloreadme
    Enter password:
    CCmyoTeHa1JM5bPhEqnE5BY2PJTTYC/pw/LLz0W805Q=

For scripting purposes you can pipe the password on stdin:

    $ printf password | stdkdf -salt helloreadme
    CCmyoTeHa1JM5bPhEqnE5BY2PJTTYC/pw/LLz0W805Q=

_Careful:_ when piping, trailing whitespace (e.g. a newline) is **not** stripped! Using `echo`
instead of `printf` above yields a different key.

You can choose different [cost settings](#cost-settings) using the `-cost` flag:

    $ stdkdf -cost hard -salt helloreadme
    Enter password:
    MlKrXtvG+WJgQ79+XO4ulFzFnTv3EzCrV8lN6OrTDQA=

And output raw bytes with the `-raw` flag:

    $ printf password | stdkdf -salt helloreadme -raw > key
    $ xxd key
    00000000: 0829 b2a1 3787 6b52 4ce5 b3e1 12a9 c4e4  .)..7.kRL.......
    00000010: 1636 3c94 d360 2fe9 c3f2 cbcf 45bc d394  .6<..`/.....E...
    $ base64 key
    CCmyoTeHa1JM5bPhEqnE5BY2PJTTYC/pw/LLz0W805Q=

## cost settings

All settings output 32 byte hashes. The following cost settings are defined:

| label  | time cost | memory cost | threads | approx duration on i5-5200U |
| ------ | --------- | ----------- | ------- | --------------------------- |
| quick  | 8         | 8 MB        | 1       | 70 msec                     |
| normal | 16        | 64 MB       | 2       | 650 msec                    |
| hard   | 32        | 256 MB      | 4       | 4 seconds                   |
