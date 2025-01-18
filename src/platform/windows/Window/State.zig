//! The internal state of the window.
//!
//! An instance of this type is allocated on the heap so that a pointer to it can be stored
//! in the Window's user data (which itself can be retrieved within the window procedured registered
//! for that window).

const std = @import("std");
const wind = @import("wind");
const win32 = @import("../win32.zig");

const Self = @This();

/// The event loop context that owns this window.
owner: *wind.Context,

/// The window handle of the window.
hwnd: win32.HWND,

/// The name of the window class that this window belongs to.
window_class_name: [:0]u16,

/// Whether the window has raw input hooks installed.
has_raw_input_hooks: bool,

/// Whether the window currently is focused.
has_focus: bool,

/// The minimum size of the window.
min_size: @Vector(2, u32),

/// The maximum size of the window.
max_size: @Vector(2, u32),

/// Whether the cursor is currently hovering over the window.
///
/// This is used to determine when a `cursor_hover(true)` event should be emitted.
cursor_hover: bool = false,

/// If a high surrogate was received in the last `WM_CHAR` message, it is stored here for
/// processing and matching with the next `WM_CHAR` message (which is expected to contain the
/// associated low surrogate).
///
/// When no high surrogate is stored, this field is set to 0.
high_surrogate: u16 = 0,

/// A buffered key event, waiting to be matched with a corresponding `WM_CHAR` message.
buffered_key_event: ?RawKeyEvent = null,

/// Contains information about a key event.
pub const RawKeyEvent = struct {
    /// The key-code.
    key_code: wind.KeyCode,
    /// Whether the key was pressed or released.
    pressed: bool,
};

/// Flushes the currently buffered key event.
pub fn flushBufferedKeyEvent(self: *Self) void {
    if (self.buffered_key_event) |key_event| {
        self.buffered_key_event = null;

        self.owner.impl.handler(self.owner, wind.Event{ .window = .{
            .window_id = @ptrCast(self.hwnd),
            .payload = .{ .keyboard = .{
                .device_id = null,
                .key_code = key_event.key_code,
                .label = "",
                .pressed = key_event.pressed,
            } },
        } });
    }
}

/// Takes a key event, parses it and eventually emits an event.
pub fn takeKeyEvent(self: *Self, key: RawKeyEvent) void {
    self.flushBufferedKeyEvent();
    self.buffered_key_event = key;
}

/// Takes a UTF-16 potentially partial value, parses it and eventually emits an event.
pub fn takeUtf16(self: *Self, val: u16) void {
    var utf16_buf = [2]u16{ 0, 0 };
    var utf16: []u16 = undefined;

    if (val >= 0xd800 and val <= 0xdbff) {
        // High surrogate.
        self.high_surrogate = val;
        return;
    } else if (val >= 0xdc00 and val <= 0xdfff) {
        // Low surrogate.
        if (self.high_surrogate != 0) {
            utf16_buf = .{ self.high_surrogate, val };
            utf16 = utf16_buf[0..2];
        } else {
            // A low surrogate without a high surrogate. This is an error.
            return;
        }
    } else {
        // The character fits on a single code point.
        self.high_surrogate = 0; // Clear the high surrogate in case of invalid sequence.
        utf16_buf = .{ val, 0 };
        utf16 = utf16_buf[0..1];
    }

    var utf8_buf = [_]u8{ 0, 0, 0, 0 };
    const utf8_len = std.unicode.utf16LeToUtf8(&utf8_buf, utf16) catch 0;
    const text = utf8_buf[0..utf8_len];

    if (self.buffered_key_event) |key_event| {
        self.buffered_key_event = null;

        self.owner.impl.handler(self.owner, wind.Event{ .window = .{
            .window_id = @ptrCast(self.hwnd),
            .payload = .{ .keyboard = .{
                .device_id = null,
                .key_code = key_event.key_code,
                .label = text,
                .pressed = key_event.pressed,
            } },
        } });
    }

    if (text.len != 0) {
        self.owner.impl.handler(self.owner, wind.Event{ .window = .{
            .window_id = @ptrCast(self.hwnd),
            .payload = .{ .text_typed = .{
                .device_id = null,
                .ime = .{ .commit = text },
            } },
        } });
    }
}

/// Notifies the window state that we're about to wait for more events.
pub fn endOfIteration(self: *Self) void {
    self.flushBufferedKeyEvent();
}
