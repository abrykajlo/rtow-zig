pub const Vec3 = @Vector(3, f64);

pub const Point3 = @Vector(3, f64);

pub inline fn length(v: *const Vec3) f64 {
    return @sqrt(lengthSquared(v));
}

pub inline fn lengthSquared(v: *const Vec3) f64 {
    return @reduce(.Add, v.* * v.*);
}

/// Return true if the vector is close to zero in all dimensions.
pub fn nearZero(v: *const Vec3) bool {
    const s = 1e-8;
    return @abs(v[0]) < s and @abs(v[1]) < s and @abs(v[2]) < s;
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
    return v.* / toVec3(length(v));
}

pub inline fn randomInUnitDisk() Vec3 {
    while (true) {
        const p: Vec3 = .{ rtw.randomDouble(.{ .min = -1, .max = 1 }), rtw.randomDouble(.{ .min = -1, .max = 1 }), 0 };
        if (rtw.vec3.lengthSquared(&p) < 1)
            return p;
    }
}

pub fn randomUnitVector() Vec3 {
    while (true) {
        const p = random(.{ .min = -1.0, .max = 1.0 });
        const lensq = lengthSquared(&p);
        if (1e-160 < lensq and lensq <= 1)
            return p / toVec3(@sqrt(lensq));
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

pub inline fn reflect(v: *const Vec3, n: *const Vec3) Vec3 {
    return v.* - toVec3(2.0 * dot(v, n)) * n.*;
}

pub inline fn refract(uv: *const Vec3, n: *const Vec3, etai_over_etat: f64) Vec3 {
    const cos_theta = @min(dot(&-uv.*, n), 1.0);
    const r_out_perp = toVec3(etai_over_etat) * (uv.* + toVec3(cos_theta) * n.*);
    const r_out_parallel = toVec3(-@sqrt(@abs(1.0 - lengthSquared(&r_out_perp)))) * n.*;
    return r_out_perp + r_out_parallel;
}

pub inline fn toVec3(s: anytype) Vec3 {
    switch (@typeInfo(@TypeOf(s))) {
        .int, .comptime_int => return @splat(@floatFromInt(s)),
        .float, .comptime_float => return @splat(s),
        else => @compileError("Type cannot be splatted"),
    }
}

const rtw = @import("rtweekend.zig");
