# GLIM - OpenGL Immediate Mode for Odin

Immediate mode rendering for OpenGL 4.6 in Odin, just for fun!

## What it does

- Batches draw calls when state matches
- 64-byte vertices: `[4]f32` position + 6 `[4]f16` attributes
- Supports custom shaders with custom attributes
- Lines, triangles, quads, all as indexed triangles
- Up to 8 textures
- Thick lines that work (CPU quads, not `glLineWidth`)
- Transform stack
- Buffers grow as needed (remember to call `flush()`)
- Optional `glid` package with 2D/3D shapes

## Quick Start

```odin
package main

import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:log"
import "./glim"

main :: proc() {
    if glfw.Init() != glfw.TRUE {
        log.panic("Failed to init GLFW")
    }
    defer glfw.Terminate()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window := glfw.CreateWindow(800, 450, "GLIM Example", nil, nil)
    if window == nil {
        log.panic("Failed to create window")
    }

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)

    gl.load_up_to(4, 6, glfw.gl_set_proc_address)

    glim.init()
    defer glim.quit()

    for !glfw.WindowShouldClose(window) {
        gl.ClearColor(0.1, 0.1, 0.1, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        glim.begin(.Triangles)
        glim.attribute(.Color, {1.0, 0.0, 0.0, 1.0}); glim.vertex({0.0, 0.5, 0.0, 1.0})
        glim.attribute(.Color, {0.0, 1.0, 0.0, 1.0}); glim.vertex({-0.5, -0.5, 0.0, 1.0})
        glim.attribute(.Color, {0.0, 0.0, 1.0, 1.0}); glim.vertex({0.5, -0.5, 0.0, 1.0})
        glim.end()

        glim.flush()

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }
}
```

## API

```odin
// Setup
glim.init()
glim.quit()

// State
glim.set_projection(matrix[4,4]f32)
glim.set_line_width(f32)
glim.set_textures([]u32)       // Max 8, use 0 for default white texture
glim.set_blend_mode(Blend)     // .Disabled, .Alpha, .Premul, .Add, .Sub, .Mul, .Min, .Max
glim.set_program(u32)

// Transforms
glim.push()
glim.pop()
glim.load_modelview(matrix[4,4]f32)
glim.mult_modelview(matrix[4,4]f32)
glim.translate(x, y, z: f32)
glim.rotate(angle_rad, x, y, z: f32)
glim.scale(x, y, z: f32)

// Drawing
glim.begin(.Lines)             // Or .Triangles, .Quads
glim.attribute(.Color, {1, 0, 0, 1})
glim.vertex({x, y, z, 1})
glim.end()
glim.flush()                   // Actually draws
```

Attributes: `.Location1` to `.Location6` (location 0 is positions from vertex())
Aliases: `.TexCoord`, `.Normal`, `.Tangent`, .Color for locations 1-4.
Default shader uses .TexCoord and .Color.

## Helper shapes (glid)

```odin
// 2D
glid.begin_2d(width, height, .Bottom_Left)  // Or .Top_Left, .Center
glid.rectangle(x, y, w, h, filled = true)
glid.circle(x, y, radius)
glid.line(x0, y0, x1, y1)
// ... and more: triangle, ellipse, rounded_rectangle, polygon, arc, bezier, etc...
glid.end_2d()

// 3D
glid.begin_3d(fov, aspect, near, far)
glid.cube(x, y, z, size)
glid.sphere(x, y, z, radius)
glid.cylinder(x, y, z, radius, height)
// ... and more: box, cone, plane, grid, axes, etc...
glid.end_3d()
```

## Notes

- `end()` tries to merge with the previous draw call if state matches
- Nothing draws until you call `flush()`
- Vertices are transformed by modelview on CPU when you call `vertex()`
- Default shader does `color * texture[0]`, projection at uniform location 0
- Use `0` in texture slots for the default white texture
