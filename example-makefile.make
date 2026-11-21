# -----------------------------------------
# Makefile – Electron app: the npm steps of the served pipeline
# -----------------------------------------
# In the dev container node_modules is a volume of its own (Linux packages),
# apart from the node_modules of this computer that `make run` installs.

PROJECT = example

all: build

node_modules/.package-lock.json: package-lock.json
	npm ci --no-audit --no-fund

install: node_modules/.package-lock.json

build: install
	npm run check --if-present
	npm run build --if-present

package: build
	npm run dist:linux

# runs the app with Electron on this computer (not in the dev container)
run:
	test -x node_modules/.bin/electron || npm install --no-audit --no-fund
	npm start

clean:
	rm -rf dist .warp-dist

.PHONY: all install build package run clean
