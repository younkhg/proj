#include "app.h"
#define GLFW_INCLUDE_NONE
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>
#include <stdio.h>

static void glfwErrCB(int code, const char *description) {
  printf("GLFW error: [%d] %s\n", code, description);
}

static void glfwKeyCB(GLFWwindow *window, int key, int scancode, int action, int mods) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}

int main(int argc, char **argv) {
  glfwInit();
  glfwSetErrorCallback(glfwErrCB);
  GLFWwindow *window = glfwCreateWindow(512, 512, "", NULL, NULL);
  if (window == NULL)
  {
      printf("Failed to create GLFW window\n");
      glfwTerminate();
      return -1;
  }
  glfwSetKeyCallback(window, glfwKeyCB);
  glfwMakeContextCurrent(window);
  NSWindow *nswindow = glfwGetCocoaWindow(window);
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
  }
  printf("Hello, World!\n");
  foo();
  glfwDestroyWindow(window);
  glfwTerminate();
  return 0;
}
