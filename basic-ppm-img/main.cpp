#include "color.h"
#include "vec3.h"
#include <iostream>

// An RGB image stored in PPM format.
int main()
{

    const int img_width = 256;
    const int img_height = 256;

    // P3 -> colors are in ASCII.
    // 256 columns and 256 rows.
    // Max color value -> 255.
    std::cout << "P3\n"
              << img_width << ' ' << img_height << "\n255\n";

    // Iterate through every pixel in the 256x256 space.
    for (int i = img_height - 1; i >= 0; --i)
    {
        // Progress indicator for tracking the progress of a render.
        std::cerr << "\rRows remaining to scan: " << i + 1 << '\n' << std::flush;

        for (int j = 0; j < img_width; ++j)
        {
            color pixel_color(double(j)/(img_width-1), double(i)/(img_height-1), 0.25);
            writeColor(std::cout, pixel_color);
        }
    }

    std::cerr << "\nDone scanning.\n";
}