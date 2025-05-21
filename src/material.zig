pub const Material = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    const VTable = struct {
        scatter: *const fn (*const anyopaque, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool,
        destroy: *const fn (*const anyopaque, allocator: std.mem.Allocator) void,
    };

    pub inline fn scatter(self: *const Material, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return self.vtable.scatter(self.ptr, r_in, rec, attenuation, scattered);
    }

    pub inline fn destroy(self: *const Material, allocator: std.mem.Allocator) void {
        self.vtable.destroy(self.ptr, allocator);
    }
};

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

    pub fn destroy(context: *const anyopaque, allocator: std.mem.Allocator) void {
        const self: *const Lambertian = @ptrCast(@alignCast(context));
        allocator.destroy(self);
    }

    pub const vtable: Material.VTable = .{
        .scatter = scatter,
        .destroy = destroy,
    };
};

pub const Metal = struct {
    albedo: Color,
    fuzz: f64,

    pub fn scatter(context: *const anyopaque, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self: *const Metal = @ptrCast(@alignCast(context));
        var reflected = rtw.vec3.reflect(&r_in.dir, &rec.normal);
        reflected = rtw.vec3.unitVector(&reflected) + toVec3(self.fuzz) * rtw.vec3.randomUnitVector();
        scattered.* = .{ .orig = rec.p, .dir = reflected };
        attenuation.* = self.albedo;
        return rtw.vec3.dot(&scattered.dir, &rec.normal) > 0;
    }

    pub fn destroy(context: *const anyopaque, allocator: std.mem.Allocator) void {
        const self: *const Metal = @ptrCast(@alignCast(context));
        allocator.destroy(self);
    }

    pub const vtable: Material.VTable = .{
        .scatter = scatter,
        .destroy = destroy,
    };
};

pub const Dielectric = struct {
    // Refractive index in vacuum or air, or the ratio of the material's refractive index over
    // the refractive index of the enclosing media
    refraction_index: f64,

    pub fn scatter(context: *const anyopaque, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self: *const Dielectric = @ptrCast(@alignCast(context));
        attenuation.* = .{ 1.0, 1.0, 1.0 };
        const ri = if (rec.front_face) 1.0 / self.refraction_index else self.refraction_index;

        const unit_direction = rtw.vec3.unitVector(&r_in.dir);
        const cos_theta = @min(rtw.vec3.dot(&-unit_direction, &rec.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract = ri * sin_theta > 1.0;
        var direction: Vec3 = undefined;

        if (cannot_refract or reflectance(cos_theta, ri) > rtw.randomDouble(void{}))
            direction = rtw.vec3.reflect(&unit_direction, &rec.normal)
        else
            direction = rtw.vec3.refract(&unit_direction, &rec.normal, ri);

        scattered.* = .{ .orig = rec.p, .dir = direction };
        return true;
    }

    fn reflectance(cosine: f64, refraction_index: f64) f64 {
        // Use Schlick's approximation for reflectance
        var r0 = (1.0 - refraction_index) / (1.0 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1.0 - r0) * std.math.pow(f64, 1.0 - cosine, 5.0);
    }

    pub fn destroy(context: *const anyopaque, allocator: std.mem.Allocator) void {
        const self: *const Dielectric = @ptrCast(@alignCast(context));
        allocator.destroy(self);
    }

    pub const vtable: Material.VTable = .{
        .scatter = scatter,
        .destroy = destroy,
    };
};

pub const MaterialManager = struct {
    allocator: std.mem.Allocator,
    materials: std.ArrayList(Material),

    pub fn init(allocator: std.mem.Allocator) MaterialManager {
        return .{
            .allocator = allocator,
            .materials = .init(allocator),
        };
    }

    pub fn deinit(self: *const MaterialManager) void {
        for (self.materials.items) |material| {
            material.destroy(self.allocator);
        }
        self.materials.deinit();
    }

    pub fn create(self: *MaterialManager, val: anytype) !Material {
        const MaterialT = @TypeOf(val);

        const ptr = try self.allocator.create(MaterialT);
        ptr.* = val;

        const material = try self.materials.addOne();
        material.* = .{ .ptr = ptr, .vtable = &MaterialT.vtable };
        return material.*;
    }
};

const std = @import("std");

const rtw = @import("rtweekend.zig");
const Color = rtw.color.Color;
const Ray = rtw.Ray;
const Vec3 = rtw.vec3.Vec3;
const toVec3 = rtw.vec3.toVec3;

const HitRecord = @import("hittable.zig").HitRecord;
