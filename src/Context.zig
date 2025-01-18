//! The event loop context.
//!
//! A pointer to this type is passed to the event loop handler function passed to `run`. The context
//! represents the event loop itself, and can be used to either post events to the event loop, query
//! its state, configure its behavior, or exit it once the application means to stop.

const wind = @import("wind");
const std = @import("std");

const Self = @This();

/// The platform-specific event loop implementation.
///
/// It can sometimes be useful to access the underlying platform's event loop implementation, but
/// one must keep in mind that anything past this point is dependent on the platform and must be
/// correctly gated behind the proper compile-time checks.
impl: wind.platform.Context,

//
// PUBLIC INTERFACE
//

/// Returns the allocator that was used to create the event loop.
pub inline fn getAllocator(self: *const Self) std.mem.Allocator {
    return self.impl.getAllocator();
}

/// Sets whether the event loop should block the current thread when no new events are available.
///
/// See the documentation of `wind.EventLoopOptions.block_when_no_events` for more information.
pub inline fn setBlockWhenNoEvents(self: *Self, yes: bool) void {
    self.impl.setBlockWhenNoEvents(yes);
}

/// Exits from the event loop.
///
/// Note that new events might still be receieved after this function is called. The event loop will
/// actually stop after the next `end_of_iteration` event.
pub inline fn exit(self: *Self) void {
    self.impl.exit();
}
