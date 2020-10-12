#!/bin/bash

mkdir -p include
cp -r glad/include/ include/
mkdir -p build_glad
mkdir -p lib
cc -Iglad/include -c glad/src/glad.c -o build_glad/glad.o
ar rs lib/libglad.a build_glad/glad.o

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(pwd) -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF -B build_glfw -S glfw
make -j 4 -C build_glfw
make -C build_glfw install
