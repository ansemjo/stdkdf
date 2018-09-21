# targets that are not actual files
.PHONY : install build clean mkrelease-prepare mkrelease mkrelease-finish release

# build static binary w/o debugging symbols, Go 1.11+ required
build : stdkdf
stdkdf : stdkdf.go go.mod go.sum
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

# makerelease targets for reproducible builds, ansemjo/makerelease
mkrelease-prepare:
	go mod download
EXT := $(if $(findstring windows,$(OS)),.exe)
mkrelease: stdkdf.go
	GOOS=$(OS) GOARCH=$(ARCH) go build \
		-ldflags="-s -w" -o $(RELEASEDIR)/stdkdf-$(OS)-$(ARCH)$(EXT) $<
mkrelease-finish:
	upx $(RELEASEDIR)/* || true
	printf "# built with %s in %s\n" "$$MKR_VERSION" "$$MKR_IMAGE" > $(RELEASEDIR)/SHA256SUMS
	cd $(RELEASEDIR) && sha256sum * | tee -e SHA256SUMS

release:
	git archive --prefix=./ HEAD | mkr rl
