#ifndef RAY_H
#define RAY_H

#include "vec3.h"

class ray {
  public:
    point3 orig;
    vec3 dir;

  public:
    ray() {}
    ray(const point3 &origin, const vec3 &direction)
        : orig(origin), dir(direction) {}

    point3 origin() const { return orig; }
    vec3 direction() const { return dir; }

    // Ray as a linear function: P(t) = A + tb, where A is ray origin, b is direction, and t is real number.
    point3 rayFunc(double t) const {
        return orig + t * dir;
    }
};

#endif