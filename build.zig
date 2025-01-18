const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //
    // WIND OBJECT
    //

    const wind_obj = b.addObject(.{
        .name = "wind",
        .root_source_file = b.path("src/root.zig"),
        .optimize = optimize,
        .target = target,
    });
    wind_obj.root_module.addImport("wind", wind_obj.root_module);
    b.modules.put("wind", wind_obj.root_module) catch @panic("OOM");

    if (target.result.os.tag == .windows) {
        wind_obj.root_module.addImport("win32", b.lazyDependency("win32", .{}).?.module("zigwin32"));
    }

    //
    // EXAMPLES
    //

    const examples = [_][]const u8{ "simple-window", "multiple-windows", "all-events" };

    for (examples) |ex| {
        const example_exe = b.addExecutable(.{
            .name = ex,
            .root_source_file = b.path(b.fmt("examples/{s}.zig", .{ex})),
            .optimize = optimize,
            .target = target,
            .single_threaded = true,
        });
        example_exe.root_module.addImport("wind", wind_obj.root_module);

        const example_step = b.step(
            b.fmt("example-{s}", .{ex}),
            b.fmt("Run the `{s}` example", .{ex}),
        );
        example_step.dependOn(&b.addRunArtifact(example_exe).step);
    }

    //
    // CHECK STEP
    //

    const check_step = b.step("check", "Makes sure that all examples do compile");

    for (examples) |ex| {
        const example_exe = b.addExecutable(.{
            .name = ex,
            .root_source_file = b.path(b.fmt("examples/{s}.zig", .{ex})),
            .optimize = optimize,
            .target = target,
            .single_threaded = true,
        });
        example_exe.root_module.addImport("wind", wind_obj.root_module);
        check_step.dependOn(&example_exe.step);
    }

    //
    // DOCUMENTATION
    //

    const install_docs = b.addInstallDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "docs",
        .source_dir = wind_obj.getEmittedDocs(),
    });

    const docs_step = b.step("docs", "Generate documentation for the `wind` library");
    docs_step.dependOn(&install_docs.step);
}
