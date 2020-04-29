module sdl_gfx_primitives;

import derelict.sdl2.sdl;
import core.stdc.stdlib;
import std.math;

/* 

SDL2_gfxPrimitives.c: graphics primitives for SDL2 renderers

Copyright (C) 2012  Andreas Schiffler

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source
distribution.

Andreas Schiffler -- aschiffler at ferzkopp dot net

------

D translation by blackbird806

*/

alias Sint16 = short;
alias Uint8 = ubyte;

struct SDL2_gfxBresenhamIterator {
	Sint16 x, y;
	int dx, dy, s1, s2, swapdir, error;
	Uint32 count;
}

struct SDL2_gfxMurphyIterator {
	SDL_Renderer *renderer;
	int u, v;		/* delta x , delta y */
	int ku, kt, kv, kd;	/* loop constants */
	int oct2;
	int quad4;
	Sint16 last1x, last1y, last2x, last2y, first1x, first1y, first2x, first2y, tempx, tempy;
}


/*!
\brief Draw polygon with the currently set color and blend mode.

\param renderer The renderer to draw on.
\param vx Vertex array containing X coordinates of the points of the polygon.
\param vy Vertex array containing Y coordinates of the points of the polygon.
\param n Number of points in the vertex array. Minimum number is 3.

\returns Returns 0 on success, -1 on failure.
*/
int polygon(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n)
{
	/*
	* Draw 
	*/
	int result;
	int i, nn;
	SDL_Point* points;

	/*
	* Vertex array NULL check 
	*/
	if (vx == null) {
		return (-1);
	}
	if (vy == null) {
		return (-1);
	}

	/*
	* Sanity check 
	*/
	if (n < 3) {
		return (-1);
	}

	/*
	* Create array of points
	*/
	nn = n + 1;
	points = cast(SDL_Point*) malloc(SDL_Point.sizeof * nn);
	if (points == null)
	{
		return -1;
	}
	for (i=0; i<n; i++)
	{
		points[i].x = vx[i];
		points[i].y = vy[i];
	}
	points[n].x = vx[0];
	points[n].y = vy[0];

	/*
	* Draw 
	*/
	result |= SDL_RenderDrawLines(renderer, points, nn);
	free(points);

	return (result);
}

/*!
\brief Draw horizontal line with blending.

\param renderer The renderer to draw on.
\param x1 X coordinate of the first point (i.e. left) of the line.
\param x2 X coordinate of the second point (i.e. right) of the line.
\param y Y coordinate of the points of the line.
\param r The red value of the line to draw. 
\param g The green value of the line to draw. 
\param b The blue value of the line to draw. 
\param a The alpha value of the line to draw. 

\returns Returns 0 on success, -1 on failure.
*/
int hlineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 x2, Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
{
	int result = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result |= SDL_RenderDrawLine(renderer, x1, y, x2, y);
	return result;
}

/*!
\brief Draw vertical line with blending.

\param renderer The renderer to draw on.
\param x X coordinate of the points of the line.
\param y1 Y coordinate of the first point (i.e. top) of the line.
\param y2 Y coordinate of the second point (i.e. bottom) of the line.
\param r The red value of the line to draw. 
\param g The green value of the line to draw. 
\param b The blue value of the line to draw. 
\param a The alpha value of the line to draw. 

\returns Returns 0 on success, -1 on failure.
*/
int vlineRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y1, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
{
	int result = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result |= SDL_RenderDrawLine(renderer, x, y1, x, y2);
	return result;
}

/*!
\brief Draw pixel with blending enabled if a<255.

\param renderer The renderer to draw on.
\param x X (horizontal) coordinate of the pixel.
\param y Y (vertical) coordinate of the pixel.
\param r The red color value of the pixel to draw. 
\param g The green color value of the pixel to draw.
\param b The blue color value of the pixel to draw.
\param a The alpha value of the pixel to draw.

\returns Returns 0 on success, -1 on failure.
*/
int pixelRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
{
	int result = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result |= SDL_RenderDrawPoint(renderer, x, y);
	return result;
}

/*!
\brief Draw box (filled rectangle) with blending.

\param renderer The renderer to draw on.
\param x1 X coordinate of the first point (i.e. top right) of the box.
\param y1 Y coordinate of the first point (i.e. top right) of the box.
\param x2 X coordinate of the second point (i.e. bottom left) of the box.
\param y2 Y coordinate of the second point (i.e. bottom left) of the box.
\param r The red value of the box to draw. 
\param g The green value of the box to draw. 
\param b The blue value of the box to draw. 
\param a The alpha value of the box to draw.

\returns Returns 0 on success, -1 on failure.
*/
int boxRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
{
	int result;
	Sint16 tmp;
	SDL_Rect rect;

	/*
	* Test for special cases of straight lines or single point 
	*/
	if (x1 == x2) {
		if (y1 == y2) {
			return (pixelRGBA(renderer, x1, y1, r, g, b, a));
		} else {
			return (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		}
	} else {
		if (y1 == y2) {
			return (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		}
	}

	/*
	* Swap x1, x2 if required 
	*/
	if (x1 > x2) {
		tmp = x1;
		x1 = x2;
		x2 = tmp;
	}

	/*
	* Swap y1, y2 if required 
	*/
	if (y1 > y2) {
		tmp = y1;
		y1 = y2;
		y2 = tmp;
	}

	/* 
	* Create destination rect
	*/	
	rect.x = x1;
	rect.y = y1;
	rect.w = x2 - x1 + 1;
	rect.h = y2 - y1 + 1;
	
	/*
	* Draw
	*/
	result = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);	
	result |= SDL_RenderFillRect(renderer, &rect);
	return result;
}


/* ---- Pixel */

/*!
\brief Draw pixel  in currently set color.

\param renderer The renderer to draw on.
\param x X (horizontal) coordinate of the pixel.
\param y Y (vertical) coordinate of the pixel.

\returns Returns 0 on success, -1 on failure.
*/
int pixel(SDL_Renderer *renderer, Sint16 x, Sint16 y)
{
	return SDL_RenderDrawPoint(renderer, x, y);
}

/* ---- Thick Line */

/*!
\brief Internal function to initialize the Bresenham line iterator.

Example of use:
SDL2_gfxBresenhamIterator b;
_bresenhamInitialize (&b, x1, y1, x2, y2);
do { 
plot(b.x, b.y); 
} while (_bresenhamIterate(&b)==0); 

\param b Pointer to struct for bresenham line drawing state.
\param x1 X coordinate of the first point of the line.
\param y1 Y coordinate of the first point of the line.
\param x2 X coordinate of the second point of the line.
\param y2 Y coordinate of the second point of the line.

\returns Returns 0 on success, -1 on failure.
*/
int _bresenhamInitialize(SDL2_gfxBresenhamIterator *b, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2)
{
	int temp;

	if (b == null) {
		return(-1);
	}

	b.x = x1;
	b.y = y1;

	/* dx = abs(x2-x1), s1 = sign(x2-x1) */
	if ((b.dx = x2 - x1) != 0) {
		if (b.dx < 0) {
			b.dx = -b.dx;
			b.s1 = -1;
		} else {
			b.s1 = 1;
		}
	} else {
		b.s1 = 0;	
	}

	/* dy = abs(y2-y1), s2 = sign(y2-y1)    */
	if ((b.dy = y2 - y1) != 0) {
		if (b.dy < 0) {
			b.dy = -b.dy;
			b.s2 = -1;
		} else {
			b.s2 = 1;
		}
	} else {
		b.s2 = 0;	
	}

	if (b.dy > b.dx) {
		temp = b.dx;
		b.dx = b.dy;
		b.dy = temp;
		b.swapdir = 1;
	} else {
		b.swapdir = 0;
	}

	b.count = (b.dx<0) ? 0 : cast (uint) b.dx;
	b.dy <<= 1;
	b.error = b.dy - b.dx;
	b.dx <<= 1;	

	return(0);
}


/*!
\brief Internal function to move Bresenham line iterator to the next position.

Maybe updates the x and y coordinates of the iterator struct.

\param b Pointer to struct for bresenham line drawing state.

\returns Returns 0 on success, 1 if last point was reached, 2 if moving past end-of-line, -1 on failure.
*/
int _bresenhamIterate(SDL2_gfxBresenhamIterator *b)
{	
	if (b==null) {
		return (-1);
	}

	/* last point check */
	if (b.count==0) {
		return (2);
	}

	while (b.error >= 0) {
		if (b.swapdir) {
			b.x += b.s1;
		} else  {
			b.y += b.s2;
		}

		b.error -= b.dx;
	}

	if (b.swapdir) {
		b.y += b.s2;
	} else {
		b.x += b.s1;
	}

	b.error += b.dy;	
	b.count--;		

	/* count==0 indicates "end-of-line" */
	return ((b.count) ? 0 : 1);
}


/*!
\brief Internal function to to draw parallel lines with Murphy algorithm.

\param m Pointer to struct for murphy iterator.
\param x X coordinate of point.
\param y Y coordinate of point.
\param d1 Direction square/diagonal.
*/
void _murphyParaline(SDL2_gfxMurphyIterator *m, Sint16 x, Sint16 y, int d1)
{
	int p;
	d1 = -d1;

	for (p = 0; p <= m.u; p++) {

		pixel(m.renderer, x, y);

		if (d1 <= m.kt) {
			if (m.oct2 == 0) {
				x++;
			} else {
				if (m.quad4 == 0) {
					y++;
				} else {
					y--;
				}
			}
			d1 += m.kv;
		} else {	
			x++;
			if (m.quad4 == 0) {
				y++;
			} else {
				y--;
			}
			d1 += m.kd;
		}
	}

	m.tempx = x;
	m.tempy = y;
}

/*!
\brief Internal function to to draw one iteration of the Murphy algorithm.

\param m Pointer to struct for murphy iterator.
\param miter Iteration count.
\param ml1bx X coordinate of a point.
\param ml1by Y coordinate of a point.
\param ml2bx X coordinate of a point.
\param ml2by Y coordinate of a point.
\param ml1x X coordinate of a point.
\param ml1y Y coordinate of a point.
\param ml2x X coordinate of a point.
\param ml2y Y coordinate of a point.

*/
void _murphyIteration(SDL2_gfxMurphyIterator *m, Uint8 miter, 
	Uint16 ml1bx, Uint16 ml1by, Uint16 ml2bx, Uint16 ml2by, 
	Uint16 ml1x, Uint16 ml1y, Uint16 ml2x, Uint16 ml2y)
{
	int atemp1, atemp2;
	int ftmp1, ftmp2;
	Uint16 m1x, m1y, m2x, m2y;	
	Uint16 fix, fiy, lax, lay, curx, cury;
	Sint16[4] px, py;
	SDL2_gfxBresenhamIterator b;

	if (miter > 1) {
		if (m.first1x != -32_768) {
			fix = cast(ushort) (m.first1x + m.first2x) / 2;
			fiy = cast(ushort) (m.first1y + m.first2y) / 2;
			lax = cast(ushort) (m.last1x + m.last2x) / 2;
			lay = cast(ushort) (m.last1y + m.last2y) / 2;
			curx = (ml1x + ml2x) / 2;
			cury = (ml1y + ml2y) / 2;

			atemp1 = (fix - curx);
			atemp2 = (fiy - cury);
			ftmp1 = atemp1 * atemp1 + atemp2 * atemp2;
			atemp1 = (lax - curx);
			atemp2 = (lay - cury);
			ftmp2 = atemp1 * atemp1 + atemp2 * atemp2;

			if (ftmp1 <= ftmp2) {
				m1x = m.first1x;
				m1y = m.first1y;
				m2x = m.first2x;
				m2y = m.first2y;
			} else {
				m1x = m.last1x;
				m1y = m.last1y;
				m2x = m.last2x;
				m2y = m.last2y;
			}

			atemp1 = (m2x - ml2x);
			atemp2 = (m2y - ml2y);
			ftmp1 = atemp1 * atemp1 + atemp2 * atemp2;
			atemp1 = (m2x - ml2bx);
			atemp2 = (m2y - ml2by);
			ftmp2 = atemp1 * atemp1 + atemp2 * atemp2;

			if (ftmp2 >= ftmp1) {
				ftmp1 = ml2bx;
				ftmp2 = ml2by;
				ml2bx = ml2x;
				ml2by = ml2y;
				ml2x = cast(ushort) ftmp1;
				ml2y = cast(ushort) ftmp2;
				ftmp1 = ml1bx;
				ftmp2 = ml1by;
				ml1bx = ml1x;
				ml1by = ml1y;
				ml1x = cast(ushort) ftmp1;
				ml1y = cast(ushort) ftmp2;
			}

			/*
			* Lock the surface 
			*/
			_bresenhamInitialize(&b, m2x, m2y, m1x, m1y);
			do {
				pixel(m.renderer, b.x, b.y);
			} while (_bresenhamIterate(&b)==0);

			_bresenhamInitialize(&b, m1x, m1y, ml1bx, ml1by);
			do {
				pixel(m.renderer, b.x, b.y);
			} while (_bresenhamIterate(&b)==0);

			_bresenhamInitialize(&b, ml1bx, ml1by, ml2bx, ml2by);
			do {
				pixel(m.renderer, b.x, b.y);
			} while (_bresenhamIterate(&b)==0);

			_bresenhamInitialize(&b, ml2bx, ml2by, m2x, m2y);
			do {
				pixel(m.renderer, b.x, b.y);
			} while (_bresenhamIterate(&b)==0);

			px[0] = m1x;
			px[1] = m2x;
			px[2] = ml1bx;
			px[3] = ml2bx;
			py[0] = m1y;
			py[1] = m2y;
			py[2] = ml1by;
			py[3] = ml2by;			
			polygon(m.renderer, px.ptr, py.ptr, 4);						
		}
	}

	m.last1x = ml1x;
	m.last1y = ml1y;
	m.last2x = ml2x;
	m.last2y = ml2y;
	m.first1x = ml1bx;
	m.first1y = ml1by;
	m.first2x = ml2bx;
	m.first2y = ml2by;
}

/*
#define HYPOT(x,y) sqrt((double)(x)*(double)(x)+(double)(y)*(double)(y)) 
*/
pragma(inline)
auto HYPOT(real x, real y)
{
	return sqrt(cast(double)(x) * cast(double)(x) + cast(double)(y)* cast(double)(y));
}

/*!
\brief Internal function to to draw wide lines with Murphy algorithm.

Draws lines parallel to ideal line.

\param m Pointer to struct for murphy iterator.
\param x1 X coordinate of first point.
\param y1 Y coordinate of first point.
\param x2 X coordinate of second point.
\param y2 Y coordinate of second point.
\param width Width of line.
\param miter Iteration count.

*/
void _murphyWideline(SDL2_gfxMurphyIterator *m, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint8 width, Uint8 miter)
{	
	float offset = cast(float) width / 2.0f;

	Sint16 temp;
	Sint16 ptx, pty, ptxx, ptxy, ml1x, ml1y, ml2x, ml2y, ml1bx, ml1by, ml2bx, ml2by;

	int d0, d1;		/* difference terms d0=perpendicular to line, d1=along line */

	int q;			/* pel counter,q=perpendicular to line */
	int tmp;

	int dd;			/* distance along line */
	int tk;			/* thickness threshold */
	double ang;		/* angle for initial point calculation */
	double sang, cang;

	/* Initialisation */
	m.u = x2 - x1;	/* delta x */
	m.v = y2 - y1;	/* delta y */

	if (m.u < 0) {	/* swap to make sure we are in quadrants 1 or 4 */
		temp = x1;
		x1 = x2;
		x2 = temp;
		temp = y1;
		y1 = y2;
		y2 = temp;		
		m.u *= -1;
		m.v *= -1;
	}

	if (m.v < 0) {	/* swap to 1st quadrant and flag */
		m.v *= -1;
		m.quad4 = 1;
	} else {
		m.quad4 = 0;
	}

	if (m.v > m.u) {	/* swap things if in 2 octant */
		tmp = m.u;
		m.u = m.v;
		m.v = tmp;
		m.oct2 = 1;
	} else {
		m.oct2 = 0;
	}

	m.ku = m.u + m.u;	/* change in l for square shift */
	m.kv = m.v + m.v;	/* change in d for square shift */
	m.kd = m.kv - m.ku;	/* change in d for diagonal shift */
	m.kt = m.u - m.kv;	/* diag/square decision threshold */

	d0 = 0;
	d1 = 0;
	dd = 0;

	ang = atan(cast(double) m.v / cast(double) m.u);	/* calc new initial point - offset both sides of ideal */	
	sang = sin(ang);
	cang = cos(ang);

	if (m.oct2 == 0) {
		ptx = cast(Sint16) (x1 + lrint(offset * sang));
		if (m.quad4 == 0) {
			pty = cast(Sint16) (y1 -  lrint(offset * cang));
		} else {
			pty = cast(Sint16) (y1 + lrint(offset * cang));
		}
	} else {
		ptx = cast(Sint16) (x1 - lrint(offset * cang));
		if (m.quad4 == 0) {
			pty = cast(Sint16) (y1 + lrint(offset * sang));
		} else {
			pty = cast(Sint16) (y1 - lrint(offset * sang));
		}
	}

	/* used here for constant thickness line */
	tk = cast(int) (4.0 * HYPOT(ptx - x1, pty - y1) * HYPOT(m.u, m.v));

	if (miter == 0) {
		m.first1x = -32_768;
		m.first1y = -32_768;
		m.first2x = -32_768;
		m.first2y = -32_768;
		m.last1x = -32_768;
		m.last1y = -32_768;
		m.last2x = -32_768;
		m.last2y = -32_768;
	}
	ptxx = ptx;
	ptxy = pty;

	for (q = 0; dd <= tk; q++) {	/* outer loop, stepping perpendicular to line */

		_murphyParaline(m, ptx, pty, d1);	/* call to inner loop - right edge */
		if (q == 0) {
			ml1x = ptx;
			ml1y = pty;
			ml1bx = m.tempx;
			ml1by = m.tempy;
		} else {
			ml2x = ptx;
			ml2y = pty;
			ml2bx = m.tempx;
			ml2by = m.tempy;
		}
		if (d0 < m.kt) {	/* square move */
			if (m.oct2 == 0) {
				if (m.quad4 == 0) {
					pty++;
				} else {
					pty--;
				}
			} else {
				ptx++;
			}
		} else {	/* diagonal move */
			dd += m.kv;
			d0 -= m.ku;
			if (d1 < m.kt) {	/* normal diagonal */
				if (m.oct2 == 0) {
					ptx--;
					if (m.quad4 == 0) {
						pty++;
					} else {
						pty--;
					}
				} else {
					ptx++;
					if (m.quad4 == 0) {
						pty--;
					} else {
						pty++;
					}
				}
				d1 += m.kv;
			} else {	/* double square move, extra parallel line */
				if (m.oct2 == 0) {
					ptx--;
				} else {
					if (m.quad4 == 0) {
						pty--;
					} else {
						pty++;
					}
				}
				d1 += m.kd;
				if (dd > tk) {
					_murphyIteration(m, miter, ml1bx, ml1by, ml2bx, ml2by, ml1x, ml1y, ml2x, ml2y);
					return;	/* breakout on the extra line */
				}
				_murphyParaline(m, ptx, pty, d1);
				if (m.oct2 == 0) {
					if (m.quad4 == 0) {
						pty++;
					} else {

						pty--;
					}
				} else {
					ptx++;
				}
			}
		}
		dd += m.ku;
		d0 += m.kv;
	}

	_murphyIteration(m, miter, ml1bx, ml1by, ml2bx, ml2by, ml1x, ml1y, ml2x, ml2y);
}


/*!
\brief Draw a thick line with alpha blending.

\param renderer The renderer to draw on.
\param x1 X coordinate of the first point of the line.
\param y1 Y coordinate of the first point of the line.
\param x2 X coordinate of the second point of the line.
\param y2 Y coordinate of the second point of the line.
\param width Width of the line in pixels. Must be >0.
\param color The color value of the line to draw (0xRRGGBBAA). 

\returns Returns 0 on success, -1 on failure.
*/
int thickLineColor(SDL_Renderer *renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint8 width, Uint32 color)
{	
	Uint8 *c = cast(Uint8 *)&color; 
	return thickLineRGBA(renderer, x1, y1, x2, y2, width, c[0], c[1], c[2], c[3]);
}

/*!
\brief Draw a thick line with alpha blending.

\param renderer The renderer to draw on.
\param x1 X coordinate of the first point of the line.
\param y1 Y coordinate of the first point of the line.
\param x2 X coordinate of the second point of the line.
\param y2 Y coordinate of the second point of the line.
\param width Width of the line in pixels. Must be >0.
\param r The red value of the character to draw. 
\param g The green value of the character to draw. 
\param b The blue value of the character to draw. 
\param a The alpha value of the character to draw.

\returns Returns 0 on success, -1 on failure.
*/	
int thickLineRGBA(SDL_Renderer *renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint8 width, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
{
	int result;
	int wh;
	SDL2_gfxMurphyIterator m;

	if (renderer == null) {
		return -1;
	}
	if (width < 1) {
		return -1;
	}

	/* Special case: thick "point" */
	if ((x1 == x2) && (y1 == y2)) {
		wh = width / 2;
		return boxRGBA(renderer, cast(Sint16) (x1 - wh), cast(Sint16) (y1 - wh), cast(Sint16) (x2 + width), 
		cast(Sint16) (y2 + width), r, g, b, a);		
	}

	/*
	* Set color
	*/
	result = 0;
	result |= SDL_SetRenderDrawBlendMode(renderer, (a == 255) ? SDL_BLENDMODE_NONE : SDL_BLENDMODE_BLEND);
	result |= SDL_SetRenderDrawColor(renderer, r, g, b, a);

	/* 
	* Draw
	*/
	m.renderer = renderer;
	_murphyWideline(&m, x1, y1, x2, y2, width, 0);
	_murphyWideline(&m, x1, y1, x2, y2, width, 1);

	return(0);
}
