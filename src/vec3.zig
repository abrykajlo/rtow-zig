pub const Vec3 = @Vector(3, f64);

pub const Point3 = @Vector(3, f64);

pub inline fn length(v: *const Vec3) f64 {
    return @sqrt(lengthSquared(v));
}

pub inline fn lengthSquared(v: *const Vec3) f64 {
    return @reduce(.Add, v.* * v.*);
}

pub fn random(args: anytype) Vec3 {
    return .{ rtw.randomDouble(args), rtw.randomDouble(args), rtw.randomDouble(args) };
}

pub inline fn dot(u: *const Vec3, v: *const Vec3) f64 {
    return @reduce(.Add, u.* * v.*);
}

pub inline fn cross(u: *const Vec3, v: *const Vec3) Vec3 {
    return .{ u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0] };
}

pub inline fn unitVector(v: *const Vec3) Vec3 {
    return v.* / @as(Vec3, @splat(length(v)));
}

pub fn randomUnitVector() Vec3 {
    while (true) {
        const p = random(.{ .min = -1.0, .max = 1.0 });
        const lensq = lengthSquared(&p);
        if (1e-160 < lensq and lensq <= 1)
            return p / @as(Vec3, @splat(@sqrt(lensq)));
    }
}

pub fn randomOnHemisphere(normal: *const Vec3) Vec3 {
    const on_unit_sphere = randomUnitVector();
    if (dot(&on_unit_sphere, normal) > 0.0) { // In the same hemisphere as the normal
        return on_unit_sphere;
    } else {
        return -on_unit_sphere;
    }
}

const rtw = @import("rtweekend.zig");
