pub const Material = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    const VTable = struct {
        scatter: *const fn (*const anyopaque, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool,
    };

    pub inline fn scatter(self: *const Material, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return self.vtable.scatter(self.ptr, r_in, rec, attenuation, scattered);
    }
};

pub fn create(allocator: std.mem.Allocator, T: type, props: T) !Material {
    const ptr = try allocator.create(T);
    ptr.* = props;
    return .{ .ptr = ptr, .vtable = &T.vtable };
}

pub fn destroy(allocator: std.mem.Allocator, T: type, material: Material) void {
    const typed_ptr: *T = @ptrCast(@alignCast(material.ptr));
    allocator.destroy(typed_ptr);
}

pub const Lambertian = struct {
    albedo: Color,

    pub fn scatter(context: *const anyopaque, _: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self: *const Lambertian = @ptrCast(@alignCast(context));
        var scatter_direction = rec.normal + rtw.vec3.randomUnitVector();

        // Catch degenerate scatter direction
        if (rtw.vec3.nearZero(&scatter_direction))
            scatter_direction = rec.normal;

        scattered.* = .{ .orig = rec.p, .dir = scatter_direction };
        attenuation.* = self.albedo;
        return true;
    }

    pub const vtable: Material.VTable = .{ .scatter = scatter };
};

pub const Metal = struct {
    albedo: Color,
    fuzz: f64,

    pub fn scatter(context: *const anyopaque, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self: *const Metal = @ptrCast(@alignCast(context));
        var reflected = rtw.vec3.reflect(&r_in.dir, &rec.normal);
        reflected = rtw.vec3.unitVector(&reflected) + @as(Vec3, @splat(self.fuzz)) * rtw.vec3.randomUnitVector();
        scattered.* = .{ .orig = rec.p, .dir = reflected };
        attenuation.* = self.albedo;
        return rtw.vec3.dot(&scattered.dir, &rec.normal) > 0;
    }

    pub const vtable: Material.VTable = .{ .scatter = scatter };
};

const std = @import("std");

const rtw = @import("rtweekend.zig");
const Color = rtw.color.Color;
const Ray = rtw.Ray;
const Vec3 = rtw.vec3.Vec3;

const HitRecord = @import("hittable.zig").HitRecord;
