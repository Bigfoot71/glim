#version 460

layout(location = 0) in vec4 v_texcoord;
layout(location = 3) in vec4 v_color;

layout(binding = 0) uniform sampler2D u_texture;

layout(location = 0) out vec4 f_color;

void main() {
    f_color = texture(u_texture, v_texcoord.xy) * v_color;
}
