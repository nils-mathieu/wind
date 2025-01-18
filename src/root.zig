//! `wind` is a pure Zig cross-platform windowing library.
//!
//! It aims to be as powerful and flexible as possible, covering as much use cases and platforms
//! as possible, potentially at the cost of user-friendliness or usability. It is expected that
//! specialized wrappers will be created depending on the use-case (game engines, GUI libraries,
//! etc.).

const builtin = @import("builtin");

pub usingnamespace @import("event/root.zig");
pub const Context = @import("Context.zig");
pub const EventLoopOptions = @import("EventLoopOptions.zig");
pub const Window = @import("Window/Window.zig");
pub const DeviceId = platform.DeviceId;
pub const FingerId = platform.FingerId;

/// This namespace re-exports the platform-specific implementation of the `wind` library.
///
/// Using anything behind this point is dependent on the underlying platform and need to be
/// gated behind the appropriate compile-time checks.
pub const platform = switch (builtin.os.tag) {
    .windows => @import("platform/windows/root.zig"),
    else => unreachable,
};

/// The handler function that will be called when new events are posted to the event loop.
pub const EventLoopHandler = *const fn (ctx: *Context, event: @This().Event) void;

/// An error that might occur when running the event loop.
pub const Error = error{
    /// The operating system returned an unexpected error while running the event loop.
    OsError,
    /// The event loop ran out of memory.
    OutOfMemory,
};

/// Starts the underlying platform's event to completion.
///
/// # Parameters
///
/// - `options`: The options passed to the underlying platform. They control some aspects of the
///   event loop, or include information required to start it.
///
/// - `callback`: The callback that will be called when new events are posted to the event loop.
///
/// # Examples
///
/// ```zig
/// fn eventHandler(ctx: *wind.Context, event: wind.Event) void {
///     // ... do stuff
/// }
///
/// wind.run(
///     .{ .allocator = my_allocator },
///     eventHandler,
/// );
/// ```
///
/// # Returns
///
/// On failure, the implementation will attempt to bubble up the error up to the user. Some
/// platforms do not give back the control flow of the program once an event loop has been
/// started, so this function may not actually return, even in case of error.
///
/// On success, the function will usually simply return. But again, on some platforms, the
/// control flow is not returned to the user.
pub fn run(options: EventLoopOptions, callback: EventLoopHandler) Error!void {
    return platform.run(&options, callback);
}
