#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float maxBlockSize;  // peak block size in pixels
    float screenWidth;
    float screenHeight;
} ubuf;

void main() {
    vec2 uv = qt_TexCoord0;

    // Triangle wave: pixelation peaks at progress = 0.5
    float intensity = 1.0 - abs(2.0 * ubuf.progress - 1.0);

    vec2 sampleUV = uv;
    if (intensity > 0.001) {
        float bw = ubuf.maxBlockSize * intensity / ubuf.screenWidth;
        float bh = ubuf.maxBlockSize * intensity / ubuf.screenHeight;
        sampleUV = (floor(uv / vec2(bw, bh)) + 0.5) * vec2(bw, bh);
    }

    // Crossfade concentrated around peak pixelation (progress ≈ 0.5)
    float blend = smoothstep(0.4, 0.6, ubuf.progress);

    fragColor = mix(texture(source1, sampleUV),
                    texture(source2, sampleUV),
                    blend) * ubuf.qt_Opacity;
}
