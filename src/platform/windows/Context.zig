//! The event loop context implementation on the Windows platform.

const std = @import("std");
const wind = @import("wind");
const win32 = @import("win32.zig");
const builtin = @import("builtin");

const Self = @This();

/// The allocator used by the event loop.
allocator: std.mem.Allocator,

/// Whether the event loop is currently running.
///
/// This boolean is flipped to `false` when the `exit` function is called.
event_loop_runing: bool = true,

/// Whether to automatically exit the event loop when no windows are open.
exit_when_no_windows: bool = true,

/// Whether the event loop should block the current thread when no new events are available.
block_when_no_events: bool = true,

/// Whether raw input hooks should be used.
use_raw_input: bool = false,

/// The list of windows that are managed by the event loop.
windows: std.ArrayListUnmanaged(*wind.platform.Window.State) = .{},

/// The event loop handler specified by the user.
handler: *const fn (ctx: *wind.Context, event: wind.Event) void,

/// The raw HINSTANCE of the application.
hinstance: win32.HINSTANCE,

//
// PRIVATE INTERFACE
//

/// Initializes a new `Context` using the provided event loop handler and options.
pub fn init(options: *const wind.EventLoopOptions, handler: wind.EventLoopHandler) Self {
    return Self{
        .allocator = options.allocator,
        .block_when_no_events = options.block_when_no_events,
        .exit_when_no_windows = options.exit_when_no_windows,
        .use_raw_input = options.platform_specific.raw_input,
        .handler = handler,
        .hinstance = getCurrentModuleHandle(),
    };
}

/// Frees the resources used by the event loop.
pub fn deinit(self: *Self) void {
    if (builtin.mode == .Debug and self.windows.items.len != 0) {
        std.debug.panic("Event loop deinitialized with windows still open", .{});
    }

    self.windows.deinit(self.allocator);
}

/// Returns the module handle of the current application.
inline fn getCurrentModuleHandle() win32.HINSTANCE {
    // When given `null`, this function is supposed to never fail.
    return win32.GetModuleHandleW(null).?;
}

/// Registers a window with the event loop.
pub fn registerWindow(self: *Self, window: *wind.platform.Window.State) error{OutOfMemory}!void {
    if (builtin.mode == .Debug and std.mem.indexOfScalar(*wind.platform.Window.State, self.windows.items, window) != null) {
        std.debug.panic("Window already registered with event loop", .{});
    }
    try self.windows.append(self.allocator, window);
}

/// Unregisters a window with the event loop.
pub fn unregisterWindow(self: *Self, window: *wind.platform.Window.State) void {
    const index = std.mem.indexOfScalar(*wind.platform.Window.State, self.windows.items, window);
    if (builtin.mode == .Debug and index == null) {
        std.debug.panic("Window was not registered with event loop", .{});
    }
    _ = self.windows.swapRemove(index.?);
}

/// Notifies the event loop that we're about to wait for more events.
pub fn endOfIteration(self: *Self) void {
    for (self.windows.items) |window| window.endOfIteration();
}

//
// OTHER PUBLIC FUNCTIONS
//

/// Returns whether the event loop should continue running.
///
/// This function takes both the `event_loop_running` and `exit_when_no_windows` fields into
/// account.
pub fn shouldContinue(self: *const Self) bool {
    if (!self.event_loop_runing) return false;
    if (self.exit_when_no_windows and self.windows.items.len == 0) return false;
    return true;
}

//
// PUBLIC INTERFACE
//

/// See `wind.Context.getAllocator`.
pub inline fn getAllocator(self: *const Self) std.mem.Allocator {
    return self.allocator;
}

/// See `wind.Context.setBlockWhenNoEvents`.
pub inline fn setBlockWhenNoEvents(self: *Self, yes: bool) void {
    self.block_when_no_events = yes;
}

/// See `wind.Context.exit`.
pub inline fn exit(self: *Self) void {
    self.event_loop_runing = false;
}
