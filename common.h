#ifndef INCLUDE_COMMON_H
#define INCLUDE_COMMON_H

#define f2(X, Y) (struct F2){ .x = X, .y = Y }
#define f3(X, Y, Z) (struct F3){ .x = X, .y = Y, .z = Z }
#define f4(X, Y, Z, W) (struct F4){ .x = X, .y = Y, .z = Z, .w = W }

struct F2 {
  union {
    struct { float x, y; };
    struct { float data[2]; };
  };
};

struct F3 {
  union {
    struct { float x, y, z; };
    struct { float r, g, b; };
    struct { float data[3]; };
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

struct Vertex3D {
  struct F3 position;
  struct F4 color;
};

void foo(void);

#endif
