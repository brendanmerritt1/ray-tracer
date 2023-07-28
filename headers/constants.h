#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <cstdlib>
#include <limits>

// Constants
const double infinity = std::numeric_limits<double>::infinity();
const double pi = 3.1415926535897932385;

// Utility Functions
double degrees_to_radians(double degrees) {
    return degrees * pi / 180;
}

double random_double() {
    // Returns a random real number in [0,1).
    return rand() / (RAND_MAX + 1.0);
}

double random_double(double min, double max) {
    // Returns a random real number in [min, max).
    return min + (max - min) * random_double();
}

double clamp(double x, double min, double max) {
    // Limits the value x to the range [min, max].
    if (x < min) return min;
    if (x > max) return max;
    return x;
}

#endif