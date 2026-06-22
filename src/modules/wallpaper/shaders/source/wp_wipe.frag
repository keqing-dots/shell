#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

// direction: 0=left→right  1=right→left  2=top→bottom  3=bottom→top
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float direction;
} ubuf;

void main() {
    vec2 uv = qt_TexCoord0;

    float coord;
    if (ubuf.direction < 0.5)
        coord = uv.x;
    else if (ubuf.direction < 1.5)
        coord = 1.0 - uv.x;
    else if (ubuf.direction < 2.5)
        coord = uv.y;
    else
        coord = 1.0 - uv.y;

    // Extend progress so the soft edge starts fully off-screen
    float e = 0.04;
    float ep = ubuf.progress * (1.0 + 2.0 * e) - e;
    float t = 1.0 - smoothstep(ep - e, ep + e, coord);

    fragColor = mix(texture(source1, uv), texture(source2, uv), t) * ubuf.qt_Opacity;
}
