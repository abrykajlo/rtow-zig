pub const Vec3 = @Vector(3, f64);

pub const Point3 = @Vector(3, f64);

pub inline fn length(v: *const Vec3) f64 {
    return @sqrt(lengthSquared(v));
}

pub inline fn lengthSquared(v: *const Vec3) f64 {
    return @reduce(.Add, v.* * v.*);
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
