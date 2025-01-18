//! The Windows operating system platform implementation of the `wind` library.

const wind = @import("wind");
const std = @import("std");

pub const Window = @import("Window/Window.zig");
pub const Context = @import("Context.zig");
pub const EventLoopOptions = @import("EventLoopOptions.zig");

/// The ID of a device.
pub const DeviceId = ?*opaque {
    pub fn format(self: *const @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) std.fmt.invalidFmtError(fmt, "DeviceId");
        try writer.print("0x{x}", .{@intFromPtr(self)});
    }
};

/// The ID of a finger on the Windows platform.
pub const FingerId = ?*opaque {
    pub fn format(self: *const @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) std.fmt.invalidFmtError(fmt, "FingerId");
        try writer.print("0x{x}", .{@intFromPtr(self)});
    }
};

/// Runs the event loop to completion.
pub fn run(options: *const wind.EventLoopOptions, handler: wind.EventLoopHandler) wind.Error!void {
    if (options.platform_specific.dpi_aware)
        @import("dpi_awareness.zig").becomeDpiAware() catch {}; // Just continue even if we can't become DPI aware.

    var ctx = wind.Context{ .impl = Context.init(options, handler) };
    defer ctx.impl.deinit();

    ctx.impl.handler(&ctx, wind.Event.created);
    defer ctx.impl.handler(&ctx, wind.Event.destroyed);

    return @import("event_loop.zig").runEventLoop(&ctx);
}
