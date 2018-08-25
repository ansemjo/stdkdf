# targets that are not actual files
.PHONY : install build clean

# build static binary w/o debugging symbols, Go 1.11+ required
build : stdkdf
stdkdf : stdkdf.go
	go build -ldflags="-s -w" -o $@ $<
	command -v upx >/dev/null && upx stdkdf

# install built binary
PREFIX := $(shell [ $$(id -u) -eq 0 ] && echo /usr/local || echo ~/.local)
install : stdkdf
	install -d $(PREFIX)/bin
	install -m 755 $< $(PREFIX)/bin

# clean anything not tracked by git
clean :
	git clean -dfx
