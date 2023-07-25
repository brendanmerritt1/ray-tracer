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
            auto r = double(j) / (img_width - 1);
            auto g = double(i) / (img_height - 1);
            auto b = 0.25;

            // RGB components range from 0.0 to 1.0.
            int ir = static_cast<int>(255.999 * r);
            int ig = static_cast<int>(255.999 * g);
            int ib = static_cast<int>(255.999 * b);

            std::cout << ir << ' ' << ig << ' ' << ib << '\n';
        }
    }

    std::cerr << "\nDone scanning.\n";
}