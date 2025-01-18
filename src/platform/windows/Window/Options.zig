//! The Windows-specific options for creating a window.

/// Whether redraw requests should be sent when the window is resized horizontally.
///
/// **Default:** `true`
request_redraw_on_horizontal_resize: bool = true,

/// Whether redraw requests should be sent when the window is resized vertically.
///
/// **Default:** `true`
request_redraw_on_vertical_resize: bool = true,

/// Whether the window should be sensitive to file drops.
///
/// **Default:** `true`
accept_files: bool = true,
