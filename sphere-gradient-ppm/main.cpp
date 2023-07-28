#include "../headers/camera.h"
#include "../headers/color.h"
#include "../headers/constants.h"
#include "../headers/ray.h"
#include "../headers/sphere.h"
#include "../headers/surface_list.h"
#include "../headers/vec3.h"

#include <iostream>

// Function that will determine if a ray P(t) will hit the sphere.
double hitSphere(const point3 &center, double radius, const ray &r) {
    vec3 origin_to_center = r.origin() - center;             // Vector from center C to point P = (P-C). Full expanded equation: t^2*b*b + t*2*b*(A-C) + (A-C)*(A-C)-r^2 = 0
    auto a = r.direction().len_sq();                         // a = b*b. Vector dotted with itself is equal to square length of that vector.
    auto b = 2.0 * dotProd(origin_to_center, r.direction()); // b = 2*b*(A-C)
    auto c = origin_to_center.len_sq() - radius * radius;    // c = (A-C)*(A-C)-r^2
    auto discriminant = b * b - 4.0 * a * c;                 // Discriminant determines how many roots exist. If d > 0, two real solutions. If d = 0, one real solution.
    if (discriminant < 0) {
        return -1.0; // If no real solutions, t = -1.
    } else {
        return (-b - std::sqrt(discriminant)) / (2.0 * a); // If at least one real solution, 0 <= t <= 1.
    }
}

// Function that calculates the color of a pixel based on the direction of a ray.
color rayColor(const ray &r, const surface &world) {
    hit_record rec; // Determine the hit point of the ray on the sphere, if it exists.
    if (world.hit(r, 0, infinity, rec)) {
        return 0.5 * (rec.normal + color(1, 1, 1));
    }
    vec3 unit_dir = unitVec(r.direction());                             // Translates ray into a normalized unit vector.
    auto t = 0.5 * (unit_dir.y() + 1.0);                                // -1.0 < y < 1.0 after normalization. Therefore 0.0 < t < 1.0.
    return (1.0 - t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0); // Linear interpolation: blended = (1-t)*startVal + t*endVal
}

int main() {
    // Image
    const auto aspect_ratio = 16.0 / 9.0;
    const int img_width = 400;
    const int img_height = static_cast<int>(img_width / aspect_ratio);
    const int samples_per_pixel = 100;

    // World
    sphere_list world;
    world.add(make_shared<sphere>(point3(0, 0, -1), 0.5));
    world.add(make_shared<sphere>(point3(0, -100.5, -1), 100));

    // Camera
    camera cam;

    // Render
    std::cout << "P3\n"
              << img_width << " " << img_height << "\n255\n";

    for (int i = img_height - 1; i >= 0; --i) {
        std::cerr << "\rRows remaining to scan: " << i << ' ' << std::flush;
        for (int j = 0; j < img_width; ++j) {
            color pixel_color(0, 0, 0);
            for (int s = 0; s < samples_per_pixel; ++s) {
                auto u = (j + random_double()) / (img_width - 1);  // Vector horizontal component
                auto v = (i + random_double()) / (img_height - 1); // Vector vertical component
                ray r = cam.getRay(u, v);
                pixel_color += rayColor(r, world);
            }
            writeColor(std::cout, pixel_color, samples_per_pixel);
        }
    }

    std::cerr << "\nDone scanning.\n";
}