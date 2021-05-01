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

static inline struct F2 f2(float x, float y) {
  struct F2 f = { .x = x, .y = y };
  return f;
}

static inline struct F4 f4(float x, float y, float z, float w) {
  struct F4 f = { .x = x, .y = y , .z = z, .w = w};
  return f;
}

#endif
