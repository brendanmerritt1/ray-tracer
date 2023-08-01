/**
    Common helper functions used for ray tracing.
*/

#ifndef HELPERFUNC_GLSL
#define HELPERFUNC_GLSL

#include "./common.glsl"

// Constants
const float pi = 3.1415926535897932385;
float gSeed = 0.0;

// Structs
struct Ray {
    vec3 o;     // origin
    vec3 d;     // direction (set with normalized vector)
    float t;    // time
};

struct Camera {
    vec3 origin;
    vec3 lower_left_corner;
    vec3 horizontal;
    vec3 vertical;
    vec3 u, v, w;
    float lensRadius;
    float time0, time1;
};

struct HitRecord {
    vec3 pos;
    vec3 normal;
    float t;    // Ray parameter
};

struct Sphere {
    vec3 center;
    float radius;
};

struct MovingSphere {
    vec3 center0, center1;
    float radius;
    float time0, time1;
};

// Ray Functions
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

vec3 pointOnRay(Ray r, float t) {
    return r.o + r.d * t;
}

// Camera Functions
Camera createCamera(vec3 look_from, vec3 look_at, vec3 world_up, float fov_y, float aspect, float aperture, float focus_dist, float time0, float time1) {
    float theta = fov_y * pi / 180.0;
    float half_height = tan(theta * 0.5);
    float half_width = aspect * half_height;

    Camera cam;
    cam.lensRadius = aperture * 0.5;
    cam.origin = look_from;
    cam.w = normalize(look_from - look_at);
    cam.u = normalize(cross(world_up, cam.w));
    cam.v = cross(cam.w, cam.u);

    cam.lower_left_corner = cam.origin - half_width * focus_dist * cam.u - half_height * focus_dist * cam.v - cam.w * focus_dist;
    cam.horizontal = 2.0 * half_width * focus_dist * cam.u;
    cam.vertical = 2.0 * half_height * focus_dist * cam.v;
    cam.time0 = time0;
    cam.time1 = time1;
    return cam;
}

Camera createCamera(vec3 look_from, vec3 look_at, vec3 world_up, float fov_y, float aspect, float aperture, float focus_dist) {
    return createCamera(look_from, look_at, world_up, fov_y, aspect, aperture, focus_dist, 0.0, 0.0);
}

Camera createCamera(vec3 look_from, vec3 look_at, vec3 world_up, float fov_y, float aspect) {
    return createCamera(look_from, look_at, world_up, fov_y, aspect, 0.0, 1.0);
}

// Sphere Functions
Sphere createSphere(vec3 center, float radius) {
    Sphere s;
    s.center = center;
    s.radius = radius;
    return s;
}

MovingSphere createMovingSphere(vec3 center0, vec3 center1, float radius, float time0, float time1) {
    MovingSphere s;
    s.center0 = center0;
    s.center1 = center1;
    s.radius = radius;
    s.time0 = time0;
    s.time1 = time1;
    return s;
}

vec3 center(MovingSphere mv_sphere, float time) {
    return mv_sphere.center0 + ((time - mv_sphere.time0) / (mv_sphere.time1 - mv_sphere.time0)) * (mv_sphere.center1 - mv_sphere.center0);
}

bool hitSphere(Sphere s, Ray r, float t_min, float t_max, out HitRecord rec) {
    vec3 origin_center = r.o - s.center;
    float a = dot(r.d, r.d);
    float b = 2.0 * dot(origin_center, r.d);
    float c = dot(origin_center, origin_center) - s.radius * s.radius;
    float discriminant = b * b - 4.0 * a * c;

    if(discriminant > 0.0) {
        float sqrt_discriminant = sqrt(discriminant);
        float root = (-b - sqrt_discriminant) / (2.0 * a);
        if(root < t_max && root > t_min) {
            rec.t = root;
            rec.pos = pointOnRay(r, rec.t);
            rec.normal = (rec.pos - s.center) / s.radius;
            return true;
        }
        root = (-b + sqrt_discriminant) / (2.0 * a);
        if(root < t_max && root > t_min) {
            rec.t = root;
            rec.pos = pointOnRay(r, rec.t);
            rec.normal = (rec.pos - s.center) / s.radius;
            return true;
        }
    }
    return false;
}

bool hitMovingSphere(MovingSphere s, Ray r, float t_min, float t_max, out HitRecord rec) {
    vec3 sphere_center = center(s, r.t);
    vec3 origin_center = r.o - sphere_center;
    float a = dot(r.d, r.d);
    float b = 2.0 * dot(origin_center, r.d);
    float c = dot(origin_center, origin_center) - s.radius * s.radius;
    float discriminant = b * b - 4.0 * a * c;

    if(discriminant > 0.0) {
        float sqrt_discriminant = sqrt(discriminant);
        float root = (-b - sqrt_discriminant) / (2.0 * a);
        if(root < t_max && root > t_min) {
            rec.t = root;
            rec.pos = pointOnRay(r, rec.t);
            rec.normal = (rec.pos - sphere_center) / s.radius;
            return true;
        }
        root = (-b + sqrt_discriminant) / (2.0 * a);
        if(root < t_max && root > t_min) {
            rec.t = root;
            rec.pos = pointOnRay(r, rec.t);
            rec.normal = (rec.pos - sphere_center) / s.radius;
            return true;
        }
    }
    return false;
}

#endif