const std = @import("std");

pub fn build(b: *std.Build) void {
    buildTestOnly(b, "day1");
    buildTestOnly(b, "day2");
    buildTestOnly(b, "day3");
    buildTestOnly(b, "day4");
}

fn buildTestOnly(b: *std.Build, comptime name: []const u8) void {
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/" ++ name ++ ".zig"),
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step(name, "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
