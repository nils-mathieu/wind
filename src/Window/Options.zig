//! The options used to create and open a new window.

const std = @import("std");
const wind = @import("wind");

/// The title of the created window.
///
/// **Default:** `"Windy Window"`
title: []const u8 = "Windy Window",

// TODO: Add support for custom icons.

// TODO: Add support for specifying logical dimensions rather than only physical ones.

/// The initial dimensions of the window's client area.
///
/// The client area of the window is the area that is actually rendered to (excluding the window's
/// title bar, borders, etc.).
///
/// Letting this value be `null` will cause the window to be created with the default dimensions
/// of the platform. Some platforms may attempt to restore a previous size, some will use a specific
/// value.
///
/// # Remarks
///
/// This is measured in *physical* pixels, independently of the window's DPI scaling factor.
///
/// **Default:** `null`
size: ?@Vector(2, u32) = null,

/// The minimum dimensions that the window can be resized to.
///
/// If the provided value is too small for the platform to support it, the closest supported value
/// will be used instead.
///
/// **Default:** The minimum value that the platform supports.
///
/// # Remarks
///
/// This is measured in *physical* pixels, independently of the window's DPI scaling factor.
min_size: @Vector(2, u32) = .{ 0, 0 },

/// The maximum dimensions that the window can be resized to.
///
/// If the provided value is too large for the platform to support it, the closest supported value
/// will be used instead.
///
/// **Default:** The maximum value that the platform supports.
///
/// # Remarks
///
/// This is measured in *physical* pixels, independently of the window's DPI scaling factor.
max_size: @Vector(2, u32) = .{ std.math.maxInt(u32), std.math.maxInt(u32) },

/// The initial position of the window on the screen.
///
/// Letting this value be `null` will let the underlying platform implementation choose a position
/// for the window. Usually, this will be the center of the screen, but some platforms may attempt
/// to restore the window's last position.
///
/// **Default:** `null`
///
/// # Remarks
///
/// This is measured in *physical* pixels, independently of the window's DPI scaling factor.
position: ?@Vector(2, i32) = null,

/// Whether the window should be manually resizable by the user.
///
/// Setting this value to `false` will also prevent the user from maximizing the window.
///
/// **Default:** `true`
resizable: bool = true,

/// Whether the window should include the standard window decorations (title bar, borders, etc.).
///
/// **Default:** `true`
decorations: bool = true,

/// Whether the window should be initially visible.
///
/// **Default:** `true`
visible: bool = true,

/// Whether the window should always appear on top of other windows.
///
/// **Default:** `false`
always_on_top: bool = false,

/// Whether the window should be initially maximized.
///
/// **Default:** `false`
maximized: bool = false,

/// Whether the window should be initially minimized.
///
/// **Default:** `false`
minimized: bool = false,

/// The platform-specific options.
///
/// One should make sure to gate access to this field behind the proper compile-time checks.
///
/// **Default:** Default options for the platform.
platform_specific: wind.platform.Window.Options = .{},
