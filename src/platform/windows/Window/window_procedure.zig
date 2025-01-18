//! Defines the window procedure for the window.

const State = @import("State.zig");
const win32 = @import("../win32.zig");
const util = @import("utility.zig");
const std = @import("std");
const wind = @import("wind");
const builtin = @import("builtin");

/// The window procedure that will be used for the windows managed by the `wind` library.
pub fn handleMessage(
    hwnd: win32.HWND,
    msg: u32,
    wparam: win32.WPARAM,
    lparam: win32.LPARAM,
) callconv(win32.WINAPI) win32.LRESULT {
    const state = util.getUserData(?*State, hwnd) orelse return win32.DefWindowProcW(hwnd, msg, wparam, lparam);
    const window_id: wind.Window.Id = @ptrCast(hwnd);

    switch (msg) {
        win32.WM_CLOSE => {
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .close_requested,
            } });
            return 0;
        },
        win32.WM_PAINT => {
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .redraw_requested,
            } });
            return win32.DefWindowProcW(hwnd, msg, wparam, lparam);
        },
        win32.WM_GETMINMAXINFO => {
            const minmaxinfo: *win32.MINMAXINFO = @ptrFromInt(@as(usize, @bitCast(lparam)));
            if (minmaxinfo.ptMinTrackSize.x < 0 or @as(u32, @intCast(minmaxinfo.ptMinTrackSize.x)) < state.min_size[0]) {
                minmaxinfo.ptMinTrackSize.x = std.math.lossyCast(i32, state.min_size[0]);
            }
            if (minmaxinfo.ptMinTrackSize.y < 0 or @as(u32, @intCast(minmaxinfo.ptMinTrackSize.y)) < state.min_size[1]) {
                minmaxinfo.ptMinTrackSize.y = std.math.lossyCast(i32, state.min_size[1]);
            }
            if (minmaxinfo.ptMaxTrackSize.x > 0 and @as(u32, @intCast(minmaxinfo.ptMaxTrackSize.x)) > state.max_size[0]) {
                minmaxinfo.ptMaxTrackSize.x = std.math.lossyCast(i32, state.max_size[0]);
            }
            if (minmaxinfo.ptMaxTrackSize.y > 0 and @as(u32, @intCast(minmaxinfo.ptMaxTrackSize.y)) > state.max_size[1]) {
                minmaxinfo.ptMaxTrackSize.y = std.math.lossyCast(i32, state.max_size[1]);
            }
            return 0;
        },
        win32.WM_SIZE => {
            const width = win32.loword(lparam);
            const height = win32.hiword(lparam);
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .resized = .{ width, height } },
            } });
            return 0;
        },
        win32.WM_MOVE => {
            const x: i16 = @bitCast(win32.loword(lparam));
            const y: i16 = @bitCast(win32.hiword(lparam));
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .moved = .{ x, y } },
            } });
            return 0;
        },
        win32.WM_DPICHANGED => {
            const dpi_x = win32.loword(wparam);
            // const dpi_y = win32.hiword(wparam);
            const scale_factor = @as(f64, @floatFromInt(dpi_x)) / 96.0;
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .scale_factor_changed = scale_factor },
            } });
            return 0;
        },
        win32.WM_SETFOCUS => {
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .focus_changed = true },
            } });
            return 0;
        },
        win32.WM_KILLFOCUS => {
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .focus_changed = false },
            } });
            return 0;
        },
        win32.WM_MOUSEMOVE => {
            if (!state.cursor_hover) {
                state.cursor_hover = true;
                state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                    .window_id = window_id,
                    .payload = .{ .cursor_hover = .{
                        .device_id = null,
                        .hover = true,
                    } },
                } });

                util.trackMouseLeaveEvent(hwnd);
            }

            const x: i16 = @bitCast(win32.loword(lparam));
            const y: i16 = @bitCast(win32.hiword(lparam));
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .pointer_moved = .{
                    .device_id = null,
                    .primary = true,
                    .info = .mouse,
                    .position = .{ @floatFromInt(x), @floatFromInt(y) },
                } },
            } });
            return 0;
        },
        win32.WM_MOUSELEAVE => {
            state.cursor_hover = false;
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .cursor_hover = .{
                    .device_id = null,
                    .hover = false,
                } },
            } });
            return 0;
        },
        win32.WM_LBUTTONDOWN, win32.WM_LBUTTONUP => {
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .pointer_button = .{
                    .device_id = null,
                    .button = .primary,
                    .pointer_type = .mouse,
                    .primary = true,
                    .pressed = msg == win32.WM_LBUTTONDOWN,
                } },
            } });
            return 0;
        },
        win32.WM_MBUTTONDOWN, win32.WM_MBUTTONUP => {
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .pointer_button = .{
                    .device_id = null,
                    .button = .middle,
                    .primary = true,
                    .pointer_type = .mouse,
                    .pressed = msg == win32.WM_MBUTTONDOWN,
                } },
            } });
            return 0;
        },
        win32.WM_RBUTTONDOWN, win32.WM_RBUTTONUP => {
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .pointer_button = .{
                    .device_id = null,
                    .button = .secondary,
                    .primary = true,
                    .pointer_type = .mouse,
                    .pressed = msg == win32.WM_RBUTTONDOWN,
                } },
            } });
            return 0;
        },
        win32.WM_XBUTTONDOWN, win32.WM_XBUTTONUP => {
            const num = win32.hiword(wparam);
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .pointer_button = .{
                    .device_id = null,
                    .button = switch (num) {
                        0 => wind.PointerButton.extra(5),
                        1 => wind.PointerButton.backward,
                        2 => wind.PointerButton.forward,
                        else => wind.PointerButton.extra(@truncate(3 + @as(u32, num))),
                    },
                    .pointer_type = .mouse,
                    .primary = true,
                    .pressed = msg == win32.WM_XBUTTONDOWN,
                } },
            } });
            return 0;
        },
        win32.WM_MOUSEWHEEL => {
            const delta: i16 = @bitCast(win32.hiword(wparam));
            state.owner.impl.handler(state.owner, wind.Event{
                .window = .{
                    .window_id = window_id,
                    .payload = .{ .wheel = .{
                        .device_id = null,
                        .amount = .{ 0.0, @as(f64, @floatFromInt(delta)) / 120.0 },
                        .unit = .lines,
                        .phase = .moved,
                    } },
                },
            });
            return 0;
        },
        win32.WM_MOUSEHWHEEL => {
            const delta: i16 = @bitCast(win32.hiword(wparam));
            state.owner.impl.handler(state.owner, wind.Event{ .window = .{
                .window_id = window_id,
                .payload = .{ .wheel = .{
                    .device_id = null,
                    .amount = .{ -@as(f64, @floatFromInt(delta)) / 120.0, 0.0 },
                    .unit = .lines,
                    .phase = .moved,
                } },
            } });
            return 0;
        },
        win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP => {
            const key_flags = win32.hiword(lparam);
            var scan_code = key_flags & 0xFF;
            if (key_flags & win32.KF_EXTENDED != 0) scan_code |= 0xE000;
            state.takeKeyEvent(.{
                .pressed = (key_flags & win32.KF_UP) == 0,
                .key_code = scancodeToKeycode(scan_code),
            });
            return 0;
        },
        win32.WM_CHAR, win32.WM_SYSCHAR, win32.WM_SYSDEADCHAR, win32.WM_DEADCHAR => {
            state.takeUtf16(@truncate(wparam));
            return 0;
        },
        else => return win32.DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}

/// Computes the make code associated with the provided key code.
fn scancodeToKeycode(scancode: u16) wind.KeyCode {
    // Shamelessly stolen from https://github.com/rust-windowing/winit/blob/e3fbfb81d7993e88b2b69b273dad583d21bb5ea1/src/platform_impl/windows/keyboard.rs#L1086-L1243
    //
    // They reference the following links:
    // - https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
    // - https://www.w3.org/TR/uievents-code/
    // - widget/NativeKeyToDOMCodeName.h from Firefox's source code

    return switch (scancode) {
        0x0029 => wind.KeyCode.backquote,
        0x002b => wind.KeyCode.backslash,
        0x000e => wind.KeyCode.backspace,
        0x001a => wind.KeyCode.bracket_left,
        0x001b => wind.KeyCode.bracket_right,
        0x0033 => wind.KeyCode.comma,
        0x000b => wind.KeyCode.digit0,
        0x0002 => wind.KeyCode.digit1,
        0x0003 => wind.KeyCode.digit2,
        0x0004 => wind.KeyCode.digit3,
        0x0005 => wind.KeyCode.digit4,
        0x0006 => wind.KeyCode.digit5,
        0x0007 => wind.KeyCode.digit6,
        0x0008 => wind.KeyCode.digit7,
        0x0009 => wind.KeyCode.digit8,
        0x000a => wind.KeyCode.digit9,
        0x000d => wind.KeyCode.equal,
        0x0056 => wind.KeyCode.intl_backslash,
        0x0073 => wind.KeyCode.intl_ro,
        0x007d => wind.KeyCode.intl_yen,
        0x001e => wind.KeyCode.key_a,
        0x0030 => wind.KeyCode.key_b,
        0x002e => wind.KeyCode.key_c,
        0x0020 => wind.KeyCode.key_d,
        0x0012 => wind.KeyCode.key_e,
        0x0021 => wind.KeyCode.key_f,
        0x0022 => wind.KeyCode.key_g,
        0x0023 => wind.KeyCode.key_h,
        0x0017 => wind.KeyCode.key_i,
        0x0024 => wind.KeyCode.key_j,
        0x0025 => wind.KeyCode.key_k,
        0x0026 => wind.KeyCode.key_l,
        0x0032 => wind.KeyCode.key_m,
        0x0031 => wind.KeyCode.key_n,
        0x0018 => wind.KeyCode.key_o,
        0x0019 => wind.KeyCode.key_p,
        0x0010 => wind.KeyCode.key_q,
        0x0013 => wind.KeyCode.key_r,
        0x001f => wind.KeyCode.key_s,
        0x0014 => wind.KeyCode.key_t,
        0x0016 => wind.KeyCode.key_u,
        0x002f => wind.KeyCode.key_v,
        0x0011 => wind.KeyCode.key_w,
        0x002d => wind.KeyCode.key_x,
        0x0015 => wind.KeyCode.key_y,
        0x002c => wind.KeyCode.key_z,
        0x000c => wind.KeyCode.minus,
        0x0034 => wind.KeyCode.period,
        0x0028 => wind.KeyCode.quote,
        0x0027 => wind.KeyCode.semicolon,
        0x0035 => wind.KeyCode.slash,
        0x0038 => wind.KeyCode.alt_left,
        0xe038 => wind.KeyCode.alt_right,
        0x003a => wind.KeyCode.caps_lock,
        0xe05d => wind.KeyCode.context_menu,
        0x001d => wind.KeyCode.control_left,
        0xe01d => wind.KeyCode.control_right,
        0x001c => wind.KeyCode.enter,
        0xe05b => wind.KeyCode.meta_left,
        0xe05c => wind.KeyCode.meta_right,
        0x002a => wind.KeyCode.shift_left,
        0x0036 => wind.KeyCode.shift_right,
        0x0039 => wind.KeyCode.space,
        0x000f => wind.KeyCode.tab,
        0x0079 => wind.KeyCode.convert,
        0x0072 => wind.KeyCode.lang1, // for non-Korean layout
        0xe0f2 => wind.KeyCode.lang1, // for Korean layout
        0x0071 => wind.KeyCode.lang2, // for non-Korean layout
        0xe0f1 => wind.KeyCode.lang2, // for Korean layout
        0x0070 => wind.KeyCode.kana_mode,
        0x007b => wind.KeyCode.non_convert,
        0xe053 => wind.KeyCode.delete,
        0xe04f => wind.KeyCode.end,
        0xe047 => wind.KeyCode.home,
        0xe052 => wind.KeyCode.insert,
        0xe051 => wind.KeyCode.page_down,
        0xe049 => wind.KeyCode.page_up,
        0xe050 => wind.KeyCode.arrow_down,
        0xe04b => wind.KeyCode.arrow_left,
        0xe04d => wind.KeyCode.arrow_right,
        0xe048 => wind.KeyCode.arrow_up,
        0xe045 => wind.KeyCode.num_lock,
        0x0052 => wind.KeyCode.numpad0,
        0x004f => wind.KeyCode.numpad1,
        0x0050 => wind.KeyCode.numpad2,
        0x0051 => wind.KeyCode.numpad3,
        0x004b => wind.KeyCode.numpad4,
        0x004c => wind.KeyCode.numpad5,
        0x004d => wind.KeyCode.numpad6,
        0x0047 => wind.KeyCode.numpad7,
        0x0048 => wind.KeyCode.numpad8,
        0x0049 => wind.KeyCode.numpad9,
        0x004e => wind.KeyCode.numpad_add,
        0x007e => wind.KeyCode.numpad_comma,
        0x0053 => wind.KeyCode.numpad_decimal,
        0xe035 => wind.KeyCode.numpad_divide,
        0xe01c => wind.KeyCode.numpad_enter,
        0x0059 => wind.KeyCode.numpad_equal,
        0x0037 => wind.KeyCode.numpad_multiply,
        0x004a => wind.KeyCode.numpad_subtract,
        0x0001 => wind.KeyCode.escape,
        0x003b => wind.KeyCode.f1,
        0x003c => wind.KeyCode.f2,
        0x003d => wind.KeyCode.f3,
        0x003e => wind.KeyCode.f4,
        0x003f => wind.KeyCode.f5,
        0x0040 => wind.KeyCode.f6,
        0x0041 => wind.KeyCode.f7,
        0x0042 => wind.KeyCode.f8,
        0x0043 => wind.KeyCode.f9,
        0x0044 => wind.KeyCode.f10,
        0x0057 => wind.KeyCode.f11,
        0x0058 => wind.KeyCode.f12,
        0x0064 => wind.KeyCode.f13,
        0x0065 => wind.KeyCode.f14,
        0x0066 => wind.KeyCode.f15,
        0x0067 => wind.KeyCode.f16,
        0x0068 => wind.KeyCode.f17,
        0x0069 => wind.KeyCode.f18,
        0x006a => wind.KeyCode.f19,
        0x006b => wind.KeyCode.f20,
        0x006c => wind.KeyCode.f21,
        0x006d => wind.KeyCode.f22,
        0x006e => wind.KeyCode.f23,
        0x0076 => wind.KeyCode.f24,
        0xe037 => wind.KeyCode.print_screen,
        0x0054 => wind.KeyCode.print_screen, // Alt + PrintScreen
        0x0046 => wind.KeyCode.scroll_lock,
        0x0045 => wind.KeyCode.pause,
        0xe046 => wind.KeyCode.pause, // Ctrl + Pause
        0xe06a => wind.KeyCode.browser_back,
        0xe066 => wind.KeyCode.browser_favorites,
        0xe069 => wind.KeyCode.browser_forward,
        0xe032 => wind.KeyCode.browser_home,
        0xe067 => wind.KeyCode.browser_refresh,
        0xe065 => wind.KeyCode.browser_search,
        0xe068 => wind.KeyCode.browser_stop,
        0xe06b => wind.KeyCode.launch_app1,
        0xe021 => wind.KeyCode.launch_app2,
        0xe06c => wind.KeyCode.launch_mail,
        0xe022 => wind.KeyCode.media_play_pause,
        0xe06d => wind.KeyCode.media_select,
        0xe024 => wind.KeyCode.media_stop,
        0xe019 => wind.KeyCode.media_track_next,
        0xe010 => wind.KeyCode.media_track_previous,
        0xe05e => wind.KeyCode.power,
        0xe02e => wind.KeyCode.audio_volume_down,
        0xe020 => wind.KeyCode.audio_volume_mute,
        0xe030 => wind.KeyCode.audio_volume_up,
        else => wind.KeyCode.unidentified,
    };
}
