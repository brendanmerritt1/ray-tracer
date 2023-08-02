#include "./common.glsl"

#iChannel0 "self"
#iChannel1 "https://stionary.sirv.com/Images/noise.png"

// Initial Conditions
#define MAX_STEPS 100.0
#define MAX_DIST 10000.0
#define SURF_DIST 0.001
#define OCEANS_LEVEL 0.60
#define PLANET_CENTER vec3(-3, -3, 25)
#define PLANET_RADIUS 7.0
#define MOON_CENTER vec3(53, -50, 145)
#define MOON_RADIUS 7.0
#define ATMOS_THICK 0.25
#define ATMOS_DENS 2.0
#define LIGHT_POS vec3(40, 25, -5)

vec3 rayTrace(Ray r, vec4 noise) {
    vec3 color = vec3(0, 0, 0);
    vec2 atmos = sphIntersect(r.o, r.d, PLANET_CENTER, ATMOS_THICK + PLANET_RADIUS);
    float dist = getSceneDistance(r.o, r.d, PLANET_CENTER, PLANET_RADIUS, MAX_DIST);

    if(dist < MAX_DIST) {
        // Ray hits planet
        atmos.y = dist;
        vec3 pos = r.o + r.d * dist;
        vec3 norm = normalize(pos - PLANET_CENTER);
        vec3 local_pos = (pos - PLANET_CENTER) * 0.5;
        local_pos = RotateY(local_pos, iTime * 0.05);

        // Water noise
        float heat_distribution = smoothstep(4.5, 0.25, (abs(local_pos.y) + getNoise(local_pos + vec3(-20, 55, 20))));
        float height = getFBM(local_pos) * 0.50;
        float water = smoothstep(OCEANS_LEVEL + 0.02, OCEANS_LEVEL - 0.05, height);
        float waterHeight = clamp((height / OCEANS_LEVEL), 0.0, 1.1);

        // Shallow water
        float foamNoise = getNoise(local_pos * 7.0 * (0.75 + 0.25 * sin(iTime * 0.1))) * 0.25;
        float foamLimit = smoothstep(0.65 + foamNoise, 1.0, waterHeight);
        foamLimit = 0.7 * foamLimit + 0.3 * fract(foamLimit * 4.0 - iTime * 0.2) * foamLimit * smoothstep(1.0, 0.85, foamLimit);

        // Combining various water shades
        vec3 warmWaterColor = mix(vec3(0.0, 0.2, 0.6), vec3(0.0, 0.4, 1.0), smoothstep(0.0, 1.0, waterHeight));
        vec3 coolWaterColor = mix(vec3(0.15, 0.3, 0.5), vec3(0.2, 0.5, 0.7), smoothstep(0.0, 1.0, waterHeight));
        vec3 waterColor = mix(coolWaterColor, warmWaterColor, heat_distribution);
        waterColor = mix(waterColor, vec3(0.7, 0.8, 0.9), foamLimit);

        // Ice generation
        float iceDistribution = smoothstep(3.8, 4.3, foamLimit + smoothstep(0.7, 0.85, height) * 0.25 + (abs(local_pos.y) - water * 0.5 + getNoise(local_pos + vec3(-20, 55, 20))));
        float wideIceDistribution = smoothstep(2.5, 3.0, foamLimit + smoothstep(0.7, 0.85, height) * 0.25 + (abs(local_pos.y) - water * 0.5 + height * 0.5));
        float flatten = water * (1.0 - iceDistribution);
        flatten = max(flatten, iceDistribution * 0.75);

        // Land generation
        float groundHeight = clamp(((height - OCEANS_LEVEL) / (1.0 - OCEANS_LEVEL)), 0.0, 1.0);
        vec3 groundColor = mix(vec3(0.4, 0.1, 0.0), vec3(1.0, 0.5, 0.4), clamp(groundHeight * 3.0, 0.0, 1.0));

        vec3 finalColor = mix(groundColor, waterColor, water);
        finalColor = mix(finalColor, mix(vec3(1.1, 1.1, 1.1), vec3(0.9, 1.0, 1.0), abs(sin(height * 10.0))), iceDistribution);

        // Lighting and shadows
        float light = getLight(LIGHT_POS, PLANET_CENTER, PLANET_RADIUS, SURF_DIST, MAX_DIST, pos, norm, height, flatten);
        float light_diffuse = clamp(light, 0.0, 1.0);
        float inv_light_diffuse = smoothstep(0.1, 0.05, light);
        vec3 light_pos = LIGHT_POS;
        vec3 norm_light = normalize(light_pos - pos);
        float rawNormDotL = clamp(dot(norm, norm_light), 0.0, 1.0);
        light_diffuse = max(light_diffuse, rawNormDotL * 0.7);
        light_diffuse *= rawNormDotL;
        float fresnel = pow(1.0 - clamp(dot(norm, -r.d), 0.0, 1.0), 3.0);
        inv_light_diffuse *= (1.0 - fresnel);
        light_diffuse *= (1.0 - fresnel);

        color = vec3(light_diffuse) * finalColor;

        // Trees and cities
        float citiesLimit = smoothstep(0.0, 0.1, groundHeight) * smoothstep(0.15, 0.13, groundHeight) * (1.0 - water) * (1.0 - iceDistribution);
        float greenArea = smoothstep(0.0, 0.01, groundHeight) * smoothstep(0.45, 0.3, groundHeight) * (1.0 - water) * (1.0 - wideIceDistribution);
        vec2 city = inverseSF(normalize(local_pos), 140.0) + inverseSF(normalize(local_pos), 100.0);
        local_pos = normalize(local_pos);
        float town = smoothstep(0.28, 0.1, city.y);

        // Light intensity for cities
        vec2 light_info1 = inverseSF(local_pos, 20000.0);
        vec2 light_info2 = inverseSF(RotateX(local_pos, 1.0), 40000.0);
        vec2 light_info3 = inverseSF(RotateX(local_pos, 1.5), 30000.0);
        float light_intensity = min(min(light_info1.y * 1.25 * (1.0 + smoothstep(0.8, 0.4, getHashFloat((light_info1.x) * 0.02))), light_info2.y * 1.75 * (1.0 + smoothstep(0.8, 0.4, getHashFloat((light_info1.x) * 0.02)))), light_info3.y * (1.0 + smoothstep(0.8, 0.4, getHashFloat((light_info1.x) * 0.02))));
        light_intensity = smoothstep(0.01, 0.0, light_intensity);

        // Applying trees and cities to world
        float cityArea = smoothstep(0.2, 0.18, city.y) * citiesLimit;
        citiesLimit *= town * light_intensity;
        greenArea *= smoothstep(0.4, 0.3, city.y) * smoothstep(0.25, 0.28, city.y);
        color = mix(color, vec3(light_diffuse) * mix(vec3(0.45, 0.65, 0.15), vec3(0.1, 0.35, 0.1), getNoise(local_pos * 200.0)), clamp(greenArea - getNoise(local_pos * 100.0) * 0.5, 0.0, 1.0));
        color = mix(color, vec3(0.15), cityArea);
        color = mix(color, vec3(0.25), clamp(citiesLimit * 2.0, 0.0, 1.0));
        color += vec3(0.95, 0.8, 0.5) * inv_light_diffuse * citiesLimit * 2.0;

        // Clouds
        vec3 local_pos_clouds = (pos - PLANET_CENTER) * 0.25;
        local_pos_clouds = RotateY(local_pos_clouds, iTime * 0.05 + local_pos_clouds.y * 0.85);
        float clouds = getFBMClouds(local_pos_clouds * 3.0 - vec3(iTime * 0.025)) * 0.6;
        vec3 local_pos_clouds_bisect = (pos + norm_light * 0.1 - PLANET_CENTER) * 0.25;
        local_pos_clouds_bisect = RotateY(local_pos_clouds_bisect, iTime * 0.05);
        float clouds_bisect = getFBMClouds(local_pos_clouds_bisect * 3.0 - vec3(iTime * 0.025)) * 0.6;
        float level = smoothstep(OCEANS_LEVEL - 0.1, OCEANS_LEVEL + 0.5, height);
        clouds = smoothstep(0.5 + level * 0.85, 0.8 + level * 0.85, clouds);
        float cloudShadow = 1.0 - smoothstep(0.5 + level * 0.85, 0.8 + level * 0.85, clouds_bisect) * 0.5 * (1.0 - clamp(dot(norm, norm_light), 0.0, 1.0));
        color = mix(color * cloudShadow, vec3(1.0) * rawNormDotL * cloudShadow, clouds);

    } else {
        vec2 intersect = sphIntersect(r.o, r.d, MOON_CENTER, MOON_RADIUS);
        if(intersect.x >= 0.0) {
            // Ray hits moon
            vec3 pos = intersect.x * r.d + r.o;
            vec3 norm = normalize(pos - MOON_CENTER);
            vec3 light_pos = LIGHT_POS;
            vec3 norm_light = normalize(light_pos - pos);
            float shadows = clamp(dot(norm_light, norm), 0.0, 1.0);
            float noise = getFBM(pos * 0.4);
            color = mix(vec3(0.2), vec3(0.4), noise) * shadows;
        } else {
            // Ray hits space
            color = vec3(0.06);
            vec3 pos = normalize(r.o + r.d * 1000.0);
            pos = pos.xyz;

            // Stars
            for(float i = 0.0; i < 5.0; ++i) {
                vec2 info = inverseSF(pos, 60000.0 + i * 1000.0);
                float random = getHashFloat((info.x + i * 20.0) * 0.01);
                float dist_to_star = smoothstep(0.0002 + 0.001 * pow((1.0 - random), 30.0), 0.0002, info.y) * smoothstep(0.1, 0.0, random);
                color = max(color, vec3(dist_to_star));
            }

            // Space noise (nebulae)
            float noise = getFBM(pos * 2.0 + vec3(0.0, 0.0, iTime * 0.05));
            float nebulae = smoothstep(0.4, 1.8, noise);
            float nebulae1 = max(0.3 - abs(nebulae - 0.3), 0.0);
            float nebulae2 = max(0.2 - abs(nebulae - 0.4), 0.0);
            float nebulae3 = max(0.1 - abs(nebulae - 0.5), 0.0);
            vec3 nebulaeColor = vec3(0.0, 0.2, 0.7) * nebulae1 + vec3(0.5, 0.4, 0.3) * nebulae2 + vec3(0.1, 0.2, 0.4) * nebulae3;
            color += nebulaeColor;
        }
    }
    if(atmos.x >= 0.0) {
        // Ray hits atmosphere
        atmos.x -= noise.r;
        float atmos_remaining = atmos.y - atmos.x;
        vec3 start_pos = r.o + r.d * atmos.x;
        float light_energy = 0.0;
        float transmittance = 1.0;
        float steps = 0.005;
        for(float i = 0.0; i < atmos_remaining; i += steps) {
            vec3 pos = start_pos + r.d * i;
            float loc_density = Density(pos, PLANET_CENTER, PLANET_RADIUS, ATMOS_THICK, ATMOS_DENS) * steps;
            vec3 light_dir = -normalize(pos - LIGHT_POS);
            float shadow = getSceneDistance(pos, light_dir, PLANET_CENTER, PLANET_RADIUS, MAX_DIST);
            shadow = step(MAX_DIST * 0.9, shadow);
            light_energy += loc_density * shadow;
            transmittance *= (1.0 - loc_density * 1.0);
        }
        color = mix(color, mix(vec3(0.1, 0.15, 0.7), vec3(0.65, 0.8, 1.0), (1.0 - exp(-light_energy * 0.6))) * clamp(light_energy * 0.5, 0.0, 1.0), (1.0 - transmittance) * (1.0 - exp(-light_energy * 0.6)));
    }
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 offset = vec3(sin(iTime * 0.1) * 3.0, 0.25 + (cos(iTime * 0.1) * .5), 0);
    offset = mix(offset, vec3(4.0 - iMouse.x / iResolution.x * 8.0, 4.0 - (iMouse.y / iResolution.y) * 8.0, 0), step(0.001, iMouse.z));
    vec4 noise = texture(iChannel1, fragCoord / 1024.0);

    vec3 ro = offset + vec3(0.0, 12.0, 0.0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 2));
    rd = RotateX(rd, 0.5);
    Ray r = createRay(ro, rd);
    vec3 col = rayTrace(r, noise);
    fragColor = vec4(col, 1.0);
}