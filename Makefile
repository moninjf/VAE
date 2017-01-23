sources := $(wildcard src/*.md)

all: VAE.pdf

run: all
	evince VAE.pdf

VAE.pdf: $(sources)
	pandoc -s --toc -o $@ $^
