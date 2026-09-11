const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tracy_enabled = b.option(
        bool,
        "tracy",
        "Build with tracy support.",
    ) orelse false;

    const tracy = b.dependency("tracy", .{
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("tracy", tracy.module("tracy"));

    if (tracy_enabled) {
        exe_mod.addImport("tracy_impl", tracy.module("tracy_impl_enabled"));
    } else {
        exe_mod.addImport("tracy_impl", tracy.module("tracy_impl_disabled"));
    }

    const exe = b.addExecutable(.{
        .name = "rtow_zig",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
