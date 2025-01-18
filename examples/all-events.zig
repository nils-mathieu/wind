const std = @import("std");
const wind = @import("wind");
const builtin = @import("builtin");

pub const std_options: std.Options = .{
    .log_level = .info,
};

var window: wind.Window = undefined;

fn handleEvent(ctx: *wind.Context, event: wind.Event) void {
    switch (event) {
        .created => {
            window = wind.Window.open(ctx, .{ .size = .{ 400, 300 } }) catch @panic(":(");
        },
        .destroyed => {
            window.close();
        },
        .window => |window_event| switch (window_event.payload) {
            .close_requested => ctx.exit(),
            .resized => |size| std.log.info("resized ({}x{})", .{ size[0], size[1] }),
            .moved => |pos| std.log.info("moved ({}, {})", .{ pos[0], pos[1] }),
            .redraw_requested => std.log.debug("redraw_requested", .{}),
            .scale_factor_changed => |scale_factor| std.log.info("scale_factor_changed ({d})", .{scale_factor}),
            .focus_changed => |has_focus| std.log.info("focus_changed ({})", .{has_focus}),
            .cursor_hover => |ev| std.log.info("cursor_hover ({})", .{ev.hover}),
            .pointer_moved => |ev| std.log.debug("cursor_moved ({d}, {d})", .{ ev.position[0], ev.position[1] }),
            .keyboard => |ev| if (ev.pressed) std.log.info("keyboard (pressed {s})", .{@tagName(ev.key_code)}) else std.log.debug("keyboard (released {s})", .{@tagName(ev.key_code)}),
            .text_typed => |ev| std.log.info("text_input ({s})", .{ev.typedText()}),
            .pointer_button => |ev| if (ev.pressed) std.log.info("mouse_button (pressed {s})", .{@tagName(ev.button)}) else std.log.debug("mouse_button (released {s})", .{@tagName(ev.button)}),
            .wheel => |ev| std.log.info("wheel ({d}, {d})", .{ ev.amount[0], ev.amount[1] }),
        },
        else => {},
    }
}

pub fn main() wind.Error!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    try wind.run(
        .{
            .allocator = gpa.allocator(),
            .platform_specific = switch (builtin.os.tag) {
                .windows => .{ .raw_input = true },
                else => .{},
            },
        },
        handleEvent,
    );
}
