#ifndef VIBE_DOOM_PORT_MATH_H
#define VIBE_DOOM_PORT_MATH_H

/* x87-backed freestanding subset; not a complete hosted libm. */
double sin(double x);
double cos(double x);
double atan(double x);
double atan2(double y, double x);
double pow(double x, double y);
double sqrt(double x);
double floor(double x);
double ceil(double x);
double fabs(double x);

#endif
