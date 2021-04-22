// https://gist.github.com/gcatlin/987be74e2d58da96093a7598f3fbfb27
// https://gist.github.com/dmikoss/5f7f4ca63c89d26d8a7e
// https://github.com/ocornut/imgui/blob/master/backends/imgui_impl_metal.mm
// https://github.com/ocornut/imgui/blob/master/examples/example_glfw_metal/main.mm
// https://github.com/whaison/metal-without-xcode/blob/master/main.mm

#define GLFW_INCLUDE_NONE
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>

#import <Metal/Metal.h>
#import <AppKit/NSWindow.h>
#import <QuartzCore/CAMetalLayer.h>

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "app.h"

static void glfwErrCB(int code, const char *description) {
  printf("GLFW error: [%d] %s\n", code, description);
}

static void glfwKeyCB(GLFWwindow *window, int key, int scancode, int action, int mods) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}

bool isInteger(const char *restrict str, long *intVal, char **restrict strEnd) {
    *intVal = strtol(str, strEnd, 10);
    return !(str == *strEnd);
}

int main(int argc, char **argv) {
    @autoreleasepool {
        bool fullscreen = false;
        int width = -1;
        int height = -1;
        if (argc > 1) {
            for (int i = 1; i < argc; i += 1) {
                char *arg = argv[i];
                long intVal;
                char *strEnd;
                if (strcmp(arg, "f") == 0) {
                    fullscreen = true;
                    printf("Fullscreen: True\n");
                }
                else if (isInteger(arg, &intVal, &strEnd)) {
                    if (intVal > 0) {
                        if (width < 0) {
                            width = (int)intVal;
                        }
                        else {
                            height = (int)intVal;
                        }
                    }
                    else {
                        printf("Invalid int val %ld\n", intVal);
                    }
                }
            }
        }
        if (width < 0) {
            width = 512;
        }
        if (height < 0) {
            height = 512;
        }

        foo();

        glfwSetErrorCallback(glfwErrCB);
        glfwInit();
        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
        GLFWwindow *window = 0;
        if (fullscreen) {
            GLFWmonitor *fullscreenMonitor = glfwGetPrimaryMonitor();
            const GLFWvidmode* videoMode = glfwGetVideoMode(fullscreenMonitor);
            window = glfwCreateWindow(videoMode->width, videoMode->height, "", fullscreenMonitor, NULL);
        }
        else {
            window = glfwCreateWindow(width, height, "", NULL, NULL);
        }
        if (window == NULL) {
            printf("Failed to create GLFW window\n");
            glfwTerminate();
            return -1;
        }
        glfwSetKeyCallback(window, glfwKeyCB);

        CAMetalLayer *layer = [CAMetalLayer layer]; // CoreAnimation -> GPU -> Display
        id<MTLDevice> device = [layer preferredDevice];
        id<MTLCommandQueue> commandQueue = [device newCommandQueue];
        NSWindow *nswindow = glfwGetCocoaWindow(window);
        // MTLPixelFormatBGRA8Unorm is the default value for CAMetalLayer.pixelFormat
        MTLPixelFormat pixelFormat = MTLPixelFormatBGRA8Unorm;
        NSError *err = nil;

        layer.device = device;
        layer.pixelFormat = pixelFormat;
        layer.framebufferOnly = YES;

        // contentView: the highest accessible NSView object in the window’s view hierarchy.
        nswindow.contentView.layer = layer; // Set View's content backing storage
        nswindow.contentView.wantsLayer = YES;

        NSString *libraryFile = @"shader.metallib";
        id<MTLLibrary> myLibrary = [device newLibraryWithFile:libraryFile error:&err];
        if (!myLibrary) {
            NSLog(@"Library error: %@", err.localizedDescription);
            return -1;
        }
        id<MTLFunction> vertexProgram = [myLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentProgram = [myLibrary newFunctionWithName:@"fragmentShader"];

        MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
        pipelineDescriptor.vertexFunction = vertexProgram;
        pipelineDescriptor.fragmentFunction = fragmentProgram;
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat;

        id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&err];
        if (!pipelineState) {
            NSLog(@"Failed to create pipeline state: %@", err.localizedDescription);
            return -1;
        }

        float vertexData[] = {
            0.0f, 0.5f, 0.0f,
            -0.5f, -0.5f, 0.0f,
            0.5f, -0.5f, 0.0f
        };

        NSUInteger dataSize = sizeof(vertexData);
        id<MTLBuffer> vertexBuffer = [device newBufferWithBytes:vertexData length:dataSize options:MTLResourceStorageModeShared];

        struct Uniforms {
            float t;
        };
        NSUInteger uniformSize = sizeof(struct Uniforms);
        id<MTLBuffer> uniformBuffer = [device newBufferWithLength:uniformSize options:MTLResourceStorageModeShared];

        uint64_t frameCount = 0;

        while (!glfwWindowShouldClose(window)) {
            glfwPollEvents();

            float t = (float)(frameCount % 100) / 99.0f;

            int width, height;
            glfwGetFramebufferSize(window, &width, &height);
            layer.drawableSize = CGSizeMake(width, height);
            id<CAMetalDrawable> drawable = [layer nextDrawable];
            id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];

            MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
            renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.7f, 0.3f, t, 1.0f);

            struct Uniforms *uniforms = [uniformBuffer contents];
            uniforms->t = t;

            id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder setRenderPipelineState:pipelineState];
            [renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
            [renderEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];

            [renderEncoder endEncoding];
            [commandBuffer presentDrawable:drawable];
            [commandBuffer commit];

            frameCount += 1;
        }

        glfwDestroyWindow(window);
        glfwTerminate();
    }
    return 0;
}
