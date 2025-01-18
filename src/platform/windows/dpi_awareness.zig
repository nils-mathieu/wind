const win32 = @import("win32.zig");

/// Attempts to become DPI aware.
pub fn becomeDpiAware() error{OsError}!void {
    if (win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2) != 0) {
        return;
    }

    if (win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE) != 0) {
        return;
    }

    if (win32.SetProcessDpiAwareness(win32.PROCESS_DPI_AWARENESS.PER_MONITOR_DPI_AWARE) != 0) {
        return;
    }

    if (win32.SetProcessDPIAware() != 0) {
        return;
    }

    return error.OsError;
}
