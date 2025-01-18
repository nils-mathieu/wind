const std = @import("std");
const wind = @import("wind");

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
            else => {},
        },
        else => {},
    }
}

pub fn main() wind.Error!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    try wind.run(.{ .allocator = gpa.allocator() }, handleEvent);
}
