#!/bin/bash

mkdir -p deps

mkdir -p deps/include
cp -r glad/include/ deps/include/
mkdir -p build/deps/glad
mkdir -p deps/lib
cc -Iglad/include -c glad/src/glad.c -o build/deps/glad/glad.o
ar rs deps/lib/libglad.a build/deps/glad/glad.o

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(pwd)/deps -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF -B build/deps/glfw -S glfw
make -j 4 -C build/deps/glfw
make -C build/deps/glfw install
