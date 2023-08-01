#include "./common.glsl"
#include "./helperFunc.glsl"

#iChannel0 "self"

// Initial Conditions
#define MAX_STEPS 100.0
#define MAX_DIST 100.0
#define SURF_DIST 0.001
#define OCEANS_LEVEL 0.60
#define PLANET_CENTER vec3(-4, -3, 25)
#define PLANET_RADIUS 7.0
#define MOON_CENTER vec3(54, -50, 145)
#define MOON_RADIUS 7.0
#define ATMOS_THICK 0.5
#define ATMOS_DENS 2.0
#define LIGHT_POS vec3(20 * 3, 15 * 3, 10)

int hitSurface(Ray r, float t_min, float t_max, out HitRecord rec) {
    // 0 = planet
    // 1 = moon
    // 2 = atmosphere
    int hit;
    rec.t = t_max;

    if(hitSphere(createSphere(PLANET_CENTER, PLANET_RADIUS), r, t_min, rec.t, rec)) {
        hit = 0;
    } else if(hitSphere(createSphere(MOON_CENTER, MOON_RADIUS), r, t_min, rec.t, rec)) {
        hit = 1;
    } else {
        hit = 2;
    }

    return hit;
}

vec3 rayTrace(Ray r) {
    HitRecord rec;
    vec3 color = vec3(0, 0, 0);
    if(hitSurface(r, 0.001, 10000.0, rec) == 0) {
        // Ray hits planet
        vec3 pos = rec.pos;
        vec3 norm = rec.normal;

        vec3 local_pos = (pos - PLANET_CENTER) * 0.5;
        local_pos = RotateY(local_pos, iTime * 0.05);

        float heat_distribution = smoothstep(3.5, 0.25, (abs(local_pos.y) + getNoise(local_pos + vec3(-150, 65, 10))));
        float height = getFBM(local_pos) * 0.45;
        float water = smoothstep(OCEANS_LEVEL + 0.05, OCEANS_LEVEL - 0.05, height);
        float waterHeight = clamp((height / OCEANS_LEVEL), 0.0, 1.1);
        float foamNoise = getNoise(local_pos*5.0*(1.5+0.25*sin(iTime*0.1)))*0.25;
        float foamLimit = smoothstep(0.6+foamNoise, 1.0, waterHeight);

        vec3 warmWaterColor = mix(vec3(0.0, 0.2, 0.6), vec3(0.0, 0.4, 1.0), smoothstep(0.0, 1.0, waterHeight));
        vec3 coolWaterColor = mix(vec3(0.15, 0.3, 0.5), vec3(0.2, 0.5, 0.7), smoothstep(0.0, 1.0, waterHeight));
        vec3 waterColor = mix(coolWaterColor, warmWaterColor, heat_distribution);
        waterColor = mix(waterColor, vec3(0.7, 0.8, 0.9), foamLimit);
        vec3 finalColor = waterColor;
        color = finalColor;
    } else if(hitSurface(r, 0.001, 10000.0, rec) == 1) {
        // Ray hits moon
        vec3 pos = rec.pos;
        vec3 norm = rec.normal;
        vec3 light_pos = LIGHT_POS;
        vec3 l = normalize(light_pos - pos);
        float shadows = clamp(dot(l, norm), 0.0, 1.0);
        float noise = getFBM(pos * 0.4);
        color = mix(vec3(0.2), vec3(0.4), noise) * shadows;
    } else {
        // Ray hits atmosphere
        color = vec3(0.06);
    }
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 offset = vec3(sin(iTime * 0.1) * 3.0, 0.25 + (cos(iTime * 0.1) * .5), 0);
    offset = mix(offset, vec3(4.0 - iMouse.x / iResolution.x * 8.0, 4.0 - (iMouse.y / iResolution.y) * 8.0, 0), step(0.001, iMouse.z));

    vec3 ro = offset + vec3(0.0, 12.0, 0.0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 2));
    rd = RotateX(rd, 0.5);
    Ray r = createRay(ro, rd);
    vec3 col = rayTrace(r);
    fragColor = vec4(col, 1.0);
}