#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source1;
layout(binding = 2) uniform sampler2D source2;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float stripeCount;  // stripe density (stripes per screen-height unit)
    float angle;        // radians
    float aspectRatio;  // width / height — keeps geometry correct on wide screens
} ubuf;

void main() {
    vec2 uv = qt_TexCoord0;

    // Work in aspect-ratio-corrected space so angles look geometrically correct
    vec2 uvAR = vec2(uv.x * ubuf.aspectRatio, uv.y);

    float cosA = cos(ubuf.angle);
    float sinA = sin(ubuf.angle);

    // Along-stripe coordinate (determines which stripe this pixel belongs to)
    float stripeCoord = dot(uvAR, vec2(cosA, sinA));
    // Perpendicular coordinate (the reveal edge sweeps along this axis)
    float perpCoord = dot(uvAR, vec2(-sinA, cosA));

    // Perpendicular extent of the four screen corners in AR space
    float p00 = 0.0;
    float p10 = -ubuf.aspectRatio * sinA;
    float p01 = cosA;
    float p11 = -ubuf.aspectRatio * sinA + cosA;
    float minPerp = min(min(p00, p10), min(p01, p11));
    float maxPerp = max(max(p00, p10), max(p01, p11));

    float e = 0.02;
    float sweep = maxPerp - minPerp + 2.0 * e;

    // 0.0 = even stripe, 1.0 = odd stripe — branchless via step
    float oddness = step(0.5, mod(floor(stripeCoord * ubuf.stripeCount), 2.0));

    // Even stripes: edge sweeps minPerp → maxPerp
    float ep_even = minPerp - e + ubuf.progress * sweep;
    float t_even  = 1.0 - smoothstep(ep_even - e, ep_even + e, perpCoord);

    // Odd stripes: edge sweeps maxPerp → minPerp
    float ep_odd = maxPerp + e - ubuf.progress * sweep;
    float t_odd  = smoothstep(ep_odd - e, ep_odd + e, perpCoord);

    float t = mix(t_even, t_odd, oddness);

    fragColor = mix(texture(source1, uv), texture(source2, uv), t) * ubuf.qt_Opacity;
}
