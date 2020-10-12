#include "app.h"
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <glad/glad.h>
#include <stdio.h>

void glfwErrCB(int code, const char *description) {
  printf("GLFW error: [%d] %s\n", code, description);
}

int main(int argc, char **argv) {
  glfwInit();
  glfwSetErrorCallback(glfwErrCB);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
  GLFWwindow* window = glfwCreateWindow(512, 512, "", NULL, NULL);
  if (window == NULL)
  {
      printf("Failed to create GLFW window\n");
      glfwTerminate();
      return -1;
  }
  glfwMakeContextCurrent(window);
  if(!gladLoadGL()) {
    printf("Failed to load OpenGL\n");
  }
  printf("Hello, World!\n");
  foo();
  glfwTerminate();
  return 0;
}
