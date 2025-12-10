package main

import "./glim/glid"
import "./glim"

import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:math"
import "core:log"

WIN_W :: 800
WIN_H :: 450

FRAG_LIGHT ::
`
#version 460

layout(location = 0) in vec4 v_texcoord;
layout(location = 1) in vec4 v_normal;
layout(location = 3) in vec4 v_color;

layout(binding = 0) uniform sampler2D u_texture;

layout(location = 0) out vec4 f_color;

void main() {
    const vec3 L = normalize(vec3(1.0));
    vec3 N = normalize(v_normal.xyz);

    float diffuse = max(dot(N, L), 0.0);
    float ambient = 0.1;

    vec4 texColor = texture(u_texture, v_texcoord.xy);
    f_color = texColor * v_color * (ambient + diffuse);
    f_color.rgb = pow(f_color.rgb, vec3(1.0 / 2.2));
}
`

main :: proc() {
    if glfw.Init() != glfw.TRUE {
        log.panic("Failed to init GLFW")
    }
    defer glfw.Terminate()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    glfw.WindowHint(glfw.SAMPLES, 4)
    window := glfw.CreateWindow(WIN_W, WIN_H, "Batch for OpenGL", nil, nil)
    if window == nil {
        log.panic("Failed to create window")
    }

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)

    gl.load_up_to(4, 6, glfw.gl_set_proc_address)
    gl.Enable(gl.DEPTH_TEST)

    glim.init()
    defer glim.quit()

    glim.set_projection(glm.mat4Perspective(glm.radians(f32(60)), f32(WIN_W) / f32(WIN_H), 0.01, 100.0))
    prog_light, ok := gl.load_shaders_source(string(glim.VERT_SHADER), FRAG_LIGHT); assert(ok)
    rotation: f32 = 0.0

    for !glfw.WindowShouldClose(window) {
        gl.ClearColor(0.1, 0.1, 0.1, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        glid.begin_3d(60.0, f32(WIN_W) / f32(WIN_H), 0.01, 100.0)
        glim.load_modelview(glm.mat4LookAt({5.0 * math.cos(rotation), 5.0, 5.0 * math.sin(rotation)}, {0,1,0}, {0,1,0}))
        glim.attribute(.Color, {1.0, 1.0, 1.0, 1.0})
        glim.set_line_width(1.0)
        glid.grid(0, 0, 0, 10, 10, 10, 10)
        glim.set_program(prog_light)
        glid.sphere(0, 1, 0, 1.0)
        glim.set_program(0)
        glid.end_3d()

        glid.begin_2d(WIN_W, WIN_H)
        glim.set_line_width(2.0)
        glim.attribute(.Color, {1.0, 0.0, 0.0, 1.0})
        glid.rectangle(0, 0, WIN_W, WIN_H, false)
        glid.end_2d()

        rotation += 0.016 * math.PI / 4

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }
}
