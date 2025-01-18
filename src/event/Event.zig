const wind = @import("wind");

/// An event that can be posted to the event loop.
pub const Event = union(enum) {
    /// The first event that is posted to the event loop.
    ///
    /// This event indicates that the application has started running. During this event, new
    /// windows can be created, and the application is expected to initialize its state.
    ///
    /// It *guaranteed* that no other events will be posted before this one.
    created,

    /// The last event that is posted to the event loop.
    ///
    /// This event indicates that the event loop is done running.
    ///
    /// It is *guaranteed* that no other events will be posted after this one, and that this event
    /// will not be posted if `created` wasn't posted previously.
    destroyed,

    /// A window-specific event has been received by the event loop.
    window: Window,

    /// The event that is posted at the end of each iteration of the event loop, just before
    /// starting to wait for more events.
    end_of_iteration,

    /// An event that is posted for a specific window.
    pub const Window = struct {
        /// The unique ID of the window that this event is for.
        window_id: wind.Window.Id,

        /// The actual payload of the
        payload: union(enum) {
            /// The window has been requested to close itself.
            ///
            /// Note that actually closing the window right now is not mandatory. It is legal
            /// behavior to do nothing, or show a pop-up asking the user to confirm the action.
            ///
            /// In order to actual close the window, either `close` the window, or call `exit`
            /// on the event loop context.
            close_requested,

            /// The window has been requested to redraw its content.
            redraw_requested,

            /// Indicates that the size of the window's client area has changed.
            ///
            /// The associated value is the new size of the client area, measured in physical
            /// pixels (not taken into account any DPI scaling).
            resized: @Vector(2, u32),

            /// Indicates that the position of the window has changed.
            ///
            /// The associated value is the new position of the window, measured in physical
            /// pixels (not taken into account any DPI scaling).
            moved: @Vector(2, i32),

            /// Indicates that the scale factor of the window has changed (for example because the
            /// window was dragged to a monitor with a different DPI).
            ///
            /// The associated value is the new scale factor for this window.
            scale_factor_changed: f64,

            /// Indicates that the focus of the window has changed.
            ///
            /// The associated value is `true` if the window has gained focus, and `false` if it
            /// has lost focus.
            focus_changed: bool,

            /// Indicates that a cursor (or other pointing device) has entered or left the
            /// window's client area.
            cursor_hover: struct {
                /// The device ID of the cursor that has entered or left the client area, when
                /// the platform supports it.
                device_id: wind.DeviceId,

                /// Whether the cursor has entered the client area (`true`) or left it (`false`).
                hover: bool,
            },

            /// Indicates that a pointer (typically a cursor) has moved within the window's
            /// client area.
            pointer_moved: struct {
                /// The device ID of the pointer that has moved, when the platform supports it.
                device_id: wind.DeviceId,

                /// The new position of the pointer, measured in physical pixels (not taken into
                /// account any DPI scaling). This value is relative to the top left corner of the
                /// window's client area.
                ///
                /// The value is specified as a floating point value because some platforms
                /// support sub-pixel movement for pointing devices.
                position: @Vector(2, f64),

                /// Whether the device that generated the event is a primary pointing device.
                ///
                /// Primary pointing devices are typically mouses, or the first touch point on a
                /// touch screen.
                primary: bool,

                /// Additional information about the pointer that generated the event.
                info: union(enum) {
                    /// The pointer that generated the event is a mouse.
                    mouse,

                    /// The pointer comes from a touch.
                    touch: struct {
                        /// The associated value is a unique index of the finger that generated the
                        /// event.
                        ///
                        /// This can be used to track the movement of individual fingers on a touch
                        /// screen.
                        finger_id: wind.FingerId,

                        /// The force with which the finger is pressing the screen.
                        force: f64,

                        /// The touch phase of the event.
                        phase: wind.TouchPhase,
                    },

                    /// The pointer type is not recognized or is unknown.
                    unknown,
                },
            },

            /// A pointer (mouse-like) button has been pressed or released.
            pointer_button: struct {
                /// The device ID of the device that generated the event.
                device_id: wind.DeviceId,

                /// The button that was pressed or released.
                button: wind.PointerButton,

                /// Whether the button was pressed (`true`) or released (`false`).
                pressed: bool,

                /// Whether the device that generated the event is a primary pointing device.
                ///
                /// Primary pointing devices are typically mouses, or the first touch point on a
                /// touch screen.
                primary: bool,

                /// The type of the pointing device.
                pointer_type: union(enum) {
                    /// The pointer that generated the event is a mouse.
                    mouse,

                    /// The pointer comes from a touch.
                    touch: struct {
                        /// The associated value is a unique index of the finger that generated the
                        /// event.
                        ///
                        /// This can be used to track the movement of individual fingers on a touch
                        /// screen.
                        finger_id: wind.FingerId,

                        /// The force with which the finger is pressing the screen.
                        force: f64,
                    },

                    /// The pointer type is not recognized or is unknown.
                    unknown,
                },
            },

            /// Indicates that a wheel device has been used to scroll the window.
            wheel: struct {
                /// The device ID of the wheel that generated the event.
                device_id: wind.DeviceId,

                /// The amount of horizontal and vertical scrolling that was performed.
                ///
                /// The value is specified as a floating point value because some platforms
                /// support sub-pixel scrolling. The exact unique (and how the value should be
                /// interpreted) is specified by the `unit` field.
                ///
                /// # Meaning
                ///
                /// For the horizontal scroll amount, a positive value indicates scrolling to the
                /// right, and a negative value indicates scrolling to the left.
                ///
                /// For the vertical scroll amount, a positive value indicates scrolling downwards,
                /// and a negative value indicates scrolling upwards.
                amount: @Vector(2, f64),

                /// The unit of the scroll amount.
                unit: Unit,

                /// The phase of the scroll event.
                ///
                /// When the scroll event comes from a regular mouse wheel device, the phase
                /// is always `.moved`.
                phase: wind.TouchPhase,

                /// The possible unit value for the scroll amount.
                pub const Unit = enum {
                    /// The scroll amount is specified in lines.
                    lines,
                    /// The scroll amount is specified in pixels.
                    pixels,
                };
            },

            /// A keyboard event has been sent to the window.
            keyboard: struct {
                /// The device ID of the keyboard that generated the event.
                device_id: wind.DeviceId,

                /// The physical key code of the key that was pressed or released.
                ///
                /// # Usage
                ///
                /// This field should be used when the physical location of the key is more
                /// important than its actual meaning, such as when implementing controls for a
                /// 3D application, etc.
                ///
                /// # Caveats
                ///
                /// This is the physical key code, which is the code that the keyboard sends to
                /// the computer. This is not the same as the character that the key would
                /// generate when pressed. For example, pressing the "A" key on a US keyboard
                /// generates the same key code as pressing the "Q" key on a French keyboard.
                ///
                /// To get the character that the key would generate, use the `text` field.
                key_code: wind.KeyCode,

                /// The label of the key that generated this key event, if any. This takes
                /// keyboard modifiers (such as shift) into account.
                ///
                /// # Usage
                ///
                /// This field should be used when the meaning of the key is more important than
                /// its actual location of the keyboard, such as when specifying keyboard shortcuts,
                /// etc.
                ///
                /// # Caveats
                ///
                /// It's generally the text that would be typed if the key was pressed in a text
                /// field. Note that this should *not* be used to determine text typed by the
                /// user. Instead, use the `text_typed` event.
                ///
                /// This is because there is more than one way to type text, and using a keyboard
                /// is only one of them. For example, the user could use a virtual keyboard, or
                /// an accessibility tool that generates text.
                ///
                /// Additionally, this field may store "dead" characters, which are not actually
                /// supposed to be displayed, but are used to generate other characters.
                label: []const u8,

                /// Whether the key was pressed (`true`) or released (`false`).
                pressed: bool,
            },

            /// Indicates that text has been typed by the user in the window.
            text_typed: struct {
                /// The ID of the device that was used to type the text.
                device_id: wind.DeviceId,
                /// The input method event associated with this input.
                ime: wind.Ime,

                /// Returns the typed text from the associated input method event.
                pub inline fn typedText(self: @This()) []const u8 {
                    return self.ime.typedText();
                }
            },
        },
    };
};
