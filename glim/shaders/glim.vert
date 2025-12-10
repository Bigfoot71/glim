#version 460

layout(location = 0) in vec4 a_position;
layout(location = 1) in vec4 a_texcoord;
layout(location = 2) in vec4 a_normal;
layout(location = 3) in vec4 a_tangent;
layout(location = 4) in vec4 a_color;
layout(location = 5) in vec4 a_loc5;
layout(location = 6) in vec4 a_loc6;

layout(location = 0) uniform mat4 u_mvp;

layout(location = 0) out vec4 v_texcoord;
layout(location = 1) out vec4 v_normal;
layout(location = 2) out vec4 v_tangent;
layout(location = 3) out vec4 v_color;
layout(location = 4) out vec4 v_loc5;
layout(location = 5) out vec4 v_loc6;

void main() {
    gl_Position = u_mvp * a_position;
    v_texcoord = a_texcoord;
    v_normal = a_normal;
    v_tangent = a_tangent;
    v_color = a_color;
    v_loc5 = a_loc5;
    v_loc6 = a_loc6;
}
