# build static binary w/o debugging symbols, Go 1.11+ required
.PHONY : static
BUILDFLAGS := -ldflags '-s -w -extldflags "-static"'
static : stdkdf
stdkdf : stdkdf.go go.mod go.sum
	CGO_ENABLED=0 GOOS=$(OS) GOARCH=$(ARCH) go build $(BUILDFLAGS) -o stdkdf $<

# install built binary
.PHONY : install
PREFIX := $(shell [ $$(id -u) -eq 0 ] && echo /usr/local || echo ~/.local)
install : $(PREFIX)/bin/stdkdf
$(PREFIX)/bin/stdkdf : stdkdf
	install -d $(PREFIX)/bin
	install -m 755 $< $(PREFIX)/bin

