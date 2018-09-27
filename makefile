# build static binary w/o debugging symbols, Go 1.11+ required
.PHONY : build
OUTPUT := stdkdf
BUILDFLAGS := -ldflags '-s -w -d'
build : $(OUTPUT)
$(OUTPUT) : stdkdf.go go.mod go.sum
	CGO_ENABLED=0 GOOS=$(OS) GOARCH=$(ARCH) go build $(BUILDFLAGS) -o $(OUTPUT) $<

# install built binary
.PHONY : install
PREFIX := $(shell [ $$(id -u) -eq 0 ] && echo /usr/local || echo ~/.local)
install : $(PREFIX)/bin/stdkdf
$(PREFIX)/bin/stdkdf :
	install -d $(PREFIX)/bin
	install -m 755 $< $(PREFIX)/bin

# clean anything not tracked by git
.PHONY : clean
clean :
	git clean -dfx

# cross-compile all binaries
.PHONY : release
release :
	git archive --prefix=./ HEAD | mkr rl

# makerelease targets for reproducible builds, ansemjo/makerelease
.PHONY : mkrelease-prepare mkrelease mkrelease-finish
mkrelease-prepare :
	go mod download

EXT := $(if $(findstring windows,$(OS)),.exe)
mkrelease :
	OUTPUT=$(RELEASEDIR)/$(OUTPUT)-$(OS)-$(ARCH)$(EXT) make build

mkrelease-finish :
	printf "# built with %s in %s\n" "$$MKR_VERSION" "$$MKR_IMAGE" > $(RELEASEDIR)/SHA256SUMS
	cd $(RELEASEDIR) && sha256sum $(OUTPUT)-*-* | tee -a SHA256SUMS

