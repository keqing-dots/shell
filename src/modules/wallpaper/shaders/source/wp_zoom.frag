#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
} ubuf;

void main() {
    vec2 uv  = qt_TexCoord0;
    vec2 ctr = vec2(0.5);

    // Old image gradually zooms in (scale 1.0 → 1.08) as it fades out
    float scale1 = 1.0 + 0.08 * ubuf.progress;
    vec2 uv1 = ctr + (uv - ctr) / scale1;

    // New image zooms out from a slight zoom-in toward normal (scale 1.08 → 1.0) as it fades in
    float scale2 = 1.0 + 0.08 * (1.0 - ubuf.progress);
    vec2 uv2 = ctr + (uv - ctr) / scale2;

    vec4 a = texture(source1, clamp(uv1, 0.0, 1.0));
    vec4 b = texture(source2, clamp(uv2, 0.0, 1.0));

    fragColor = mix(a, b, ubuf.progress) * ubuf.qt_Opacity;
}
