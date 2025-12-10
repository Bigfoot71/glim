package glid

import glim ".."

import glm "core:math/linalg/glsl"
import "core:math"

Origin :: enum {
    Bottom_Left,
    Top_Left,
    Center,
}

begin_2d :: proc(width, height: f32, origin := Origin.Bottom_Left) {
    projection: matrix[4, 4]f32
    
    switch origin {
    case .Bottom_Left:
        projection = glm.mat4Ortho3d(0, width, 0, height, -1, 1)
    case .Top_Left:
        projection = glm.mat4Ortho3d(0, width, height, 0, -1, 1)
    case .Center:
        projection = glm.mat4Ortho3d(-width/2, width/2, -height/2, height/2, -1, 1)
    }
    
    glim.set_projection(projection)
    glim.push()
}

end_2d :: proc() {
    glim.flush()
    glim.pop()
}

line :: proc(x0, y0, x1, y1: f32) {
    glim.begin(.Lines)
    glim.vertex({x0, y0, 0, 1})
    glim.vertex({x1, y1, 0, 1})
    glim.end()
}

triangle :: proc(x0, y0, x1, y1, x2, y2: f32, filled := true) {
    if filled {
        glim.begin(.Triangles)
        glim.vertex({x0, y0, 0, 1})
        glim.vertex({x1, y1, 0, 1})
        glim.vertex({x2, y2, 0, 1})
        glim.end()
    } else {
        glim.begin(.Lines)
        glim.vertex({x0, y0, 0, 1})
        glim.vertex({x1, y1, 0, 1})
        
        glim.vertex({x1, y1, 0, 1})
        glim.vertex({x2, y2, 0, 1})
        
        glim.vertex({x2, y2, 0, 1})
        glim.vertex({x0, y0, 0, 1})
        glim.end()
    }
}

rectangle :: proc(x, y, w, h: f32, filled := true) {
    if filled {
        glim.begin(.Quads)
        glim.attribute(.TexCoord, {0, 0, 0, 1}); glim.vertex({x,     y,     0, 1})
        glim.attribute(.TexCoord, {1, 0, 0, 1}); glim.vertex({x + w, y,     0, 1})
        glim.attribute(.TexCoord, {1, 1, 0, 1}); glim.vertex({x + w, y + h, 0, 1})
        glim.attribute(.TexCoord, {0, 1, 0, 1}); glim.vertex({x,     y + h, 0, 1})
        glim.end()
    } else {
        glim.begin(.Lines)
        glim.vertex({x,     y,     0, 1})
        glim.vertex({x + w, y,     0, 1})
        
        glim.vertex({x + w, y,     0, 1})
        glim.vertex({x + w, y + h, 0, 1})
        
        glim.vertex({x + w, y + h, 0, 1})
        glim.vertex({x,     y + h, 0, 1})
        
        glim.vertex({x,     y + h, 0, 1})
        glim.vertex({x,     y,     0, 1})
        glim.end()
    }
}

textured_rectangle :: proc(x, y, w, h: f32, u0 := f32(0), v0 := f32(0), u1 := f32(1), v1 := f32(1)) {
    glim.begin(.Quads)
    glim.attribute(.TexCoord, {u0, v0, 0, 1}); glim.vertex({x,     y,     0, 1})
    glim.attribute(.TexCoord, {u1, v0, 0, 1}); glim.vertex({x + w, y,     0, 1})
    glim.attribute(.TexCoord, {u1, v1, 0, 1}); glim.vertex({x + w, y + h, 0, 1})
    glim.attribute(.TexCoord, {u0, v1, 0, 1}); glim.vertex({x,     y + h, 0, 1})
    glim.end()
}

rounded_rectangle :: proc(x, y, w, h, radius: f32, segments := 8, filled := true) {
    r := min(radius, min(w, h) / 2)
    
    if filled {
        glim.begin(.Triangles)

        cx := x + w / 2
        cy := y + h / 2

        corners := [4][2]f32{
            {x + r,     y + r},     // Bottom-left
            {x + w - r, y + r},     // Bottom-right
            {x + w - r, y + h - r}, // Top-right
            {x + r,     y + h - r}, // Top-left
        }

        start_angles := [4]f32{math.PI, math.PI * 1.5, 0, math.PI * 0.5}

        for corner, corner_idx in corners {
            start_angle := start_angles[corner_idx]
            for i in 0..<segments {
                angle0 := start_angle + f32(i) / f32(segments) * (math.PI / 2)
                angle1 := start_angle + f32(i + 1) / f32(segments) * (math.PI / 2)

                x0 := corner.x + math.cos(angle0) * r
                y0 := corner.y + math.sin(angle0) * r
                x1 := corner.x + math.cos(angle1) * r
                y1 := corner.y + math.sin(angle1) * r

                glim.vertex({cx, cy, 0, 1})
                glim.vertex({x0, y0, 0, 1})
                glim.vertex({x1, y1, 0, 1})
            }
        }

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x + r, y, 0, 1})
        glim.vertex({x + w - r, y, 0, 1})

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x + w - r, y, 0, 1})
        glim.vertex({x + w, y + r, 0, 1})

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x + w, y + r, 0, 1})
        glim.vertex({x + w, y + h - r, 0, 1})

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x + w, y + h - r, 0, 1})
        glim.vertex({x + w - r, y + h, 0, 1})

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x + w - r, y + h, 0, 1})
        glim.vertex({x + r, y + h, 0, 1})

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x + r, y + h, 0, 1})
        glim.vertex({x, y + h - r, 0, 1})

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x, y + h - r, 0, 1})
        glim.vertex({x, y + r, 0, 1})

        glim.vertex({cx, cy, 0, 1})
        glim.vertex({x, y + r, 0, 1})
        glim.vertex({x + r, y, 0, 1})

        glim.end()
    } else {
        glim.begin(.Lines)

        corners := [4][2]f32{
            {x + r,     y + r},
            {x + w - r, y + r},
            {x + w - r, y + h - r},
            {x + r,     y + h - r},
        }

        start_angles := [4]f32{math.PI, math.PI * 1.5, 0, math.PI * 0.5}

        for corner, corner_idx in corners {
            start_angle := start_angles[corner_idx]
            for i in 0..<segments {
                angle0 := start_angle + f32(i) / f32(segments) * (math.PI / 2)
                angle1 := start_angle + f32(i + 1) / f32(segments) * (math.PI / 2)

                x0 := corner.x + math.cos(angle0) * r
                y0 := corner.y + math.sin(angle0) * r
                x1 := corner.x + math.cos(angle1) * r
                y1 := corner.y + math.sin(angle1) * r

                glim.vertex({x0, y0, 0, 1})
                glim.vertex({x1, y1, 0, 1})
            }
        }

        glim.end()
    }
}

circle :: proc(x, y, radius: f32, segments := 32, filled := true) {
    ellipse(x, y, radius, radius, segments, filled)
}

ellipse :: proc(x, y, radius_x, radius_y: f32, segments := 32, filled := true) {
    if filled {
        glim.begin(.Triangles)
        for i in 0..<segments {
            angle0 := f32(i) / f32(segments) * math.TAU
            angle1 := f32(i + 1) / f32(segments) * math.TAU

            x0 := x + math.cos(angle0) * radius_x
            y0 := y + math.sin(angle0) * radius_y
            x1 := x + math.cos(angle1) * radius_x
            y1 := y + math.sin(angle1) * radius_y

            glim.vertex({x,  y,  0, 1})
            glim.vertex({x0, y0, 0, 1})
            glim.vertex({x1, y1, 0, 1})
        }
        glim.end()
    } else {
        glim.begin(.Lines)
        for i in 0..<segments {
            angle0 := f32(i) / f32(segments) * math.TAU
            angle1 := f32(i + 1) / f32(segments) * math.TAU

            x0 := x + math.cos(angle0) * radius_x
            y0 := y + math.sin(angle0) * radius_y
            x1 := x + math.cos(angle1) * radius_x
            y1 := y + math.sin(angle1) * radius_y

            glim.vertex({x0, y0, 0, 1})
            glim.vertex({x1, y1, 0, 1})
        }
        glim.end()
    }
}

arc :: proc(x, y, radius, start_angle, end_angle: f32, segments := 32) {
    glim.begin(.Lines)

    angle_range := end_angle - start_angle
    for i in 0..<segments {
        angle0 := start_angle + f32(i) / f32(segments) * angle_range
        angle1 := start_angle + f32(i + 1) / f32(segments) * angle_range

        x0 := x + math.cos(angle0) * radius
        y0 := y + math.sin(angle0) * radius
        x1 := x + math.cos(angle1) * radius
        y1 := y + math.sin(angle1) * radius

        glim.vertex({x0, y0, 0, 1})
        glim.vertex({x1, y1, 0, 1})
    }

    glim.end()
}

bezier_quadratic :: proc(x0, y0, x1, y1, x2, y2: f32, segments := 32) {
    glim.begin(.Lines)

    for i in 0..<segments {
        t0 := f32(i) / f32(segments)
        t1 := f32(i + 1) / f32(segments)

        px0 := (1 - t0) * (1 - t0) * x0 + 2 * (1 - t0) * t0 * x1 + t0 * t0 * x2
        py0 := (1 - t0) * (1 - t0) * y0 + 2 * (1 - t0) * t0 * y1 + t0 * t0 * y2

        px1 := (1 - t1) * (1 - t1) * x0 + 2 * (1 - t1) * t1 * x1 + t1 * t1 * x2
        py1 := (1 - t1) * (1 - t1) * y0 + 2 * (1 - t1) * t1 * y1 + t1 * t1 * y2

        glim.vertex({px0, py0, 0, 1})
        glim.vertex({px1, py1, 0, 1})
    }

    glim.end()
}

bezier_cubic :: proc(x0, y0, x1, y1, x2, y2, x3, y3: f32, segments := 32) {
    glim.begin(.Lines)

    for i in 0..<segments {
        t0 := f32(i) / f32(segments)
        t1 := f32(i + 1) / f32(segments)

        px0 := (1-t0)*(1-t0)*(1-t0)*x0 + 3*(1-t0)*(1-t0)*t0*x1 + 3*(1-t0)*t0*t0*x2 + t0*t0*t0*x3
        py0 := (1-t0)*(1-t0)*(1-t0)*y0 + 3*(1-t0)*(1-t0)*t0*y1 + 3*(1-t0)*t0*t0*y2 + t0*t0*t0*y3

        px1 := (1-t1)*(1-t1)*(1-t1)*x0 + 3*(1-t1)*(1-t1)*t1*x1 + 3*(1-t1)*t1*t1*x2 + t1*t1*t1*x3
        py1 := (1-t1)*(1-t1)*(1-t1)*y0 + 3*(1-t1)*(1-t1)*t1*y1 + 3*(1-t1)*t1*t1*y2 + t1*t1*t1*y3

        glim.vertex({px0, py0, 0, 1})
        glim.vertex({px1, py1, 0, 1})
    }

    glim.end()
}

polygon :: proc(points: [][2]f32, filled := true) {
    if len(points) < 3 do return

    if filled {
        // Triangle fan from the first point
        glim.begin(.Triangles)
        for i in 1..<len(points) - 1 {
            glim.vertex({points[0].x, points[0].y, 0, 1})
            glim.vertex({points[i].x, points[i].y, 0, 1})
            glim.vertex({points[i + 1].x, points[i + 1].y, 0, 1})
        }
        glim.end()
    } else {
        glim.begin(.Lines)
        for i in 0..<len(points) {
            p0 := points[i]
            p1 := points[(i + 1) % len(points)]
            glim.vertex({p0.x, p0.y, 0, 1})
            glim.vertex({p1.x, p1.y, 0, 1})
        }
        glim.end()
    }
}

polyline :: proc(points: [][2]f32) {
    if len(points) < 2 do return

    glim.begin(.Lines)
    for i in 0..<len(points) - 1 {
        glim.vertex({points[i].x, points[i].y, 0, 1})
        glim.vertex({points[i + 1].x, points[i + 1].y, 0, 1})
    }
    glim.end()
}
