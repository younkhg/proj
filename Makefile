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

SRC = app.c
LNK = -Z -L/usr/lib
OBJ = $(addprefix build/proj/, $(addsuffix .o, $(SRC)))
DEP = $(addprefix build/proj/, $(addsuffix .d, $(SRC)))

MACGLSRC = main.c
MACGLLNK = -F/System/Library/Frameworks -Ldeps/lib -lglfw3 -lglad -ldl -framework Cocoa -framework IOKit -framework CoreFoundation
MACGLOBJ = $(addprefix build/proj/, $(addsuffix .o, $(MACGLSRC)))
MACGLDEP = $(addprefix build/proj/, $(addsuffix .d, $(MACGLSRC)))

MACMTSRC = main.m
MACMTLNK = -F/System/Library/Frameworks -Ldeps/lib -lglfw3 -framework Cocoa -framework IOKit -framework CoreFoundation -framework Metal -framework MetalKit -framework QuartzCore
MACMTOBJ = $(addprefix build/proj/, $(addsuffix .o, $(MACMTSRC)))
MACMTDEP = $(addprefix build/proj/, $(addsuffix .d, $(MACMTSRC)))

INC = -Ideps/include

all:
	@echo "Need to provide target to build: [macglbin, macmtbin]"

macglbin: $(OBJ) $(MACGLOBJ)
	cc $(OBJ) $(MACGLOBJ) $(LNK) $(MACGLLNK) -o macglbin

macmtbin: $(OBJ) $(MACMTOBJ)
	cc $(OBJ) $(MACMTOBJ) $(LNK) $(MACMTLNK) -o macmtbin

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
	rm -f macglbin macmtbin

-include $(DEP)
-include $(MACGLDEP)
-include $(MACMTDEP)
