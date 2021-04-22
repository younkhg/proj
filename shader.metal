#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 position [[position]];
    float4 color;
} RasterizerData;

vertex RasterizerData vertexShader(
    uint vertexID [[vertex_id]],
    constant packed_float3 *vertices [[buffer(0)]])
{
    RasterizerData out = {
        .position = float4(vertices[vertexID], 1.0),
        .color = float4(1.0, 0.9, 0.0, 1.0)
    };
    return out;
}

fragment half4 fragmentShader(
    RasterizerData in [[stage_in]],
    constant float *uniforms [[buffer(0)]])
{
    float r = uniforms[0];
    float g = in.color[1];
    return half4(r, g, 1.0 - r, 1.0);
}
