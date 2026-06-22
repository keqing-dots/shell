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
    fragColor = mix(texture(source1, qt_TexCoord0),
                    texture(source2, qt_TexCoord0),
                    ubuf.progress) * ubuf.qt_Opacity;
}
