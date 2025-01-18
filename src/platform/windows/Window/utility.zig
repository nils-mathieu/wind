//! Provides utility functions to work with windows.

const std = @import("std");
const wind = @import("wind");
const win32 = @import("../win32.zig");
const builtin = @import("builtin");

/// The next window class ID that will be used.
var next_window_class_id = std.atomic.Value(usize).init(0);

/// Returns a unique window class name.
///
/// # Returns
///
/// A unique window class name that can be used to register a window class. The pointer must be
/// freed by the caller.
pub fn getUniqueWindowClassName(allocator: std.mem.Allocator) error{OutOfMemory}![:0]u16 {
    var id = next_window_class_id.fetchAdd(1, .monotonic);

    if (id == std.math.maxInt(usize)) {
        std.debug.panic("Ran out of valid window class names - how did this happen?", .{});
    }

    const alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-";
    const prefix = std.unicode.utf8ToUtf16LeStringLiteral("__wind_window_class_");
    const encoded_id_len = if (id == 0) 0 else std.math.log(usize, alphabet.len, id) + 1;

    var buffer = try allocator.alloc(u16, prefix.len + encoded_id_len + 1);
    errdefer allocator.free(buffer);

    var cursor: usize = 0;

    @memcpy(buffer.ptr, prefix);
    cursor += prefix.len;

    while (id != 0) {
        buffer[cursor] = alphabet[id % alphabet.len];
        id /= alphabet.len;
        cursor += 1;
    }

    buffer[cursor] = 0;
    return buffer[0..cursor :0];
}

/// The options of the `registerWindowClass` function.
pub const WindowClassOptions = struct {
    /// The name of the registered window class.
    name: [*:0]u16,
    /// The window procedure that will be used to handle messages for windows of this class.
    wndproc: win32.WNDPROC,
    /// The HINSTANCE of the application owning the window class.
    hinstance: win32.HINSTANCE,
    /// Whether to send a `WM_PAINT` message to the window whenever it is resized horizontally.
    h_redraw: bool,
    /// Whether to send a `WM_PAINT` message to the window whenever it is resized vertically.
    v_redraw: bool,
};

/// Registers a new window class under the provided name.
pub fn registerWindowClass(options: WindowClassOptions) wind.Error!void {
    const info = win32.WNDCLASSEXW{
        .cbSize = @sizeOf(win32.WNDCLASSEXW),
        .lpszClassName = options.name,
        .lpfnWndProc = options.wndproc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hbrBackground = null,
        .hCursor = null,
        .hIcon = null,
        .hIconSm = null,
        .hInstance = options.hinstance,
        .lpszMenuName = null,
        .style = .{
            .HREDRAW = @intFromBool(options.h_redraw),
            .VREDRAW = @intFromBool(options.v_redraw),
        },
    };

    switch (win32.RegisterClassExW(&info)) {
        0 => return error.OsError,
        else => {},
    }
}

/// Unregisters the provided window class.
pub fn unregisterWindowClass(name: [*:0]u16, hinstance: win32.HINSTANCE) void {
    const ret = win32.UnregisterClassW(name, hinstance);
    if (builtin.mode == .Debug and ret == 0) {
        std.debug.panic("Failed to unregister window class", .{});
    }
}

/// The options of the `createWindow` function.
pub const CreateWindowOptions = struct {
    /// An allocator that will be used to allocate temporary memory.
    allocator: std.mem.Allocator,
    /// The title of the window, encoded as UTF-8.
    title: []const u8,
    /// The size of the window.
    size: ?[2]u32,
    /// The position of the window.
    position: ?[2]i32,
    /// The name of the window class this window belongs to.
    window_class_name: [*:0]u16,
    /// The HINSTANCE of the application owning the window.
    hinstance: win32.HINSTANCE,
    /// Whether the window should have a maximize button.
    maximize_button: bool,
    /// Whether the window should have a minimize button.
    minimize_button: bool,
    /// Whether the window should have a title bar.
    title_bar: bool,
    /// Whether the window should always be on top of other windows.
    topmost: bool,
    /// Whether the window should accept files dropped on it.
    accept_files: bool,
    /// Whether the window should allow transparent rendering.
    transparent: bool,
    /// Whether the window should be resizable.
    resizable: bool,
    /// Whether the window should include a border.
    border: bool,
    /// Whether the window should start minimized.
    minimized: bool,
    /// Whether the window should start maximized.
    maximized: bool,
};

/// Creates a new window with the provided parameters.
pub fn createWindow(options: CreateWindowOptions) wind.Error!win32.HWND {
    const ex_style = win32.WINDOW_EX_STYLE{
        .TOPMOST = @intFromBool(options.topmost),
        .ACCEPTFILES = @intFromBool(options.accept_files),
        .TRANSPARENT = @intFromBool(options.transparent),
    };
    const style = win32.WINDOW_STYLE{
        .GROUP = @intFromBool(options.minimize_button),
        .TABSTOP = @intFromBool(options.maximize_button),
        .THICKFRAME = @intFromBool(options.resizable),
        .SYSMENU = @intFromBool(options.title_bar),
        .BORDER = @intFromBool(options.border),
        .MINIMIZE = @intFromBool(options.minimized),
        .MAXIMIZE = @intFromBool(options.maximized),
    };

    const title = std.unicode.utf8ToUtf16LeAllocZ(options.allocator, options.title) catch |err| switch (err) {
        error.OutOfMemory => return error.OutOfMemory,
        error.InvalidUtf8 => if (builtin.mode == .Debug) std.debug.panic("Invalid UTF-8 string passed to createWindow", .{}) else std.unicode.utf8ToUtf16LeStringLiteral("<invalid utf-8>"),
    };
    defer options.allocator.free(title);

    var x = win32.CW_USEDEFAULT;
    var y = win32.CW_USEDEFAULT;
    var width = win32.CW_USEDEFAULT;
    var height = win32.CW_USEDEFAULT;

    if (options.size) |size| {
        if (size[0] > std.math.maxInt(i32)) {
            width = std.math.maxInt(i32);
        } else {
            width = @intCast(size[0]);
        }

        if (size[1] > std.math.maxInt(i32)) {
            height = std.math.maxInt(i32);
        } else {
            height = @intCast(size[1]);
        }
    }

    if (options.position) |pos| {
        x = pos[0];
        y = pos[1];
    }

    const hwnd = win32.CreateWindowExW(
        ex_style,
        options.window_class_name,
        title,
        style,
        x,
        y,
        width,
        height,
        null,
        null,
        options.hinstance,
        null,
    );

    return hwnd orelse return error.OsError;
}

/// Destroys the provided window.
pub fn destroyWindow(hwnd: win32.HWND) void {
    const ret = win32.DestroyWindow(hwnd);

    if (builtin.mode == .Debug and ret == 0) {
        std.debug.panic("Failed to destroy window", .{});
    }
}

/// Sets the user data associated with the provided window.
pub fn setUserData(hwnd: win32.HWND, data: anytype) void {
    _ = win32.SetWindowLongPtrW(hwnd, win32.GWLP_USERDATA, @as(isize, @bitCast(@intFromPtr(data))));
}

/// Gets the user data associated with the provided window.
pub fn getUserData(comptime T: type, hwnd: win32.HWND) T {
    return @ptrFromInt(@as(usize, @bitCast(win32.GetWindowLongPtrW(hwnd, win32.GWLP_USERDATA))));
}

/// Registers hooks for raw input events to be sent to the provided window.
pub fn registerRawInputHooks(hwnd: win32.HWND) error{OsError}!void {
    var rids = [2]win32.RAWINPUTDEVICE{
        .{
            .dwFlags = win32.RIDEV_INPUTSINK,
            .hwndTarget = hwnd,
            .usUsage = win32.HID_USAGE_GENERIC_KEYBOARD,
            .usUsagePage = win32.HID_USAGE_PAGE_GENERIC,
        },
        .{
            .dwFlags = win32.RIDEV_INPUTSINK,
            .hwndTarget = hwnd,
            .usUsage = win32.HID_USAGE_GENERIC_MOUSE,
            .usUsagePage = win32.HID_USAGE_PAGE_GENERIC,
        },
    };

    if (win32.RegisterRawInputDevices(&rids, rids.len, @sizeOf(win32.RAWINPUTDEVICE)) == 0) {
        return error.OsError;
    }
}

/// Tracks the mouse leave event for the provided window.
pub fn trackMouseLeaveEvent(hwnd: win32.HWND) void {
    var event = win32.TRACKMOUSEEVENT{
        .cbSize = @sizeOf(win32.TRACKMOUSEEVENT),
        .dwFlags = win32.TME_LEAVE,
        .dwHoverTime = 0,
        .hwndTrack = hwnd,
    };

    const ret = win32.TrackMouseEvent(&event);

    if (builtin.mode == .Debug and ret == 0) {
        std.debug.panic("Failed to track mouse event", .{});
    }
}
