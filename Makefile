.PHONY: all
all:
	swiftc src/*.swift -o rgn

.PHONY: clean
clean:
	rm -f rgn
