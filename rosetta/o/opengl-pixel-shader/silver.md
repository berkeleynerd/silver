# OpenGL pixel shader

**Excluded from Silver: GUI, graphics.** The task requires an OpenGL pixel shader that colors each pixel of a triangle in a window. That needs the gui and graphics effects, which Silver lacks today. It does not break any fixed Oracle rule, so it is a candidate for future inclusion once admitted library operations for graphics exist.

## External effects

- **GUI** (not allowed): The task is to render a triangle in an OpenGL window using a pixel shader, so it needs a window and an OpenGL rendering context. Text art or an image file does not meet it.
- **graphics** (not allowed): The required work is GPU rendering: a shader runs once per pixel of a triangle on a display.

Assessed on 2026-10-15 against page revision 393305 of the [task](https://rosettacode.org/wiki/OpenGL_pixel_shader) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
