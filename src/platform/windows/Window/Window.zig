const std = @import("std");
const win32 = @import("../win32.zig");
const wind = @import("wind");
const util = @import("utility.zig");

const Self = @This();

pub const State = @import("State.zig");
pub const Options = @import("Options.zig");

/// The `State` pointer allocated for this window.
state: *State,

//
// PUBLIC INTERFACE
//

/// The type used to uniquely identify a window on the system.
pub const Id = *opaque {
    pub fn format(self: *const @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len != 0) std.fmt.invalidFmtError(fmt, "Window.Id");
        try writer.print("0x{x}", .{@intFromPtr(self)});
    }
};

var next_window_class_id = std.atomic.Value(usize).init(0);

/// See `wind.Window.open`.
pub fn open(ctx: *wind.Context, options: *const wind.Window.Options) wind.Error!Self {
    const window_class_name = try util.getUniqueWindowClassName(ctx.impl.allocator);
    errdefer ctx.impl.allocator.free(window_class_name);

    //
    // Create the window class.
    //
    try util.registerWindowClass(.{
        .hinstance = ctx.impl.hinstance,
        .name = window_class_name,
        .wndproc = @import("window_procedure.zig").handleMessage,
        .h_redraw = options.platform_specific.request_redraw_on_horizontal_resize,
        .v_redraw = options.platform_specific.request_redraw_on_vertical_resize,
    });
    errdefer util.unregisterWindowClass(window_class_name, ctx.impl.hinstance);

    //
    // Create the window.
    //
    const hwnd = try util.createWindow(.{
        .accept_files = options.platform_specific.accept_files,
        .border = options.decorations,
        .title_bar = options.decorations,
        .title = options.title,
        .maximize_button = options.resizable and options.decorations,
        .minimize_button = options.decorations,
        .allocator = ctx.impl.allocator,
        .hinstance = ctx.impl.hinstance,
        .minimized = options.minimized,
        .maximized = options.maximized,
        .position = options.position,
        .size = if (options.size) |size| std.math.clamp(size, options.min_size, options.max_size) else null,
        .window_class_name = window_class_name,
        .topmost = options.always_on_top,
        .transparent = false,
        .resizable = options.resizable,
    });
    errdefer util.destroyWindow(hwnd);

    //
    // If this is the first window we're creating, we can hook into the raw input API. We have to
    // do that only once.
    //
    var has_raw_input_hooks = false;
    if (ctx.impl.use_raw_input and ctx.impl.windows.items.len == 0) {
        if (util.registerRawInputHooks(hwnd)) {
            has_raw_input_hooks = true;
        } else |_| {}
    }

    //
    // Allocate and initialize the state object.
    //
    const state = try ctx.impl.allocator.create(State);
    errdefer ctx.impl.allocator.destroy(state);
    state.* = State{
        .owner = ctx,
        .hwnd = hwnd,
        .window_class_name = window_class_name,
        .has_raw_input_hooks = has_raw_input_hooks,
        .has_focus = true,
        .max_size = options.max_size,
        .min_size = options.min_size,
    };

    //
    // Register the state object in places.
    //
    util.setUserData(hwnd, state);
    try ctx.impl.registerWindow(state);
    errdefer ctx.impl.unregisterWindow(state);

    //
    // Wrap up delayed states.
    //
    if (options.visible) {
        _ = win32.ShowWindow(hwnd, win32.SW_NORMAL);
    }

    return Self{ .state = state };
}

/// See `wind.Window.close`.
pub fn close(self: *Self) void {
    const ctx = self.state.owner;

    const had_raw_input_hooks = self.state.has_raw_input_hooks;

    ctx.impl.unregisterWindow(self.state);
    util.destroyWindow(self.state.hwnd);
    util.unregisterWindowClass(self.state.window_class_name, ctx.impl.hinstance);
    ctx.impl.allocator.free(self.state.window_class_name);
    ctx.impl.allocator.destroy(self.state);
    self.state = undefined;

    if (ctx.impl.use_raw_input and had_raw_input_hooks and ctx.impl.windows.items.len != 0) {
        // Register another window to receive raw input events.
        if (util.registerRawInputHooks(ctx.impl.windows.items[0].hwnd)) {
            ctx.impl.windows.items[0].has_raw_input_hooks = true;
        } else |_| {}
    }
}

// STATE GETTERS

/// See `wind.Window.getId`.
pub inline fn getId(self: *const Self) Id {
    return @ptrCast(self.state.hwnd);
}

/// See `wind.Window.hasFocus`.
pub inline fn hasFocus(self: *const Self) bool {
    return self.state.has_focus;
}
