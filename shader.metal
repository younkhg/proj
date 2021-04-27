#include <metal_stdlib>
using namespace metal;

struct VertIn {
    float2 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertOut {
    float4 position [[position]];
    float4 color;
};

vertex VertOut vertexShader(
    VertIn in [[stage_in]],
    uint id [[vertex_id]])
{
    VertOut out = {
        .position = float4(in.position, 0.0, 1.0),
        .color = in.color
    };
    return out;
}

fragment half4 fragmentShader(
    VertOut in [[stage_in]],
    constant float *uniforms [[buffer(0)]])
{
    return half4(in.color[0], in.color[1], uniforms[0], 1.0);
}
