const wind = @import("wind");
const win32 = @import("win32.zig");

/// Runs the Windows message loop to completion.
pub fn runEventLoop(ctx: *wind.Context) wind.Error!void {
    var msg: win32.MSG = undefined;
    while (ctx.impl.shouldContinue()) {
        if (ctx.impl.block_when_no_events) {
            try getMessage(&msg);

            if (msg.message == win32.WM_QUIT) {
                break;
            }

            _ = win32.TranslateMessage(&msg);
            _ = win32.DispatchMessageW(&msg);
        }

        while (try peekAndRemoveMessage(&msg)) {
            if (msg.message == win32.WM_QUIT) {
                break;
            }

            _ = win32.TranslateMessage(&msg);
            _ = win32.DispatchMessageW(&msg);
        }

        ctx.impl.endOfIteration();
        ctx.impl.handler(ctx, wind.Event.end_of_iteration);
    }
}

/// Gets a message from the Windows message queue.
///
/// If no messages are currently available, this function will block until one is received.
fn getMessage(out: *win32.MSG) error{OsError}!void {
    return switch (win32.GetMessageW(out, null, 0, 0)) {
        -1 => error.OsError,
        else => {},
    };
}

/// Gets a message from the Windows message queue.
///
/// If no mesages are currently available, this function will return `false` immediately.
fn peekAndRemoveMessage(out: *win32.MSG) error{OsError}!bool {
    return switch (win32.PeekMessageW(out, null, 0, 0, win32.PM_REMOVE)) {
        -1 => error.OsError,
        0 => false,
        else => true,
    };
}
