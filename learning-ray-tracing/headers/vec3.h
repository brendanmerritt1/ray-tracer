#ifndef VEC3_H
#define VEC3_H

#include <cmath>
#include <iostream>

class vec3 {
  public:
    // Coordinate vector triplet.
    double e[3];

  public:
    // Constructor overloading vec3.
    vec3() : e{0, 0, 0} {}
    vec3(double e0, double e1, double e2) : e{e0, e1, e2} {}

    double x() const { return e[0]; }
    double y() const { return e[1]; }
    double z() const { return e[2]; }

    vec3 operator-() const { return vec3(-e[0], -e[1], -e[2]); }
    // double operator[](int i) const { return e[i]; }
    // double& operator[](int i) { return e[i]; }

    vec3 &operator+=(const vec3 &v) {
        e[0] += v.e[0];
        e[1] += v.e[1];
        e[2] += v.e[2];
        return *this;
    }

    vec3 &operator*=(const double t) {
        e[0] *= t;
        e[1] *= t;
        e[2] *= t;
        return *this;
    }

    vec3 &operator/=(const double t) {
        return *this *= 1 / t;
    }

    double len_sq() const {
        return e[0] * e[0] + e[1] * e[1] + e[2] * e[2];
    }

    double len() const {
        return std::sqrt(len_sq());
    }

    static vec3 random() {
        return vec3(random_double(), random_double(), random_double());
    }

    static vec3 random(double min, double max) {
        return vec3(random_double(min, max), random_double(min, max), random_double(min, max));
    }
};

// Aliases for vec3.
using point3 = vec3; // 3D point
using color = vec3;  // RGB color

// vec3 utility functions
// Operator overloading functions.
std::ostream &operator<<(std::ostream &out, const vec3 &v) {
    return out << v.e[0] << ' ' << v.e[1] << ' ' << v.e[2];
}

vec3 operator+(const vec3 &u, const vec3 &v) {
    return vec3(u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2]);
}

vec3 operator-(const vec3 &u, const vec3 &v) {
    return vec3(u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2]);
}

vec3 operator*(const vec3 &u, const vec3 &v) {
    return vec3(u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2]);
}

vec3 operator*(double t, const vec3 &v) {
    return vec3(t * v.e[0], t * v.e[1], t * v.e[2]);
}

vec3 operator*(const vec3 &v, double t) {
    return t * v;
}

vec3 operator/(vec3 v, double t) {
    return (1 / t) * v;
}

double dotProd(const vec3 &u, const vec3 &v) {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

vec3 crossProd(const vec3 &u, const vec3 &v) {
    return vec3(u.e[1] * v.e[2] - u.e[2] * v.e[1],
                u.e[2] * v.e[0] - u.e[0] * v.e[2],
                u.e[0] * v.e[1] - u.e[1] * v.e[0]);
}

vec3 unitVec(vec3 v) {
    return v / v.len();
}

vec3 random_in_unit_sphere() {
    while (true) {
        auto p = vec3::random(-1, 1); // Pick a random point in the unit cube where x,y,z all range from -1 to 1.
        if (p.len_sq() >= 1)
            continue; // If point is outside the sphere, reject the point and try again.
        return p;
    }
}

#endif