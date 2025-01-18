//! The event loop options that are specifically available on the Windows platform.

/// Whether the application is DPI aware.
///
/// Note that for DPI unaware applications, Windows will automatically scale the window and its
/// content to match the system DPI, which can result in blurry graphics.
///
/// **Default:** `true`
dpi_aware: bool = true,

/// Whether to hook into the Windows raw input API.
///
/// This allows receiving raw device input events, which can be useful for games or other
/// application that require low-level input handling.
///
/// **Default:** `false`
raw_input: bool = false,
