orig: Point3,
dir: Vec3,

pub fn at(self: *const @This(), t: f64) Point3 {
    return self.orig + @as(Vec3, @splat(t)) * self.dir;
}

const rtw = @import("rtweekend.zig");
const Point3 = rtw.vec3.Point3;
const Vec3 = rtw.vec3.Vec3;
