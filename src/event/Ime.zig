const std = @import("std");

/// A tagged enum representing an IME event that a window can receive.
pub const Ime = union(enum) {
    /// Indicates that the IME has been initiated by the user.
    ///
    /// After this event, `commit` and `pre_edit` events will be sent.
    enabled,
    /// Indicates that a new composing text should be set at the cursor position.
    pre_edit: PreEdit,
    /// Indicates that the composing text should be committed.
    ///
    /// When composing text is commit, an empty `pre_edit` is sent to clear the composing text.
    /// When outside of a composing text, the `commit` text is sent as is to indicate what
    /// the user has typed.
    commit: []const u8,
    /// Indicates that the IME has been disabled.
    ///
    /// No more `commit` or `pre_edit` events will be sent.
    disabled,

    /// The content of a `pre_edit` event.
    pub const PreEdit = struct {
        /// The text associated with the event.
        ///
        /// When empty, indicates that the pre-edit text should be cleared.
        text: []const u8,

        /// The cursor range where the pre-edit text takes place. This is a byte-wise range
        /// relative to the `text` field.
        ///
        /// When the range is empty, the cursor should not be displayed.
        cursor: [2]usize,

        /// An empty pre-edit event.
        pub const empty: PreEdit = .{ .text = &.{}, .cursor = .{ 0, 0 } };
    };

    /// Returns the text that the user has typed, or an empty string if no text has been typed.
    pub fn typedText(self: Ime) []const u8 {
        switch (self) {
            .commit => |text| return text,
            else => return &.{},
        }
    }
};

test "typedText" {
    const ime_commit = Ime{ .commit = "Hello, world!" };
    try std.testing.expectEqualStrings("Hello, world!", ime_commit.typedText());

    const ime_pre_edit = Ime{ .pre_edit = Ime.PreEdit{ .text = "Hello, world!", .cursor = .{ 0, 0 } } };
    try std.testing.expectEqualStrings("", ime_pre_edit.typedText());

    const ime_disabled: Ime = .disabled;
    try std.testing.expectEqualStrings("", ime_disabled.typedText());

    const ime_enabled: Ime = .enabled;
    try std.testing.expectEqualStrings("", ime_enabled.typedText());
}
