//! Re-exports the part of `zigwin32` we actually need.

pub const WINAPI = @import("std").os.windows.WINAPI;
pub usingnamespace @import("win32").zig;
pub usingnamespace @import("win32").ui.windows_and_messaging;
pub usingnamespace @import("win32").foundation;
pub usingnamespace @import("win32").system.library_loader;
pub usingnamespace @import("win32").ui.hi_dpi;
pub usingnamespace @import("win32").ui.input.keyboard_and_mouse;
pub usingnamespace @import("win32").ui.controls;
pub usingnamespace @import("win32").ui.input;
pub usingnamespace @import("win32").devices.human_interface_device;
