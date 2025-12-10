package glim

import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "base:runtime"

// ====================
// CONSTANTS
// ====================

VERT_SHADER :: #load("./shaders/glim.vert")
FRAG_SHADER :: #load("./shaders/glim.frag")

MAX_TEXTURES :: 8

// ====================
// PUBLIC TYPES
// ====================

Attribute :: enum {
    Location1 = 0,  TexCoord = 0,
    Location2 = 1,  Normal   = 1,
    Location3 = 2,  Tangent  = 2,
    Location4 = 3,  Color    = 3,
    Location5 = 4,
    Location6 = 5,
}

Blend :: enum {
    Disabled,
    Alpha,
    Premul,
    Add,
    Sub,
    Mul,
    Min,
    Max,
}

Mode :: enum {
    Lines,
    Triangles,
    Quads,
}

// ====================
// GLOBALS
// ====================

@(private="file")
Core :: struct {
    // Staging buffers
    vertices: [dynamic]Vertex,
    indices: [dynamic]Index,

    // Draw calls
    calls: [dynamic]Draw_Call,

    // Current state
    current_inv_projection: matrix[4, 4]f32,
    current_projection: matrix[4, 4]f32,
    current_line_width: f32,
    current_vertex: Vertex,
    current_state: State,
    current_mode: Mode,

    // Model-view stack
    modelview_stack: [dynamic]matrix[4, 4]f32,
    current_modelview: matrix[4, 4]f32,

    // Batch state
    batch_start_vertex: u32,
    batch_start_index: u32,

    // GPU resources
    vao, vbo, ebo: u32,
    vbo_size: int,
    ebo_size: int,

    // Defaults
    default_texture: u32,
    default_program: u32,
}

core: Core

// ====================
// FILE TYPES
// ====================

@(private="file")
State :: struct {
    textures: [MAX_TEXTURES]u32,
    texture_count: int,
    blend_mode: Blend,
    program: u32,
}

@(private="file")
Draw_Call :: struct {
    index_offset: u32,
    index_count: u32,
    state: State,
}

@(private="file")
Vertex :: struct {
    position: [4]f32,
    attribute: [6][4]f16,
}

@(private="file")
Index :: u32

// ====================
// PUBLIC API
// ====================

init :: proc() {
    core.current_inv_projection = 1.0
    core.current_projection = 1.0
    core.current_modelview = 1.0
    core.current_line_width = 1.0
    core.current_vertex = {
        position = {},
        attribute = {
            { 0.0, 0.0, 0.0, 1.0 },
            { 0.0, 0.0, 1.0, 1.0 },
            { 1.0, 0.0, 0.0, 1.0 },
            { 1.0, 1.0, 1.0, 1.0 },
            { 0.0, 0.0, 0.0, 1.0 },
            { 0.0, 0.0, 0.0, 1.0 }
        }
    }

    pix_white: []u8 = { 255, 255, 255, 255 }
    gl.CreateTextures(gl.TEXTURE_2D, 1, &core.default_texture)
    gl.TextureStorage2D(core.default_texture, 1, gl.RGBA8, 1, 1)
    gl.TextureSubImage2D(core.default_texture, 0, 0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, raw_data(pix_white))
    core.current_state.textures[0] = core.default_texture
    core.current_state.texture_count = 1

    program, ok := gl.load_shaders_source(string(VERT_SHADER), string(FRAG_SHADER)); assert(ok)
    core.current_state.program = program
    core.default_program = program

    gl.CreateVertexArrays(1, &core.vao)
    gl.CreateBuffers(1, &core.vbo)
    gl.CreateBuffers(1, &core.ebo)

    gl.VertexArrayElementBuffer(core.vao, core.ebo)
    gl.VertexArrayVertexBuffer(core.vao, 0, core.vbo, 0, i32(size_of(Vertex)))

    gl.EnableVertexArrayAttrib(core.vao, 0)
    gl.VertexArrayAttribFormat(core.vao, 0, 4, gl.FLOAT, gl.FALSE, 0)
    gl.VertexArrayAttribBinding(core.vao, 0, 0)

    for i in 0..<6 {
        loc := u32(i + 1)
        offset := u32(size_of([4]f32) + i * size_of([4]f16))
        gl.EnableVertexArrayAttrib(core.vao, loc)
        gl.VertexArrayAttribFormat(core.vao, loc, 4, gl.HALF_FLOAT, gl.FALSE, offset)
        gl.VertexArrayAttribBinding(core.vao, loc, 0)
    }
}

quit :: proc() {
    delete(core.modelview_stack)
    delete(core.vertices)
    delete(core.indices)
    delete(core.calls)

    gl.DeleteTextures(1, &core.default_texture)
    gl.DeleteProgram(core.default_program)

    gl.DeleteVertexArrays(1, &core.vao)
    gl.DeleteBuffers(1, &core.vbo)
    gl.DeleteBuffers(1, &core.ebo)
}

set_projection :: proc(projection: matrix[4, 4]f32) {
    core.current_inv_projection = glm.inverse(projection)
    core.current_projection = projection
}

set_line_width :: proc(line_width: f32) {
    core.current_line_width = line_width
}

set_textures :: proc(textures: []u32) {
    count := min(len(textures), MAX_TEXTURES)
    for i in 0..<count do core.current_state.textures[i] = textures[i]
    for i in count..<MAX_TEXTURES do core.current_state.textures[i] = 0
    core.current_state.texture_count = count
}

set_blend_mode :: proc(blend_mode: Blend) {
    core.current_state.blend_mode = blend_mode
}

set_program :: proc(program: u32) {
    if program == 0 {
        core.current_state.program = core.default_program
    } else {
        core.current_state.program = program
    }
}

push :: proc() {
    append(&core.modelview_stack, core.current_modelview)
}

pop :: proc() {
    if len(core.modelview_stack) > 0 {
        core.current_modelview = runtime.pop(&core.modelview_stack)
    }
}

load_modelview :: proc(mat: matrix[4, 4]f32) {
    core.current_modelview = mat
}

mult_modelview :: proc(mat: matrix[4, 4]f32) {
    core.current_modelview = mat * core.current_modelview
}

translate :: proc(x, y, z: f32) {
    core.current_modelview = glm.mat4Translate({x, y, z}) * core.current_modelview
}

rotate :: proc(angle_rad: f32, x, y, z: f32) {
    core.current_modelview = glm.mat4Rotate({x, y, z}, angle_rad) * core.current_modelview
}

scale :: proc(x, y, z: f32) {
    core.current_modelview = glm.mat4Scale({x, y, z}) * core.current_modelview
}

begin :: proc(mode: Mode) {
    core.current_mode = mode
    core.batch_start_vertex = u32(len(core.vertices))
    core.batch_start_index = u32(len(core.indices))
}

attribute :: proc(loc: Attribute, value: [4]f32) {
    for i in 0..<4 {
        core.current_vertex.attribute[int(loc)][i] = f16(value[i])
    }
}

vertex :: proc(position: [4]f32) {
    core.current_vertex.position = core.current_modelview * position
    append(&core.vertices, core.current_vertex)
}

end :: proc() {
    vertex_count := u32(len(core.vertices)) - core.batch_start_vertex
    if vertex_count == 0 do return

    switch core.current_mode {
    case .Lines: generate_line_indices(vertex_count)
    case .Triangles: generate_triangle_indices(vertex_count)
    case .Quads: generate_quad_indices(vertex_count)
    }

    index_count := u32(len(core.indices)) - core.batch_start_index
    if index_count > 0 {
        // We check if we can append this pass to the previous draw call
        if len(core.calls) > 0 {
            last_call := &core.calls[len(core.calls) - 1]
            if last_call.state == core.current_state {
                last_call.index_count += index_count
                return
            }
        }
        // Otherwise, we push a new draw call
        call := Draw_Call{
            index_offset = core.batch_start_index,
            index_count = index_count,
            state = core.current_state
        }
        append(&core.calls, call)
    }
}

flush :: proc() {
    if len(core.calls) == 0 do return

    vertex_size := len(core.vertices) * size_of(Vertex)
    reserve_buffer(core.vbo, &core.vbo_size, vertex_size)
    gl.NamedBufferSubData(core.vbo, 0, vertex_size, raw_data(core.vertices))

    index_size := len(core.indices) * size_of(Index)
    reserve_buffer(core.ebo, &core.ebo_size, index_size)
    gl.NamedBufferSubData(core.ebo, 0, index_size, raw_data(core.indices))

    gl.BindVertexArray(core.vao)

    for call in core.calls {
        gl.UseProgram(call.state.program)
        for i in 0..<call.state.texture_count {
            gl.BindTextureUnit(u32(i), call.state.textures[i])
        }
        apply_blend_mode(call.state.blend_mode)
        gl.UniformMatrix4fv(0, 1, false, &core.current_projection[0, 0])

        offset := uintptr(call.index_offset * size_of(Index))
        gl.DrawElements(gl.TRIANGLES, i32(call.index_count), gl.UNSIGNED_INT, rawptr(offset))
    }

    gl.BindVertexArray(0)

    clear(&core.vertices)
    clear(&core.indices)
    clear(&core.calls)
}

// ====================
// PRIVATE HELPERS
// ====================

@(private="file")
generate_line_indices :: proc(vertex_count: u32) {
    // NOTE: Simplicity was chosen here. Line vertices are used to generate quads, so quad vertices
    //       are appended to the batch while the original line vertices are kept but not indexed.
    //       They will be uploaded but ignored during rendering. This may be revisited later.

    base := core.batch_start_vertex
    line_count := vertex_count / 2

    P := core.current_projection
    invP := core.current_inv_projection

    viewport: [4]i32
    gl.GetIntegerv(gl.VIEWPORT, &viewport[0])
    sw := f32(viewport[2])
    sh := f32(viewport[3])

    for i in 0..<line_count {
        v0_idx := base + i * 2
        v1_idx := base + i * 2 + 1

        v0 := core.vertices[v0_idx]
        v1 := core.vertices[v1_idx]

        c0 := P * v0.position
        c1 := P * v1.position

        // Normalize to NDC
        ndc0 := c0.xy / c0.w
        ndc1 := c1.xy / c1.w

        // Direction in NDC
        dir  := glm.normalize(ndc1 - ndc0)
        perp := [2]f32{-dir.y, dir.x}

        // Convert pixels to NDC
        half_px := core.current_line_width * 0.5
        px_ndc := [2]f32{
            (half_px / sw) * 2.0,
            (half_px / sh) * 2.0
        }

        offset_ndc := perp * px_ndc

        // Create the offset in clip space (multiply by w)
        offset_clip0 := [4]f32{offset_ndc.x * c0.w, offset_ndc.y * c0.w, 0, 0}
        offset_clip1 := [4]f32{offset_ndc.x * c1.w, offset_ndc.y * c1.w, 0, 0}

        // Apply the offset directly in clip space
        v0_lo := invP * (c0 - offset_clip0)
        v0_hi := invP * (c0 + offset_clip0)
        v1_lo := invP * (c1 - offset_clip1)
        v1_hi := invP * (c1 + offset_clip1)

        v_base := u32(len(core.vertices))

        vert := v0; vert.position = v0_lo; append(&core.vertices, vert)
        vert  = v1; vert.position = v1_lo; append(&core.vertices, vert)
        vert  = v1; vert.position = v1_hi; append(&core.vertices, vert)
        vert  = v0; vert.position = v0_hi; append(&core.vertices, vert)

        append(&core.indices,
            v_base + 0, v_base + 1, v_base + 2,
            v_base + 0, v_base + 2, v_base + 3
        )
    }
}

@(private="file")
generate_triangle_indices :: proc(vertex_count: u32) {
    base := core.batch_start_vertex
    triangle_count := vertex_count / 3
    for i in 0..<triangle_count {
        idx := base + i * 3
        append(&core.indices, idx + 0, idx + 1, idx + 2)
    }
}

@(private="file")
generate_quad_indices :: proc(vertex_count: u32) {
    base := core.batch_start_vertex
    quad_count := vertex_count / 4
    for i in 0..<quad_count {
        idx := base + i * 4
        append(&core.indices, idx + 0, idx + 1, idx + 2) // Triangle 1: 0-1-2
        append(&core.indices, idx + 0, idx + 2, idx + 3) // Triangle 2: 0-2-3
    }
}

@(private="file")
reserve_buffer :: proc(buffer: u32, size: ^int, required: int) {
    if size^ < required {
        // The buffers are allocated with 50% more space
        new_size := required * 3 / 2
        gl.NamedBufferData(buffer, new_size, nil, gl.STREAM_DRAW)
        size^ = new_size
    }
}

@(private="file")
apply_blend_mode :: proc(mode: Blend) {
    switch mode {
    case .Disabled:
        gl.Disable(gl.BLEND)

    case .Alpha:
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
        gl.BlendEquation(gl.FUNC_ADD)

    case .Premul:
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA)
        gl.BlendEquation(gl.FUNC_ADD)

    case .Add:
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE)
        gl.BlendEquation(gl.FUNC_ADD)

    case .Sub:
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE)
        gl.BlendEquation(gl.FUNC_REVERSE_SUBTRACT)

    case .Mul:
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.DST_COLOR, gl.ZERO)
        gl.BlendEquation(gl.FUNC_ADD)

    case .Min:
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.ONE, gl.ONE)
        gl.BlendEquation(gl.MIN)

    case .Max:
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.ONE, gl.ONE)
        gl.BlendEquation(gl.MAX)
    }
}
