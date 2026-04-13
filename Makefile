.SILENT:
VERSION = $(shell git describe --tags --always)

.PHONY: all
all: build

.PHONY: build
build:
	echo 'let appVersion = "$(VERSION)"' > Sources/rgn/build.swift
	swift build

.PHONY: test
test:
	swift test

.PHONY: clean
clean:
	rm -rf .build

