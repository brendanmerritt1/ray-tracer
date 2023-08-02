#ifndef COMMON_GLSL
#define COMMON_GLSL

/**
    Constants
**/
const float PI = 3.14159265359;
const float PHI = 1.61803398875;

/**
    Structs
**/
struct Ray {
    vec3 o;     // origin
    vec3 d;     // direction (set with normalized vector)
    float t;    // time
};

/**
    Ray Functions
**/
Ray createRay(vec3 o, vec3 d, float t) {
    Ray r;
    r.o = o;
    r.d = d;
    r.t = t;
    return r;
}

Ray createRay(vec3 o, vec3 d) {
    return createRay(o, d, 0.0);
}

/**
    Sphere Functions
**/
vec2 sphIntersect(in vec3 ro, in vec3 rd, in vec3 center, float radius) {
    vec3 origin_center = ro - center;
    float b = dot(origin_center, rd);
    float c = dot(origin_center, origin_center) - radius * radius;
    float discriminant = b * b - c;
    if(discriminant < 0.0)
        return vec2(-1.0);
    discriminant = sqrt(discriminant);
    return vec2(-b - discriminant, -b + discriminant);
}

/**
    Utility Functions - Credit to Inigo Quilez for providing many of these functions
**/
vec3 RotateY(vec3 pos, float angle) {
    return vec3(pos.x * cos(angle) - pos.z * sin(angle), pos.y, pos.x * sin(angle) + pos.z * cos(angle));
}

vec3 RotateX(vec3 pos, float angle) {
    return vec3(pos.x, pos.y * cos(angle) - pos.z * sin(angle), pos.y * sin(angle) + pos.z * cos(angle));
}

float getHash(vec3 p) {
    p = fract(p * 0.3183099 + .1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
} // Hash function created by Inigo Quilez

float getHashFloat(float p) {
    return fract(sin(p) * 158.5453123);
} // Hash function created by Inigo Quilez

float getNoise(in vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    return mix(mix(mix(getHash(p + vec3(0, 0, 0)), getHash(p + vec3(1, 0, 0)), f.x), mix(getHash(p + vec3(0, 1, 0)), getHash(p + vec3(1, 1, 0)), f.x), f.y), mix(mix(getHash(p + vec3(0, 0, 1)), getHash(p + vec3(1, 0, 1)), f.x), mix(getHash(p + vec3(0, 1, 1)), getHash(p + vec3(1, 1, 1)), f.x), f.y), f.z);
} // Noise function created by Inigo Quilez

float getFBM(vec3 p) {
    float noise = 0.0;

    // Domain warping - using fBm to warp the space of a fBm (analogy: dream in a dream)
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
} // Fractal Brownian Motion function created by Inigo Quilez. A simple sum of noise waves with increasing frequencies and decreasing amplitudes.

float getFBMClouds(vec3 p) {
    float noise = 0.0;
    // Domain warping
    vec3 warp = vec3(getNoise(p * 0.8 + vec3(13.0, 44.0, 15.0)), getNoise(p * 0.8 + vec3(43.0, 74.0, 25.0)), getNoise(p * 0.8 + vec3(33.0, 14.0, 75.0)));

    warp -= vec3(0.5);

    p += vec3(123.0, 234.0, 55.0);
    p += warp * 0.2;

    noise = getNoise(p) * 1.0 +
        getNoise(p * 5.02) * 0.49 +
        getNoise(p * 11.11) * 0.24 +
        getNoise(p * 23.05) * 0.12 +
        getNoise(p * 45.05) * 0.055;
    return noise;
} // Fractal Brownian Motion function created by Inigo Quilez.

vec2 inverseSF(vec3 p, float n) {
    float m = 1.0 - 1.0 / n;

    float phi = min(atan(p.y, p.x), PI), cosTheta = p.z;

    float k = max(2.0, floor(log(n * PI * sqrt(5.0) * (1.0 - cosTheta * cosTheta)) / log(PHI + 1.0)));
    float Fk = pow(PHI, k) / sqrt(5.0);
    vec2 F = vec2(round(Fk), round(Fk * PHI));

    vec2 ka = 2.0 * F / n;
    vec2 kb = 2.0 * PI * (fract((F + 1.0) * PHI) - (PHI - 1.0));

    mat2 iB = mat2(ka.y, -ka.x, kb.y, -kb.x) / (ka.y * kb.x - ka.x * kb.y);

    vec2 c = floor(iB * vec2(phi, cosTheta - m));
    float d = 8.0;
    float j = 0.0;
    for(int s = 0; s < 4; s++) {
        vec2 uv = vec2(float(s - 2 * (s / 2)), float(s / 2));

        float i = dot(F, uv + c);

        float phi = 2.0 * PI * fract(i * PHI);
        float cosTheta = m - 2.0 * i / n;
        float sinTheta = sqrt(1.0 - cosTheta * cosTheta);

        vec3 q = vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
        float squaredDistance = dot(q - p, q - p);
        if(squaredDistance < d) {
            d = squaredDistance;
            j = i;
        }
    }
    return vec2(j, sqrt(d));
} // Inverse Spherical Fibonacci points created by Inigo Quilez.

float getSceneDistance(vec3 ro, vec3 rd, vec3 center, float radius, float MAX_DIST) {
    vec2 intersect = sphIntersect(ro, rd, center, radius);
    if(intersect.x >= 0.0) {
        return intersect.x;
    } else {
        return MAX_DIST;
    }
}

float getLight(vec3 LIGHT_POS, vec3 PLANET_CENTER, float PLANET_RADIUS, float SURF_DIST, float MAX_DIST, vec3 p, vec3 n, float height, float waterMask) {
    vec3 light_pos = LIGHT_POS;
    vec3 l = normalize(light_pos - p);

    // Computes the normal with two height samples (only computing one extra here)
    vec3 planet_bisect = normalize(p + l * 0.01 - PLANET_CENTER) * 0.5 * PLANET_RADIUS;
    planet_bisect = RotateY(planet_bisect, iTime * 0.05);
    float height_bisect = getFBM(planet_bisect) * 0.6;
    float deltaH = height_bisect - height;

    n = normalize(n - deltaH * l * 40.0 * (1.0 - waterMask));

    float diffuse = dot(n, l); // Used for lights at night
    float d = getSceneDistance(p + n * SURF_DIST * 2.0, l, PLANET_CENTER, PLANET_RADIUS, MAX_DIST);
    if(d < length(light_pos - p))
        diffuse *= 0.1;

    return diffuse;
}

float Density(vec3 pos, vec3 PLANET_CENTER, float PLANET_RADIUS, float ATMOS_THICK, float ATMOS_DENS) {
    float distance_to_center = length(pos - PLANET_CENTER);
    float relative_pos = clamp((distance_to_center - PLANET_RADIUS) / ATMOS_THICK, 0.0, 1.0);

    return ATMOS_DENS * exp(-relative_pos);
}

#endif