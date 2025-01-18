const wind = @import("wind");

const Self = @This();

pub const Options = @import("Options.zig");

/// The underlying platform-specific window implementation.
///
/// Using the underlying platform implementation can sometimes be useful, but one must keep in
/// mind that anything past this point is dependent on the platform and must be correctly gated
/// behind the proper compile-time checks.
impl: wind.platform.Window,

//
// PUBLIC INTERFACE
//

/// A type that is responsible for uniquely identifying a window on the system.
pub const Id = wind.platform.Window.Id;

/// Creates and opens a new window.
///
/// The created window will be managed by provided event loop. The window must be closed before
/// the event loop is destroyed.
///
/// # Parameters
///
/// - `ctx`: The event loop context that will manage the window.
///
/// - `options`: The options that will be used to create the window.
///
/// # Returns
///
/// If an error occurs while creating the window, it will be returned. Otherwise, the newly created
/// window will be returned.
pub inline fn open(ctx: *wind.Context, options: Options) wind.Error!Self {
    return Self{ .impl = try wind.platform.Window.open(ctx, &options) };
}

/// Closes and frees the resources that were allocated for the window.
///
/// After this function has been called, it must be assumed that the window is no longer valid
/// and may not be used in any way.
pub inline fn close(self: *Self) void {
    self.impl.close();
}

// STATE GETTERS

/// Returns the window's unique ID.
pub inline fn getId(self: *const Self) Id {
    return self.impl.getId();
}

/// Returns whether the window currently has focus on the system.
pub inline fn isFocused(self: *const Self) bool {
    self.impl.isFocused();
}
