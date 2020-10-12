#include "a.h"
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <glad/glad.h>
#include <stdio.h>

// Called from platform main
int main(int argc, char **argv) {
  printf("Hello, World!\n");
  foo();
  glfwInit();
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
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
  glfwTerminate();
  return 0;
}
