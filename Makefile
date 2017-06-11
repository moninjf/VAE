sources := $(wildcard src/*.md)

all: build/VAE.pdf

run: all
	evince build/VAE.pdf

build:
	mkdir -p $@

build/VAE.pdf: $(sources) | build
	pandoc -s --toc -o $@ $^
