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

SRC = main.c app.c
INC = -Ideps/include
LNK = -Z -L/usr/lib -F/System/Library/Frameworks -Ldeps/lib -lglfw3 -lglad -ldl -framework Cocoa -framework IOKit -framework CoreFoundation

OBJ = $(addprefix build/proj/, $(addsuffix .o, $(SRC)))
DEP = $(addprefix build/proj/, $(addsuffix .d, $(SRC)))

all: bin

bin: $(OBJ)
	cc $(OBJ) $(LNK) -o bin

build/proj/%.c.o: %.c
	mkdir -p build/proj/$(dir $<)
	cc -c $(INC) $< -MT $@ -MMD -MP -MF build/proj/$<.d -o $@

build/proj/%.m.o: %.m
	mkdir -p build/proj/$(dir $<)
	cc -c -ObjC $(INC) $< -MT $@ -MMD -MP -MF build/proj/$<.d -o $@

build/proj/%.cpp.o: %.cpp
	mkdir -p build/proj/$(dir $<)
	c++ -c $(INC) $< -MT $@ -MMD -MP -MF build/proj/$<.d -o $@

clean:
	rm -rf build/proj
	rm -f bin

-include $(DEP)
