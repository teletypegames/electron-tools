# -----------------------------------------
# Makefile – Electron app: the npm steps of the served pipeline
# -----------------------------------------
# In the dev container node_modules is a volume of its own (Linux packages),
# apart from the node_modules of this computer that `make run` installs.

PROJECT = example

# mac-release: the macOS packages, which only a Mac builds; the version is
# package.json's. WARP_TOKEN is an application token with the update + upload
# scopes.
VERSION     ?= $(shell node -p 'require("./package.json").version' 2>/dev/null)
MAC_ARCHS    = x64 arm64
WARP_SERVER ?= https://teletypegames.org
WARP_ENGINE ?= warp-engine
export WARP_SERVER WARP_TOKEN

all: build

node_modules/.package-lock.json: package-lock.json
	npm ci --no-audit --no-fund

install: node_modules/.package-lock.json

check: install
	npm run check --if-present

build: check
	npm run build --if-present

package: build
	npm run dist:linux

# runs the app with Electron on this computer (not in the dev container)
run:
	test -x node_modules/.bin/electron || npm install --no-audit --no-fund
	npm start

# run on a Mac: builds a zip per architecture, uploads them into the release
# the CI published and publishes it again (warp-engine, the WarpEngine CLI)
mac-release: build
	@if [ "$$(uname -s)" != "Darwin" ]; then echo "ERROR: the macOS packages are built on a Mac"; exit 1; fi
	@command -v $(WARP_ENGINE) >/dev/null 2>&1 || { echo "ERROR: $(WARP_ENGINE) (the WarpEngine CLI) is not installed: curl -fsSL https://git.teletypegames.org/engines/warp-engine-cli/raw/branch/master/install.sh | sh"; exit 1; }
	@set -e; for arch in $(MAC_ARCHS); do \
		rm -f dist/*.zip; \
		npx --no-install electron-builder --mac zip --$$arch --publish never; \
		mv "$$(find dist -maxdepth 1 -name '*.zip' | head -n 1)" "$(PROJECT)-$(VERSION)-mac-$$arch.zip"; \
	done
	$(WARP_ENGINE) release upload --name $(PROJECT) --version $(VERSION) $(foreach arch,$(MAC_ARCHS),$(PROJECT)-$(VERSION)-mac-$(arch).zip)
	$(WARP_ENGINE) release publish --name $(PROJECT) --version $(VERSION) --platform electron

clean:
	rm -rf dist .warp-dist *.zip

.PHONY: all install check build package run mac-release clean
