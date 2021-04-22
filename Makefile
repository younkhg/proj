# https://www.gnu.org/software/make/manual/html_node/index.html
# .POSIX: Posix behavior
# .SUFFIXES: Disable default rules for certain suffixes
# Rules after `|` are "order-only prerequisites"
# `$<` is the first dependency
# `$@` is the target

# cc (compiler)
# -MT ${TARGETNAME} : target in dep file
# -MMD : deps without system headers
# -MP : target per prerequisite, to avoid errors when deleting files, etc
# -MF ${DEPFILENAME} : output dep file name

# ld (linker)
# The default library search path is /usr/lib then /usr/local/lib.
# The -L option will add a new library search path.  The default framework
# search path is /Library/Frameworks then /System/Library/Frameworks.
# (Note: previously, /Network/Library/Frameworks was at the end of the
# default path.  If you need that functionality, you need to explicitly add
# -F/Network/Library/Frameworks).  The -F option will add a new framework
# search path.  The -Z option will remove the standard search paths.  The
# -syslibroot option will prepend a prefix to all search paths.

# Default variables
# https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_toc.html#TOC96
# AR Archive-maintaining program; default `ar'.
# CC Program for compiling C programs; default `cc'.
# CXX Program for compiling C++ programs; default `g++'.
# CPP Program for running the C preprocessor, with results to standard output; default `$(CC) -E'.

.POSIX:
.SUFFIXES:

# Deps: glfw3

# <VAR> := $(shell <CMD>) pattern makes the variable to be set only once
# Set these when invoking make in order to override these
# ex) make CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib -lglfw"
CFLAGS := $(shell pkg-config --cflags glfw3)
LDFLAGS := $(shell pkg-config --libs glfw3)

SRC = main.m app.c
OBJ = $(addprefix build/, $(addsuffix .o, $(SRC)))
DEP = $(addprefix build/, $(addsuffix .d, $(SRC)))

INC =

LNK = -framework Cocoa -framework IOKit -framework CoreFoundation -framework Metal -framework MetalKit -framework QuartzCore

all: bin

bin: $(OBJ) shader.metallib
	$(CC) $(LDFLAGS) $(LNK) $(OBJ) -o bin

build/%.c.o: %.c
	@mkdir -p build/$(dir $<)
	$(CC) -c $(CFLAGS) $(INC) $< -MT $@ -MMD -MP -MF build/$<.d -o $@

build/%.m.o: %.m
	@mkdir -p build/$(dir $<)
	$(CC) -c -ObjC -fobjc-arc $(CFLAGS) $(INC) $< -MT $@ -MMD -MP -MF build/$<.d -o $@

build/%.cpp.o: %.cpp
	@mkdir -p build/$(dir $<)
	$(CXX) -c $(CFLAGS) $(INC) $< -MT $@ -MMD -MP -MF build/$<.d -o $@

shader.metallib: build/shader.air
	xcrun -sdk macosx metallib build/shader.air -o shader.metallib

build/shader.air: shader.metal
	@mkdir -p build
	xcrun -sdk macosx metal -c shader.metal -o build/shader.air

clean:
	rm -rf build
	rm -f bin
	rm -f shader.metalib

-include $(DEP)
