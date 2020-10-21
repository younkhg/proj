// https://gist.github.com/gcatlin/987be74e2d58da96093a7598f3fbfb27
// https://gist.github.com/dmikoss/5f7f4ca63c89d26d8a7e
// https://github.com/ocornut/imgui/blob/master/backends/imgui_impl_metal.mm
// https://github.com/ocornut/imgui/blob/master/examples/example_glfw_metal/main.mm

#include "app.h"

#define GLFW_INCLUDE_NONE
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

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
  glfwSetErrorCallback(glfwErrCB);
  glfwInit();
  glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
  GLFWwindow *window = glfwCreateWindow(512, 512, "", NULL, NULL);
  if (window == NULL)
  {
      printf("Failed to create GLFW window\n");
      glfwTerminate();
      return -1;
  }
  glfwSetKeyCallback(window, glfwKeyCB);
  
  id <MTLDevice> device = MTLCreateSystemDefaultDevice();;
  id <MTLCommandQueue> commandQueue = [device newCommandQueue];
  NSWindow *nswindow = glfwGetCocoaWindow(window);
  CAMetalLayer *layer = [CAMetalLayer layer];
  layer.device = device;
  layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
  nswindow.contentView.layer = layer;
  nswindow.contentView.wantsLayer = YES;

  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
  }
  printf("Hello, World!\n");
  foo();
  glfwDestroyWindow(window);
  glfwTerminate();
  return 0;
}
