#ifndef SURFACE_LIST_H
#define SURFACE_LIST_H

#include "surface.h"

#include <memory>
#include <vector>

using std::make_shared;
using std::shared_ptr;

class sphere_list : public surface {
  public:
    std::vector<shared_ptr<surface>> objects;

  public:
    sphere_list() {}
    sphere_list(shared_ptr<surface> object) { add(object); }

    void clear() { objects.clear(); }
    void add(shared_ptr<surface> object) { objects.push_back(object); }

    virtual bool hit(const ray &r, double t_min, double t_max, hit_record &rec) const override;
};

bool sphere_list::hit(const ray& r, double t_min, double t_max, hit_record& rec) const {
    hit_record temp_rec;
    bool hit_anything = false;
    auto closest = t_max;

    for (const auto& object : objects) {
        if (object->hit(r, t_min, closest, temp_rec)) {
            hit_anything = true;
            closest = temp_rec.t;
            rec = temp_rec;
        }
    }

    return hit_anything;
}

#endif