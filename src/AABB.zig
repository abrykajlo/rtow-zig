const AABB = @This();

const rtw = @import("rtweekend.zig");
const Vec3 = rtw.vec3.Vec3;
const Ray = rtw.Ray;

const Interval = @import("Interval.zig");

x: Interval = .{},
y: Interval = .{},
z: Interval = .{},

pub fn init(a: Vec3, b: Vec3) AABB {
    return .{
        .x = if (a[0] <= b[0]) .init(a[0], b[0]) else .init(a[0], b[0]),
        .y = if (a[1] <= b[1]) .init(a[1], b[1]) else .init(a[1], b[1]),
        .z = if (a[2] <= b[2]) .init(a[2], b[2]) else .init(a[2], b[2]),
    };
}

pub fn axisInterval(self: AABB, n: usize) *const Interval {
    if (n == 1) return &self.y;
    if (n == 2) return &self.z;
    return &self.x;
}

pub fn hit(self: AABB, r: Ray, ray_t: Interval) bool {
    var _ray_t = ray_t;

    inline for (0..3) |axis| {
        const ax = self.axisInterval(axis);
        const adinv: f64 = 1.0 / r.dir[axis];

        const t0 = (ax.min - r.orig[axis]) * adinv;
        const t1 = (ax.max - r.orig[axis]) * adinv;

        if (t0 < t1) {
            if (t0 > _ray_t.min) _ray_t.min = t0;
            if (t1 < _ray_t.max) _ray_t.max = t1;
        } else {
            if (t1 > _ray_t.min) _ray_t.min = t1;
            if (t0 < _ray_t.max) _ray_t.max = t0;
        }

        if (_ray_t.max <= _ray_t.min)
            return false;
    }

    return true;
}
