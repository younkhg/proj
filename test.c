#include "common.h"

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stddef.h>

void printSizeT(char *str, size_t i) {
  printf("%s: %zu\n", str, i);
}

int main(int argc, char **argv) {
  printSizeT("sizeof Vertex2D", sizeof(struct Vertex2D));
  printSizeT("offset of Vertex2D.color", offsetof(struct Vertex2D, color));
  printSizeT("sizeof Vertex3D", sizeof(struct Vertex3D));
  printSizeT("offset of Vertex3D.color", offsetof(struct Vertex3D, color));
}
