/// The button of a mouse.
pub const PointerButton = enum(u8) {
    /// The primary mouse button.
    ///
    /// Usually, this will be the left button of the mouse, but some users will have swapped
    /// the buttons.
    primary = 0,

    /// The middle mouse button.
    ///
    /// This is usually the wheel button of the mouse.
    middle = 1,

    /// The secondary mouse button.
    ///
    /// Usually, this will be the right button of the mouse, but some users will have swapped
    /// the buttons.
    secondary = 2,

    /// The fourth mouse button. Usually the back button.
    backward = 3,

    /// The fifth mouse button. Usually the forward button.
    forward = 4,

    _,

    /// Turns an integer into a `MouseButton`.
    ///
    /// This is usually used to create a `MouseButton` from a raw button code. Note that values
    /// from `0` to `4` (inclusive) are already named in the enum.
    pub fn extra(button: u8) PointerButton {
        return @enumFromInt(button);
    }
};
