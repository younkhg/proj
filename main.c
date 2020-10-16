#include "app.h"
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <glad/glad.h>
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
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
  GLFWwindow *window = glfwCreateWindow(512, 512, "", NULL, NULL);
  if (window == NULL)
  {
      printf("Failed to create GLFW window\n");
      glfwTerminate();
      return -1;
  }
  glfwSetKeyCallback(window, glfwKeyCB);
  glfwMakeContextCurrent(window);
  if(!gladLoadGL()) {
    printf("Failed to load OpenGL\n");
  }
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
  }
  printf("Hello, World!\n");
  foo();
  glfwDestroyWindow(window);
  glfwTerminate();
  return 0;
}
