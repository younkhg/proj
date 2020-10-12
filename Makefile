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
# -Z removes default search paths for libraries and frameworks

.POSIX:
.SUFFIXES:

SRC = main.c a.c
INC = -Iinclude
LNK = -Z -L/usr/lib -F/System/Library/Frameworks -Llib -lglfw3 -lglad -ldl -framework Cocoa -framework IOKit -framework CoreFoundation

OBJ = $(addprefix build/, $(addsuffix .o, $(SRC)))
DEP = $(addprefix build/, $(addsuffix .d, $(SRC)))

all: app

app: $(OBJ)
	cc $(OBJ) $(LNK) -o app

build/%.c.o: %.c
	mkdir -p build/$(dir $<)
	cc -c $(INC) $< -MT $@ -MMD -MP -MF build/$<.d -o $@

build/%.m.o: %.m
	mkdir -p build/$(dir $<)
	cc -c -ObjC $(INC) $< -MT $@ -MMD -MP -MF build/$<.d -o $@

clean:
	rm -rf build
	rm -f app

-include $(DEP)
