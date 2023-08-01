/**
    Common types and functions used for ray tracing.
*/

#ifndef COMMON_GLSL
#define COMMON_GLSL

// Utility Functions
float getHash(vec3 p) {
    p = fract(p * 0.3183099 + .1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
} // Hash function created by Inigo Quilez

float getNoise(in vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    return mix(mix(mix(getHash(p + vec3(0, 0, 0)), getHash(p + vec3(1, 0, 0)), f.x), mix(getHash(p + vec3(0, 1, 0)), getHash(p + vec3(1, 1, 0)), f.x), f.y), mix(mix(getHash(p + vec3(0, 0, 1)), getHash(p + vec3(1, 0, 1)), f.x), mix(getHash(p + vec3(0, 1, 1)), getHash(p + vec3(1, 1, 1)), f.x), f.y), f.z);
} // Noise function created by Inigo Quilez

float getFBM(vec3 p) {
    float noise = 0.0;

    vec3 warp = vec3(getNoise(p * 0.8 + vec3(13.0, 44.0, 15.0)), getNoise(p * 0.8 + vec3(43.0, 74.0, 25.0)), getNoise(p * 0.8 + vec3(33.0, 14.0, 75.0)));

    warp -= vec3(0.5);

    p += vec3(123.0, 234.0, 55.0);
    p += warp * 0.6;

    noise = getNoise(p) * 1.0 +
        getNoise(p * 2.02) * 0.49 +
        getNoise(p * 7.11) * 0.24 +
        getNoise(p * 13.05) * 0.12 +
        getNoise(p * 27.05) * 0.055 +
        getNoise(p * 55.25) * 0.0025 +
        getNoise(p * 96.25) * 0.00125;

    return noise;
} // Fractal Brownian Motion function created by Inigo Quilez

vec3 toLinear(vec3 c) {
    return pow(c, vec3(2.2));
}

vec3 toGamma(vec3 c) {
    return pow(c, vec3(1.0 / 2.2));
}

vec3 RotateY(vec3 pos, float angle) {
    return vec3(pos.x * cos(angle) - pos.z * sin(angle), pos.y, pos.x * sin(angle) + pos.z * cos(angle));
}

vec3 RotateX(vec3 pos, float angle) {
    return vec3(pos.x, pos.y * cos(angle) - pos.z * sin(angle), pos.y * sin(angle) + pos.z * cos(angle));
}

#endif