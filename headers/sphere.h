#ifndef SPHERE_H
#define SPHERE_H

#include "surface.h"
#include "vec3.h"

class sphere : public surface {
  public:
    point3 center;
    double radius;

  public:
    sphere() {}
    sphere(point3 cent, double rad) : center(cent), radius(rad){};

    virtual bool hit(const ray &r, double t_min, double t_max, hit_record &rec) const;
};

bool sphere::hit(const ray &r, double t_min, double t_max, hit_record &rec) const {
    vec3 origin_to_center = r.origin() - center;
    auto a = r.direction().len_sq();
    auto b = 2.0 * dotProd(origin_to_center, r.direction());
    auto c = origin_to_center.len_sq() - radius * radius;
    auto discriminant = b * b - 4.0 * a * c;
    if (discriminant < 0)
        return false;
    auto sqrtd = std::sqrt(discriminant);

    // Find nearest root that lies in the acceptable range.
    auto root = (-b - sqrtd) / (2 * a);
    if (root < t_min || root > t_max) {
        root = (-b + sqrtd) / (2 * a);
        if (root < t_min || root > t_max) {
            return false;
        }
    }

    rec.t = root;
    rec.p = r.rayFunc(rec.t);
    vec3 outward_normal = (rec.p - center) / radius;
    rec.setFaceNormal(r, outward_normal);

    return true;
};

#endif