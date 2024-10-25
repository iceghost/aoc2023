const std = @import("std");

pub fn build(b: *std.Build) void {
    buildTestOnly(b, "day1");
}

fn buildTestOnly(b: *std.Build, comptime name: []const u8) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/" ++ name ++ ".zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step(name, "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
