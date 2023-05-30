.PHONY: build run test clean

build:
	crystal build --release src/server.cr

run:
	./server

test:
	crystal spec

clean:
	rm -f ./server
