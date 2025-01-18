/// Represents the phase of a touch event.
pub const TouchPhase = enum {
    /// The touch event has started.
    started,
    /// The touch event has moved.
    moved,
    /// The touch event has ended.
    ended,
    /// The touch event has been cancelled.
    cancelled,
};
