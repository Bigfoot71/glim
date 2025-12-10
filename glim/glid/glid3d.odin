package glid

import glim ".."

import glm "core:math/linalg/glsl"
import "core:math"

begin_3d :: proc(fov, aspect, near, far: f32) {
    projection := glm.mat4Perspective(glm.radians(fov), aspect, near, far)
    glim.set_projection(projection)
    glim.push()
}

end_3d :: proc() {
    glim.flush()
    glim.pop()
}

cube :: proc(x, y, z, size: f32, filled := true) {
    box(x, y, z, size, size, size, filled)
}

box :: proc(x, y, z, w, h, d: f32, filled := true) {
    hw := w / 2
    hh := h / 2
    hd := d / 2

    if filled {
        glim.begin(.Quads)

        // Front face (+Z)
        glim.attribute(.Normal, {0, 0, 1, 0})
        glim.attribute(.TexCoord, {0, 0, 0, 1}); glim.vertex({x - hw, y - hh, z + hd, 1})
        glim.attribute(.TexCoord, {1, 0, 0, 1}); glim.vertex({x + hw, y - hh, z + hd, 1})
        glim.attribute(.TexCoord, {1, 1, 0, 1}); glim.vertex({x + hw, y + hh, z + hd, 1})
        glim.attribute(.TexCoord, {0, 1, 0, 1}); glim.vertex({x - hw, y + hh, z + hd, 1})

        // Back face (-Z)
        glim.attribute(.Normal, {0, 0, -1, 0})
        glim.attribute(.TexCoord, {0, 0, 0, 1}); glim.vertex({x + hw, y - hh, z - hd, 1})
        glim.attribute(.TexCoord, {1, 0, 0, 1}); glim.vertex({x - hw, y - hh, z - hd, 1})
        glim.attribute(.TexCoord, {1, 1, 0, 1}); glim.vertex({x - hw, y + hh, z - hd, 1})
        glim.attribute(.TexCoord, {0, 1, 0, 1}); glim.vertex({x + hw, y + hh, z - hd, 1})

        // Right face (+X)
        glim.attribute(.Normal, {1, 0, 0, 0})
        glim.attribute(.TexCoord, {0, 0, 0, 1}); glim.vertex({x + hw, y - hh, z + hd, 1})
        glim.attribute(.TexCoord, {1, 0, 0, 1}); glim.vertex({x + hw, y - hh, z - hd, 1})
        glim.attribute(.TexCoord, {1, 1, 0, 1}); glim.vertex({x + hw, y + hh, z - hd, 1})
        glim.attribute(.TexCoord, {0, 1, 0, 1}); glim.vertex({x + hw, y + hh, z + hd, 1})

        // Left face (-X)
        glim.attribute(.Normal, {-1, 0, 0, 0})
        glim.attribute(.TexCoord, {0, 0, 0, 1}); glim.vertex({x - hw, y - hh, z - hd, 1})
        glim.attribute(.TexCoord, {1, 0, 0, 1}); glim.vertex({x - hw, y - hh, z + hd, 1})
        glim.attribute(.TexCoord, {1, 1, 0, 1}); glim.vertex({x - hw, y + hh, z + hd, 1})
        glim.attribute(.TexCoord, {0, 1, 0, 1}); glim.vertex({x - hw, y + hh, z - hd, 1})

        // Top face (+Y)
        glim.attribute(.Normal, {0, 1, 0, 0})
        glim.attribute(.TexCoord, {0, 0, 0, 1}); glim.vertex({x - hw, y + hh, z + hd, 1})
        glim.attribute(.TexCoord, {1, 0, 0, 1}); glim.vertex({x + hw, y + hh, z + hd, 1})
        glim.attribute(.TexCoord, {1, 1, 0, 1}); glim.vertex({x + hw, y + hh, z - hd, 1})
        glim.attribute(.TexCoord, {0, 1, 0, 1}); glim.vertex({x - hw, y + hh, z - hd, 1})

        // Bottom face (-Y)
        glim.attribute(.Normal, {0, -1, 0, 0})
        glim.attribute(.TexCoord, {0, 0, 0, 1}); glim.vertex({x - hw, y - hh, z - hd, 1})
        glim.attribute(.TexCoord, {1, 0, 0, 1}); glim.vertex({x + hw, y - hh, z - hd, 1})
        glim.attribute(.TexCoord, {1, 1, 0, 1}); glim.vertex({x + hw, y - hh, z + hd, 1})
        glim.attribute(.TexCoord, {0, 1, 0, 1}); glim.vertex({x - hw, y - hh, z + hd, 1})

        glim.end()
    } else {
        glim.begin(.Lines)

        // Bottom rectangle
        glim.vertex({x - hw, y - hh, z - hd, 1})
        glim.vertex({x + hw, y - hh, z - hd, 1})

        glim.vertex({x + hw, y - hh, z - hd, 1})
        glim.vertex({x + hw, y - hh, z + hd, 1})

        glim.vertex({x + hw, y - hh, z + hd, 1})
        glim.vertex({x - hw, y - hh, z + hd, 1})

        glim.vertex({x - hw, y - hh, z + hd, 1})
        glim.vertex({x - hw, y - hh, z - hd, 1})

        // Top rectangle
        glim.vertex({x - hw, y + hh, z - hd, 1})
        glim.vertex({x + hw, y + hh, z - hd, 1})

        glim.vertex({x + hw, y + hh, z - hd, 1})
        glim.vertex({x + hw, y + hh, z + hd, 1})

        glim.vertex({x + hw, y + hh, z + hd, 1})
        glim.vertex({x - hw, y + hh, z + hd, 1})

        glim.vertex({x - hw, y + hh, z + hd, 1})
        glim.vertex({x - hw, y + hh, z - hd, 1})

        // Vertical edges
        glim.vertex({x - hw, y - hh, z - hd, 1})
        glim.vertex({x - hw, y + hh, z - hd, 1})

        glim.vertex({x + hw, y - hh, z - hd, 1})
        glim.vertex({x + hw, y + hh, z - hd, 1})

        glim.vertex({x + hw, y - hh, z + hd, 1})
        glim.vertex({x + hw, y + hh, z + hd, 1})

        glim.vertex({x - hw, y - hh, z + hd, 1})
        glim.vertex({x - hw, y + hh, z + hd, 1})

        glim.end()
    }
}

sphere :: proc(x, y, z, radius: f32, stacks := 16, slices := 32, filled := true) {
    if filled {
        glim.begin(.Triangles)

        for i in 0..<stacks {
            phi0 := f32(i) / f32(stacks) * math.PI
            phi1 := f32(i + 1) / f32(stacks) * math.PI

            for j in 0..<slices {
                theta0 := f32(j) / f32(slices) * math.TAU
                theta1 := f32(j + 1) / f32(slices) * math.TAU

                // Vertices
                p0 := [3]f32{
                    x + radius * math.sin(phi0) * math.cos(theta0),
                    y + radius * math.cos(phi0),
                    z + radius * math.sin(phi0) * math.sin(theta0),
                }
                p1 := [3]f32{
                    x + radius * math.sin(phi0) * math.cos(theta1),
                    y + radius * math.cos(phi0),
                    z + radius * math.sin(phi0) * math.sin(theta1),
                }
                p2 := [3]f32{
                    x + radius * math.sin(phi1) * math.cos(theta1),
                    y + radius * math.cos(phi1),
                    z + radius * math.sin(phi1) * math.sin(theta1),
                }
                p3 := [3]f32{
                    x + radius * math.sin(phi1) * math.cos(theta0),
                    y + radius * math.cos(phi1),
                    z + radius * math.sin(phi1) * math.sin(theta0),
                }

                // Normals
                n0 := glm.normalize(p0 - {x, y, z})
                n1 := glm.normalize(p1 - {x, y, z})
                n2 := glm.normalize(p2 - {x, y, z})
                n3 := glm.normalize(p3 - {x, y, z})

                // First triangle
                glim.attribute(.Normal, {n0.x, n0.y, n0.z, 0})
                glim.vertex({p0.x, p0.y, p0.z, 1})
                glim.attribute(.Normal, {n1.x, n1.y, n1.z, 0})
                glim.vertex({p1.x, p1.y, p1.z, 1})
                glim.attribute(.Normal, {n2.x, n2.y, n2.z, 0})
                glim.vertex({p2.x, p2.y, p2.z, 1})

                // Second triangle
                glim.attribute(.Normal, {n0.x, n0.y, n0.z, 0})
                glim.vertex({p0.x, p0.y, p0.z, 1})
                glim.attribute(.Normal, {n2.x, n2.y, n2.z, 0})
                glim.vertex({p2.x, p2.y, p2.z, 1})
                glim.attribute(.Normal, {n3.x, n3.y, n3.z, 0})
                glim.vertex({p3.x, p3.y, p3.z, 1})
            }
        }

        glim.end()
    } else {
        glim.begin(.Lines)

        // Latitude lines
        for i in 0..=stacks {
            phi := f32(i) / f32(stacks) * math.PI
            for j in 0..<slices {
                theta0 := f32(j) / f32(slices) * math.TAU
                theta1 := f32(j + 1) / f32(slices) * math.TAU

                p0 := [3]f32{
                    x + radius * math.sin(phi) * math.cos(theta0),
                    y + radius * math.cos(phi),
                    z + radius * math.sin(phi) * math.sin(theta0),
                }
                p1 := [3]f32{
                    x + radius * math.sin(phi) * math.cos(theta1),
                    y + radius * math.cos(phi),
                    z + radius * math.sin(phi) * math.sin(theta1),
                }

                glim.vertex({p0.x, p0.y, p0.z, 1})
                glim.vertex({p1.x, p1.y, p1.z, 1})
            }
        }

        // Longitude lines
        for j in 0..<slices {
            theta := f32(j) / f32(slices) * math.TAU
            for i in 0..<stacks {
                phi0 := f32(i) / f32(stacks) * math.PI
                phi1 := f32(i + 1) / f32(stacks) * math.PI

                p0 := [3]f32{
                    x + radius * math.sin(phi0) * math.cos(theta),
                    y + radius * math.cos(phi0),
                    z + radius * math.sin(phi0) * math.sin(theta),
                }
                p1 := [3]f32{
                    x + radius * math.sin(phi1) * math.cos(theta),
                    y + radius * math.cos(phi1),
                    z + radius * math.sin(phi1) * math.sin(theta),
                }

                glim.vertex({p0.x, p0.y, p0.z, 1})
                glim.vertex({p1.x, p1.y, p1.z, 1})
            }
        }

        glim.end()
    }
}

cylinder :: proc(x, y, z, radius, height: f32, slices := 32, filled := true) {
    hh := height / 2

    if filled {
        glim.begin(.Triangles)

        // Side faces
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            nx0 := math.cos(theta0)
            nz0 := math.sin(theta0)
            nx1 := math.cos(theta1)
            nz1 := math.sin(theta1)

            // First triangle
            glim.attribute(.Normal, {nx0, 0, nz0, 0})
            glim.vertex({x0, y - hh, z0, 1})
            glim.attribute(.Normal, {nx1, 0, nz1, 0})
            glim.vertex({x1, y - hh, z1, 1})
            glim.attribute(.Normal, {nx1, 0, nz1, 0})
            glim.vertex({x1, y + hh, z1, 1})

            // Second triangle
            glim.attribute(.Normal, {nx0, 0, nz0, 0})
            glim.vertex({x0, y - hh, z0, 1})
            glim.attribute(.Normal, {nx1, 0, nz1, 0})
            glim.vertex({x1, y + hh, z1, 1})
            glim.attribute(.Normal, {nx0, 0, nz0, 0})
            glim.vertex({x0, y + hh, z0, 1})
        }

        // Top cap
        glim.attribute(.Normal, {0, 1, 0, 0})
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            glim.vertex({x, y + hh, z, 1})
            glim.vertex({x0, y + hh, z0, 1})
            glim.vertex({x1, y + hh, z1, 1})
        }

        // Bottom cap
        glim.attribute(.Normal, {0, -1, 0, 0})
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            glim.vertex({x, y - hh, z, 1})
            glim.vertex({x1, y - hh, z1, 1})
            glim.vertex({x0, y - hh, z0, 1})
        }

        glim.end()
    } else {
        glim.begin(.Lines)

        // Top circle
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            glim.vertex({x0, y + hh, z0, 1})
            glim.vertex({x1, y + hh, z1, 1})
        }

        // Bottom circle
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            glim.vertex({x0, y - hh, z0, 1})
            glim.vertex({x1, y - hh, z1, 1})
        }

        // Vertical lines
        for i in 0..<slices / 4 {
            theta := f32(i) * 4 / f32(slices) * math.TAU

            px := x + math.cos(theta) * radius
            pz := z + math.sin(theta) * radius

            glim.vertex({px, y - hh, pz, 1})
            glim.vertex({px, y + hh, pz, 1})
        }

        glim.end()
    }
}

cone :: proc(x, y, z, radius, height: f32, slices := 32, filled := true) {
    hh := height / 2

    if filled {
        glim.begin(.Triangles)

        // Side faces
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            // Calculate normal for cone side
            edge1 := glm.normalize([3]f32{x0 - x, -height, z0 - z})
            edge2 := glm.normalize([3]f32{x1 - x, -height, z1 - z})
            normal := glm.normalize(glm.cross(edge1, edge2))

            glim.attribute(.Normal, {normal.x, normal.y, normal.z, 0})
            glim.vertex({x, y + hh, z, 1})
            glim.vertex({x0, y - hh, z0, 1})
            glim.vertex({x1, y - hh, z1, 1})
        }

        // Bottom cap
        glim.attribute(.Normal, {0, -1, 0, 0})
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            glim.vertex({x, y - hh, z, 1})
            glim.vertex({x1, y - hh, z1, 1})
            glim.vertex({x0, y - hh, z0, 1})
        }

        glim.end()
    } else {
        glim.begin(.Lines)

        // Bottom circle
        for i in 0..<slices {
            theta0 := f32(i) / f32(slices) * math.TAU
            theta1 := f32(i + 1) / f32(slices) * math.TAU

            x0 := x + math.cos(theta0) * radius
            z0 := z + math.sin(theta0) * radius
            x1 := x + math.cos(theta1) * radius
            z1 := z + math.sin(theta1) * radius

            glim.vertex({x0, y - hh, z0, 1})
            glim.vertex({x1, y - hh, z1, 1})
        }

        // Lines to apex
        for i in 0..<slices / 4 {
            theta := f32(i) * 4 / f32(slices) * math.TAU

            px := x + math.cos(theta) * radius
            pz := z + math.sin(theta) * radius

            glim.vertex({px, y - hh, pz, 1})
            glim.vertex({x, y + hh, z, 1})
        }

        glim.end()
    }
}

plane :: proc(x, y, z, w, d: f32, subdivisions := 1) {
    hw := w / 2
    hd := d / 2

    glim.begin(.Quads)
    glim.attribute(.Normal, {0, 1, 0, 0})

    step_x := w / f32(subdivisions)
    step_z := d / f32(subdivisions)

    for i in 0..<subdivisions {
        for j in 0..<subdivisions {
            x0 := x - hw + f32(i) * step_x
            z0 := z - hd + f32(j) * step_z
            x1 := x0 + step_x
            z1 := z0 + step_z

            u0 := f32(i) / f32(subdivisions)
            v0 := f32(j) / f32(subdivisions)
            u1 := f32(i + 1) / f32(subdivisions)
            v1 := f32(j + 1) / f32(subdivisions)

            glim.attribute(.TexCoord, {u0, v0, 0, 1})
            glim.vertex({x0, y, z0, 1})
            glim.attribute(.TexCoord, {u1, v0, 0, 1})
            glim.vertex({x1, y, z0, 1})
            glim.attribute(.TexCoord, {u1, v1, 0, 1})
            glim.vertex({x1, y, z1, 1})
            glim.attribute(.TexCoord, {u0, v1, 0, 1})
            glim.vertex({x0, y, z1, 1})
        }
    }

    glim.end()
}

grid :: proc(x, y, z, w, d: f32, lines_x, lines_z: int) {
    hw := w / 2
    hd := d / 2

    glim.begin(.Lines)

    // Lines along X
    for i in 0..=lines_z {
        t := f32(i) / f32(lines_z)
        pz := z - hd + t * d

        glim.vertex({x - hw, y, pz, 1})
        glim.vertex({x + hw, y, pz, 1})
    }

    // Lines along Z
    for i in 0..=lines_x {
        t := f32(i) / f32(lines_x)
        px := x - hw + t * w

        glim.vertex({px, y, z - hd, 1})
        glim.vertex({px, y, z + hd, 1})
    }

    glim.end()
}

axes :: proc(x, y, z, length: f32) {
    glim.begin(.Lines)

    // X axis (red)
    glim.attribute(.Color, {1, 0, 0, 1})
    glim.vertex({x, y, z, 1})
    glim.vertex({x + length, y, z, 1})

    // Y axis (green)
    glim.attribute(.Color, {0, 1, 0, 1})
    glim.vertex({x, y, z, 1})
    glim.vertex({x, y + length, z, 1})

    // Z axis (blue)
    glim.attribute(.Color, {0, 0, 1, 1})
    glim.vertex({x, y, z, 1})
    glim.vertex({x, y, z + length, 1})

    glim.end()
}
