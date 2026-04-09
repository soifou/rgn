.SILENT:

VERSION = $(shell git describe --tags --always)

.PHONY: all
all:
	echo 'let appVersion = "$(VERSION)"' > build.swift
	swiftc src/*.swift build.swift -o rgn

.PHONY: clean
clean:
	rm -f rgn
