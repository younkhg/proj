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
#include <stddef.h>
#include <unistd.h>
#include <stdbool.h>

#include "common.h"

static void glfwErrCB(int code, const char *description) {
	printf("GLFW error: [%d] %s\n", code, description);
}

static void glfwKeyCB(GLFWwindow *window, int key, int scancode, int action, int mods) {
	if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
		glfwSetWindowShouldClose(window, GLFW_TRUE);
	}
}

bool isIntArg(const char *restrict str, int *intVal) {
	// Expects string representing single integer number.
	// `str` should not have whitespace chars in the middle.
	// Ex) "123": Good, "1 14": Will only return 1
	char *strEnd;
	long val = strtol(str, &strEnd, 10);
	*intVal = (int)val;
	return !(str == strEnd);
}

int main(int argc, char **argv) {
@autoreleasepool {
	bool fullscreen = false;
	int windowWidth = 512;
	int windowHeight = 512;
	{
	int c, intArg;
	while ((c = getopt(argc, argv, "fw:h:")) != -1) {
		switch (c) {
		case 'f':
			fullscreen = true;
			printf("Fullscreen: True\n");
			break;
		case 'w':
			if (isIntArg(optarg, &intArg)) {
				windowWidth = intArg;
			}
			else {
				printf("option [w] with invalid arg [%s]\n", optarg);
			}
			break;
		case 'h':
			if (isIntArg(optarg, &intArg)) {
				windowHeight = intArg;
			}
			else {
				printf("option [h] with invalid arg [%s]\n", optarg);
			}
			break;
		// TODO: Option s, taking width and height combined. ex) 1920x1080
		case '?':
			printf("Unknown option [%c]\n", optopt);
			break;
		}
	}
	}

	// MTLPixelFormatBGRA8Unorm is the default value for CAMetalLayer.pixelFormat
	const MTLPixelFormat mtlLayerPixelFormat = MTLPixelFormatBGRA8Unorm;
	const MTLPixelFormat depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
	const NSUInteger MaxFramesInFlight = 3;
	const size_t MaxNumVertices = 3 * 4096;

	glfwSetErrorCallback(glfwErrCB);
	glfwInit();
	glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
	glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
	GLFWwindow *window = 0;
	if (fullscreen) {
		GLFWmonitor *fullscreenMonitor = glfwGetPrimaryMonitor();
		const GLFWvidmode* videoMode = glfwGetVideoMode(fullscreenMonitor);
		window = glfwCreateWindow(videoMode->width, videoMode->height, "", fullscreenMonitor, NULL);
	}
	else {
		window = glfwCreateWindow(windowWidth, windowHeight, "", NULL, NULL);
	}
	if (window == NULL) {
		printf("Failed to create GLFW window\n");
		glfwTerminate();
		return -1;
	}
	int width, height;
	glfwGetFramebufferSize(window, &width, &height);
	glfwSetKeyCallback(window, glfwKeyCB);

	CAMetalLayer *layer = [CAMetalLayer layer]; // CoreAnimation -> GPU -> Display
	id<MTLDevice> device = [layer preferredDevice];
	id<MTLCommandQueue> commandQueue = [device newCommandQueue];
	NSError *err = nil;

	layer.device = device;
	layer.pixelFormat = mtlLayerPixelFormat;
	layer.framebufferOnly = YES;
	layer.opaque = YES;
	layer.drawableSize = CGSizeMake(width, height);

	NSWindow *nswindow = glfwGetCocoaWindow(window);
	// contentView: the highest accessible NSView object in the window’s view hierarchy.
	nswindow.contentView.layer = layer; // Set View's content backing storage
	nswindow.contentView.wantsLayer = YES;

	NSString *libraryFile = @"shader.metallib"; // CWD is important!
	id<MTLLibrary> myLibrary = [device newLibraryWithFile:libraryFile error:&err];
	if (!myLibrary) {
		NSLog(@"Library error: %@", err.localizedDescription);
		return -1;
	}
	id<MTLFunction> vertexProgram = [myLibrary newFunctionWithName:@"vertexShader"];
	id<MTLFunction> fragmentProgram = [myLibrary newFunctionWithName:@"fragmentShader"];
	if (!vertexProgram || !fragmentProgram) {
		printf("Could not load vertex|fragment function from library\n");
		return -1;
	}

	MTLVertexDescriptor* vertexDesc = [[MTLVertexDescriptor alloc] init];
	vertexDesc.attributes[0].format = MTLVertexFormatFloat3;
	vertexDesc.attributes[0].bufferIndex = 0;
	vertexDesc.attributes[0].offset = 0;
	vertexDesc.attributes[1].format = MTLVertexFormatFloat4;
	vertexDesc.attributes[1].bufferIndex = 0;
	vertexDesc.attributes[1].offset = offsetof(struct Vertex3D, color);
	vertexDesc.layouts[0].stride = sizeof(struct Vertex3D); // Layout for MTLBuffer[0]
	vertexDesc.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;

	MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
	pipelineDescriptor.vertexFunction = vertexProgram;
	pipelineDescriptor.fragmentFunction = fragmentProgram;
	pipelineDescriptor.colorAttachments[0].pixelFormat = mtlLayerPixelFormat;
	pipelineDescriptor.depthAttachmentPixelFormat = depthAttachmentPixelFormat;
	pipelineDescriptor.vertexDescriptor = vertexDesc;

	id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&err];
	if (!pipelineState) {
		NSLog(@"Failed to create pipeline state: %@", err.localizedDescription);
		return -1;
	}

	MTLTextureDescriptor *depthTargetDescriptor = [MTLTextureDescriptor new];
	depthTargetDescriptor.width = width;
	depthTargetDescriptor.height = height;
	depthTargetDescriptor.pixelFormat = depthAttachmentPixelFormat;
	depthTargetDescriptor.storageMode = MTLStorageModePrivate;
	depthTargetDescriptor.usage = MTLTextureUsageRenderTarget;
	id<MTLTexture> depthTexture = [device newTextureWithDescriptor:depthTargetDescriptor];

	MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
	depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess; // TODO: maybe reverse depth?
	depthStencilDescriptor.depthWriteEnabled = YES;
	id<MTLDepthStencilState> depthStencilState = [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];

	struct Uniforms {
		float t;
	};
	NSUInteger uniformSize = sizeof(struct Uniforms);
	id<MTLBuffer> uniformBuffer = [device newBufferWithLength:uniformSize options:MTLResourceStorageModeShared];

	uint64_t frameCount = 0;
	dispatch_semaphore_t inFlightSemaphore = dispatch_semaphore_create(MaxFramesInFlight);
	NSUInteger currentBuffer = 0;

	id<MTLBuffer> vertexBuffers[MaxFramesInFlight];
	for (NSUInteger i = 0; i < MaxFramesInFlight; i += 1) {
		vertexBuffers[i] = [device newBufferWithLength:(NSUInteger)(MaxNumVertices * sizeof(struct Vertex3D)) options:MTLResourceStorageModeShared];
		vertexBuffers[i].label = [NSString stringWithFormat:@"Vertex Buffer #%lu", (unsigned long)i];
	}

	while (!glfwWindowShouldClose(window)) {
		dispatch_semaphore_wait(inFlightSemaphore, DISPATCH_TIME_FOREVER);
		id<CAMetalDrawable> drawable = [layer nextDrawable];
		if (!drawable) {
			continue;
		}
		glfwPollEvents();
		id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
		struct Uniforms *uniforms = [uniformBuffer contents];

		float t = (float)(frameCount % 120) / 119.0f;
		uniforms->t = t;
		struct Vertex3D *vertices = [vertexBuffers[currentBuffer] contents];
		vertices[0].position = f3(0.0f, 0.9f, t); vertices[0].color = f4(1.0f, 0.0f, 0.0f, 1.0f);
		vertices[1].position = f3(-0.5f, -0.5f, 1.0f); vertices[1].color = f4(0.0f, 1.0f, 0.0f, 1.0f);
		vertices[2].position = f3(0.5f, -0.5f, 1.0f); vertices[2].color = f4(1.0f, 1.0f, 0.0f, 1.0f);

		vertices[3].position = f3(-0.9f, 0.1f, 0.5f); vertices[3].color = f4(1.0f, 1.0f, 0.0f, 1.0f);
		vertices[4].position = f3(0.9f, 0.1f, 0.5f); vertices[4].color = f4(1.0f, 1.0f, 0.0f, 1.0f);
		vertices[5].position = f3(0.0f, 0.9f, 0.5f); vertices[5].color = f4(1.0f, 1.0f, 0.0f, 1.0f);

		MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
		renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
		renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
		renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.7f, 0.3f, t, 1.0f);
		renderPassDescriptor.depthAttachment.texture = depthTexture;
		renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
		renderPassDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
		renderPassDescriptor.depthAttachment.clearDepth = 1.0;

		id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		[renderEncoder setRenderPipelineState:pipelineState];
		[renderEncoder setDepthStencilState:depthStencilState];

		// TODO: details on culling
		// [renderEncoder setCullMode:MTLCullModeBack];

		[renderEncoder setVertexBuffer:vertexBuffers[currentBuffer] offset:0 atIndex:0];
		[renderEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
		// Instead of setting buffers, setVertexBytes:length:atIndex can be used
		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
		[renderEncoder endEncoding];

		[commandBuffer presentDrawable:drawable];
		__block dispatch_semaphore_t blockSemaphore = inFlightSemaphore;
		[commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
			dispatch_semaphore_signal(blockSemaphore);
		}];
		[commandBuffer commit];
		frameCount += 1;
		currentBuffer = (currentBuffer + 1) % MaxFramesInFlight;
	}

	glfwDestroyWindow(window);
	glfwTerminate();
}
return 0;
}
