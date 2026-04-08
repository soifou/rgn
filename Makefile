.PHONY: all
all:
	swiftc src/*.swift -o rct

.PHONY: clean
clean:
	rm -f rct
