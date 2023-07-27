#ifndef COLOR_H
#define COLOR_H

#include "vec3.h"
#include <iostream>

// Utility function to write a single pixel's color out to standard output stream.
void writeColor(std::ostream &out, color pixel_color)
{
    // Writes the translated [0,255] value of each color component.
    out << static_cast<int>(255.999 * pixel_color.x()) << ' '
        << static_cast<int>(255.999 * pixel_color.y()) << ' '
        << static_cast<int>(255.999 * pixel_color.z()) << '\n';
}

#endif