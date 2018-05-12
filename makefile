# targets with no actual files
.PHONY : install build clean

# names
BINARY := stdkdf
PREFIX := /usr/local

# build alias
build : $(BINARY)

# build binary
$(BINARY) :
	# compile w/o debugging symbols
	go build -ldflags="-s -w" -o "$@" "$@.go"
	# compress with upx
	upx stdkdf

# install globally
install : $(BINARY)
	install -m 755 -o root -g root $(BINARY) $(PREFIX)/bin/

# clean anything not tracked by git
clean :
	git clean -fx
