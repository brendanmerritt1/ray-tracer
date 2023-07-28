#ifndef SURFACE_H
#define SURFACE_H

#include "ray.h"

struct hit_record {
    point3 p;
    vec3 normal;
    double t;
    bool front_face;

    void setFaceNormal(const ray &r, const vec3 &outward_normal) { // Front face tracking. Normal should always point against the ray.
        front_face = dotProd(r.direction(), outward_normal) < 0;   // If ray and normal face in opposite directions, then the ray is outside the object.
        normal = front_face ? outward_normal : -outward_normal;
    }
};

class surface {
  public:
    virtual bool hit(const ray &r, double t_min, double t_max, hit_record &rec) const = 0;
};

#endif