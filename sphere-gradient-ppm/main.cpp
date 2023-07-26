#include "../headers/color.h"
#include "../headers/ray.h"
#include "../headers/vec3.h"

#include <iostream>

// Function that returns a gradient background color.
color rayColor(const ray &r) {
    vec3 unit_dir = unitVec(r.direction());                             // Translates ray into a normalized unit vector.
    auto t = 0.5 * (unit_dir.y() + 1.0);                                // -1.0 < y < 1.0 after normalization. Therefore 0 < t < 1.0.
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
            auto u = double(j) / (img_width - 1);
            auto v = double(i) / (img_height - 1);
            ray r(origin, lower_left_corner + u * horizontal + v * vertical - origin);
            color pixel_color = rayColor(r);
            writeColor(std::cout, pixel_color);
        }
    }

    std::cerr << "\nDone scanning.\n";
}