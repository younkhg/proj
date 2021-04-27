#ifndef INCLUDE_COMMON_H
#define INCLUDE_COMMON_H

struct F2 {
  union {
    struct { float x, y; };
    struct { float data[2]; };
  };
};

struct F4 {
  union {
    struct { float x, y, z, w; };
    struct { float r, g, b, a; };
    struct { float data[4]; };
  };
};

struct Vertex2D {
  struct F2 position;
  struct F4 color;
};


void foo(void);

#endif