//! The options used to start an event loop.
//!
//! An instance of this type is passed to the `run` function.

const std = @import("std");
const wind = @import("wind");

/// The allocator that should be used by the event loop when allocating memory.
///
/// This is required.
allocator: std.mem.Allocator,

/// Whether the event loop should block the current thread when no new events are available.
///
/// This should generally be `true` for applications that are not meant to update their state
/// continuously (i.e. GUI applications). Turning this off can result in higher CPU usage and
/// therefore higher energy consumption.
///
/// Note that this can be updated at runtime using the `setBlockWhenNoEvents` function of the
/// event loop context.
///
/// **Default:** `true`
block_when_no_events: bool = true,

/// Whether the event loop should automatically exit when no windows are open.
///
/// **Default:** `true`
exit_when_no_windows: bool = true,

/// The platform-specific options for the event loop.
///
/// Past this point, the options are dependent on the platform that the event loop is running on,
/// and one must make sure to gate the usage of these options with the appropriate platform
/// condition.
platform_specific: wind.platform.EventLoopOptions = .{},
