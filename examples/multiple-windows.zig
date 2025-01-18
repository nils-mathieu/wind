const wind = @import("wind");
const std = @import("std");

const WindowMap = std.AutoHashMap(wind.Window.Id, wind.Window);
var windows: WindowMap = undefined;

fn handleEvent(ctx: *wind.Context, event: wind.Event) void {
    switch (event) {
        .created => {
            for (0..3) |x| {
                for (0..3) |y| {
                    const title = std.fmt.allocPrint(ctx.getAllocator(), "Window {}", .{x + y * 3 + 1}) catch @panic(":(");
                    defer ctx.getAllocator().free(title);
                    const window = wind.Window.open(ctx, .{
                        .title = title,
                        .size = .{ 250, 250 },
                        .position = .{ @intCast(300 + x * 250), @intCast(300 + y * 250) },
                    }) catch @panic(":(");
                    windows.put(window.getId(), window) catch @panic(":(");
                }
            }
        },
        .destroyed => {
            var iter = windows.valueIterator();
            while (iter.next()) |window| window.close();
            windows.deinit();
        },
        .window => |window_event| switch (window_event.payload) {
            .close_requested => {
                var kv = windows.fetchRemove(window_event.window_id).?;
                kv.value.close();
            },
            else => {},
        },
        else => {},
    }
}

pub fn main() wind.Error!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    windows = WindowMap.init(gpa.allocator());
    try wind.run(.{ .allocator = gpa.allocator() }, handleEvent);
}
