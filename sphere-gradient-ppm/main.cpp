#include "../headers/color.h"
#include "../headers/ray.h"
#include "../headers/vec3.h"

#include <iostream>

// Function that will determine if a ray P(t) will hit the sphere.
double hitSphere(const point3 &center, double radius, const ray &r) {
    vec3 origin_to_center = r.origin() - center;             // Vector from center C to point P = (P-C). Full expanded equation: t^2*b*b + t*2*b*(A-C) + (A-C)*(A-C)-r^2 = 0
    auto a = r.direction().len_sq();                         // a = b*b. Vector dotted with itself is equal to square length of that vector.
    auto b = 2.0 * dotProd(origin_to_center, r.direction()); // b = 2*b*(A-C)
    auto c = origin_to_center.len_sq() - radius * radius;    // c = (A-C)*(A-C)-r^2
    auto discriminant = b * b - 4.0 * a * c;                   // Discriminant determines how many roots exist. If d > 0, two real solutions. If d = 0, one real solution.
    if (discriminant < 0) {
        return -1.0; // If no real solutions, t = -1.
    } else {
        return (-b - std::sqrt(discriminant)) / (2.0 * a); // If at least one real solution, 0 <= t <= 1.
    }
}

// Function that calculates the color of a pixel based on the direction of a ray.
color rayColor(const ray &r) {
    auto t = hitSphere(point3(0, 0, -1), 0.5, r); // Determine the hit point of the ray on the sphere, if it exists.
    if (t > 0.0) {
        vec3 norm_vec = unitVec(r.rayFunc(t) - vec3(0, 0, -1));                   // Use the calculated hit point to compute a normalized vector (perpendicular to surface).
        return 0.5 * color(norm_vec.x() + 1, norm_vec.y() + 1, norm_vec.z() + 1); // Mapping x/y/z to r/g/b.
    }
    vec3 unit_dir = unitVec(r.direction());                             // Translates ray into a normalized unit vector.
    t = 0.5 * (unit_dir.y() + 1.0);                                     // -1.0 < y < 1.0 after normalization. Therefore 0.0 < t < 1.0.
    return (1.0 - t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0); // Linear interpolation: blended = (1-t)*startVal + t*endVal
}

int main() {
    // Image
    const auto aspect_ratio = 16.0 / 9.0;
    const int img_width = 400;
    const int img_height = static_cast<int>(img_width / aspect_ratio);

    // Camera
    auto viewport_height = 2.0;
    auto viewport_width = aspect_ratio * viewport_height;
    auto focal_length = 1.0; // Distance between projection point (origin) and projection plane (viewport).

    auto origin = point3(0, 0, 0);
    auto horizontal = vec3(viewport_width, 0, 0);
    auto vertical = vec3(0, viewport_height, 0);
    auto lower_left_corner = origin - horizontal / 2 - vertical / 2 - vec3(0, 0, focal_length);

    // Render
    std::cout << "P3\n"
              << img_width << " " << img_height << "\n255\n";

    for (int i = img_height - 1; i >= 0; --i) {
        std::cerr << "\rRows remaining to scan: " << i << ' ' << std::flush;
        for (int j = 0; j < img_width; ++j) {
            auto u = double(j) / (img_width - 1);  // Vector horizontal component
            auto v = double(i) / (img_height - 1); // Vector vertical component
            ray r = ray(origin, lower_left_corner + u * horizontal + v * vertical - origin);
            color pixel_color = rayColor(r);
            writeColor(std::cout, pixel_color);
        }
    }

    std::cerr << "\nDone scanning.\n";
}