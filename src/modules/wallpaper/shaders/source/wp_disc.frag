#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float centerX;
    float centerY;
} ubuf;

void main() {
    vec2 uv = qt_TexCoord0;
    vec2 center = vec2(ubuf.centerX, ubuf.centerY);

    // Normalise distance so radius=1 reaches the farthest screen corner
    float maxDist = max(
        max(length(center),               length(vec2(1.0 - center.x, center.y))),
        max(length(vec2(center.x, 1.0 - center.y)), length(vec2(1.0) - center))
    );
    float d = length(uv - center) / maxDist;

    float e = 0.04;
    float ep = ubuf.progress * (1.0 + 2.0 * e) - e;
    float t = 1.0 - smoothstep(ep - e, ep + e, d);

    fragColor = mix(texture(source1, uv), texture(source2, uv), t) * ubuf.qt_Opacity;
}
