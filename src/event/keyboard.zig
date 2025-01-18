/// An enumeration of keyboard physical keys.
///
/// # Layout Independence
///
/// This type does not take the layout of the keyboard into account. It simply attempts to provide
/// a constistent mapping of the *physical location* of keys. For example, the `KeyCode.key_a`
/// tag will be the key labelled 'A' on a US QWERTY keyboard, but it will be the key
/// labelled 'Q' on a French AZERTY keyboard.
///
/// Use this type when the physical location of keys is more important than the character they
/// produce.
///
/// # Caveats
///
/// Some hardware likes to shuffle around the physical key positions (for example keyboards with
/// a custom hardware-implemented layout).
///
/// # References
///
/// This enumeration mostly follows the specification detailed in the [W3C UI Events] standard,
/// with some modifications to better fit the needs of the library.
///
/// [W3C UI Events]: https://w3c.github.io/uievents-code/#code-value-tables
pub const KeyCode = enum {
    //
    // WRITING SYSTEM KEYS
    //

    /// '`~' on a US keyboard.
    ///
    /// This is the `半角/全角/漢字` (hankaku/zenkaku/kanji) key on Japanese keyboards.
    backquote,
    /// `\|` on a US (101-key layout) keyboard, `#~` on a UK (102) keyboard. May be placed
    /// between `"` and `Enter` on 102-, 104- and 106- key keyboards.
    backslash,
    /// `[{` on a US keyboard.
    bracket_left,
    /// `]}` on a US keyboard.
    bracket_right,
    /// `,;` on a US keyboard.
    comma,
    /// `0)` on a US keyboard.
    digit0,
    /// `1!` on a US keyboard.
    digit1,
    /// `2@` on a US keyboard.
    digit2,
    /// `3#` on a US keyboard.
    digit3,
    /// `4$` on a US keyboard.
    digit4,
    /// `5%` on a US keyboard.
    digit5,
    /// `6^` on a US keyboard.
    digit6,
    /// `7&` on a US keyboard.
    digit7,
    /// `8*` on a US keyboard.
    digit8,
    /// `9(` on a US keyboard.
    digit9,
    /// `=+` on a US keyboard.
    equal,
    /// This key is located between the left `Shift` and `Z` keys on a US keyboard. It's labelled
    /// `\|` on a UK keyboard.
    intl_backslash,
    /// Located between the `/` and the right `Shift` keys. Labelled `\ろ` (ro) on a Japanese
    /// keyboard.
    intl_ro,
    /// Located between the `=` and `Backspace` keys. Labelled `¥` (yen) on a Japanese keyboard.
    /// `\/` on a Russian keyboard.
    intl_yen,
    /// `a` on a US keyboard.
    key_a,
    /// `b` on a US keyboard.
    key_b,
    /// `c` on a US keyboard.
    key_c,
    /// `d` on a US keyboard.
    key_d,
    /// `e` on a US keyboard.
    key_e,
    /// `f` on a US keyboard.
    key_f,
    /// `g` on a US keyboard.
    key_g,
    /// `h` on a US keyboard.
    key_h,
    /// `i` on a US keyboard.
    key_i,
    /// `j` on a US keyboard.
    key_j,
    /// `k` on a US keyboard.
    key_k,
    /// `l` on a US keyboard.
    key_l,
    /// `m` on a US keyboard.
    key_m,
    /// `n` on a US keyboard.
    key_n,
    /// `o` on a US keyboard.
    key_o,
    /// `p` on a US keyboard.
    key_p,
    /// `q` on a US keyboard.
    key_q,
    /// `r` on a US keyboard.
    key_r,
    /// `s` on a US keyboard.
    key_s,
    /// `t` on a US keyboard.
    key_t,
    /// `u` on a US keyboard.
    key_u,
    /// `v` on a US keyboard.
    key_v,
    /// `w` on a US keyboard.
    key_w,
    /// `x` on a US keyboard.
    key_x,
    /// `y` on a US keyboard.
    key_y,
    /// `z` on a US keyboard.
    key_z,
    /// `-_` on a US keyboard.
    minus,
    /// `'.>` on a US keyboard.
    period,
    /// `'"` on a US keyboard.
    quote,
    /// `;:` on a US keyboard.
    semicolon,
    /// `/?` on a US keyboard.
    slash,

    //
    // FUNCTIONAL KEYS
    //

    /// `Alt`, `Option` or `⌥`.
    alt_left,
    /// `Alt`, `Option` or `⌥`. This may be labelled `AltGr` on many keyboard layouts.
    alt_right,
    /// `Backspace` or `⌫`. Labeled `Delete` on Apple keyboards.
    backspace,
    /// `CapsLock` or `⇪`.
    caps_lock,
    /// The application context menu key which is typically found between the right `Meta` key and
    /// the right `Control` key.
    context_menu,
    /// `Control`, `Ctrl` or `⌃`.
    control_left,
    /// `Control`, `Ctrl` or `⌃`.
    control_right,
    /// `Enter` or `↵`. Labelled `Return` on Apple keyboards.
    enter,
    /// The Windows, `⌘`, `Command` or other OS specific key.
    meta_left,
    /// The Windows, `⌘`, `Command` or other OS specific key.
    meta_right,
    /// `Shift` or `⇧`.
    shift_left,
    /// `Shift` or `⇧`.
    shift_right,
    /// `Space` or `␣`.
    space,
    /// `Tab` or `⇥`.
    tab,
    /// Japanese `変換` (henkan).
    convert,
    /// Japanese `カタカナ/ひらがな/ローマ字` (katakana/hiragana/romaji)
    kana_mode,
    /// Korean: HangulMode `한/영` (han/yeong)
    /// Japanese (Mac keyboard): `かな` (kana)
    lang1,
    /// Korean: Hanja `한자` (hanja)
    /// Japanese (Mac keyboard): `英数` (eisu)
    lang2,
    /// Japanese (word-processing keyboard): Katakana
    lang3,
    /// Japanese (word-processing keyboard): Hiragana
    lang4,
    /// Japanese (word-processing keyboard): Zenkaku/Hankaku
    lang5,
    /// Japanese: `無変換` (muhenkan)
    non_convert,

    //
    // CONTROL PAD SECTION
    //

    /// The forward delete key, or `⌦`.
    ///
    /// Note that on Apple keyboards, the key labelled `Delete` on the main part of the keyboard
    /// should be encoded as "Backspace".
    delete,
    /// `End` or `↘`.
    end,
    /// `Help`. Not present on standard PC keyboards.
    help,
    /// `Home` or `↖`.
    home,
    /// `Insert` or `Ins`. Not present on Apple keyboards.
    insert,
    /// `PageDown` or `⇟`.
    page_down,
    /// `PageUp` or `⇞`.
    page_up,

    //
    // ARROW PAD SECTION
    //

    /// `↓`.
    arrow_down,
    /// `←`.
    arrow_left,
    /// `→`.
    arrow_right,
    /// `↑`.
    arrow_up,

    //
    // NUMPAD SECTION
    //

    /// `NumLock` or `⌕`.
    ///
    /// On Mac, this key is labeled `Clar`.
    num_lock,
    /// `0 Ins` on a keyboard, `0` on a phone or remote control.
    numpad0,
    /// `1 End` on a keyboard, `1` on a phone or remote control.
    numpad1,
    /// `2 ↓` on a keyboard, `2` on a phone or remote control.
    numpad2,
    /// `3 PgDn` on a keyboard, `3` on a phone or remote control.
    numpad3,
    /// `4 ←` on a keyboard, `4` on a phone or remote control.
    numpad4,
    /// `5` on a keyboard, `5` on a phone or remote control.
    numpad5,
    /// `6 →` on a keyboard, `6` on a phone or remote control.
    numpad6,
    /// `7 Home` on a keyboard, `7` on a phone or remote control.
    numpad7,
    /// `8 ↑` on a keyboard, `8` on a phone or remote control.
    numpad8,
    /// `9 PgUp` on a keyboard, `9` on a phone or remote control.
    numpad9,
    /// `+`
    numpad_add,
    /// Found on the Microsoft Natural Keyboard.
    numpad_backspace,
    /// `C` or `AC` (All Clear).
    numpad_clear,
    /// `CE` (Clear Entry).
    numpad_clear_entry,
    /// `,` (thousands separator). For locales where the thousands separator is `.` (e.g. Brazil),
    /// this key may generate a `.`.
    numpad_comma,
    /// `. del` (decimal separator). For locales where the decimal separator is `,` (e.g. Brazil),
    /// this key may generate a `,`.
    numpad_decimal,
    /// `/`.
    numpad_divide,
    /// `Enter` on the numpad.
    numpad_enter,
    /// `=`.
    numpad_equal,
    /// `#` on a phone or remote control. This ke is typically placed below the `9` key and to the
    /// right of the `0` key.
    numpad_hash,
    /// `M+` (Memory Add).
    numpad_memory_add,
    /// `MC` (Memory Clear).
    numpad_memory_clear,
    /// `MR` (Memory Recall).
    numpad_memory_recall,
    /// `MS` (Memory Store).
    numpad_memory_store,
    /// `M-` (Memory Subtract).
    numpad_memory_subtract,
    /// `*` on a keyboard. For use with numpads that provide *mathematical operations*. For the
    /// '*' key on phones or remote controls, use `numpad_star`.
    numpad_multiply,
    /// `(`, found on the Microsoft Natural Keyboard.
    numpad_paren_left,
    /// `)`, found on the Microsoft Natural Keyboard.
    numpad_paren_right,
    /// `*` on a phone or remote control. This key is typically placed below the `7` key and to
    /// the left of the `0` key.
    ///
    /// Use `numpad_multiply` for the '*' key on a keyboard.
    numpad_star,
    /// `-`.
    numpad_subtract,

    //
    // FUNCTION SECTION
    //

    /// `Esc` or `⎋`.
    escape,
    /// `F1`.
    f1,
    /// `F2`.
    f2,
    /// `F3`.
    f3,
    /// `F4`.
    f4,
    /// `F5`.
    f5,
    /// `F6`.
    f6,
    /// `F7`.
    f7,
    /// `F8`.
    f8,
    /// `F9`.
    f9,
    /// `F10`.
    f10,
    /// `F11`.
    f11,
    /// `F12`.
    f12,
    /// `F13`.
    f13,
    /// `F14`.
    f14,
    /// `F15`.
    f15,
    /// `F16`.
    f16,
    /// `F17`.
    f17,
    /// `F18`.
    f18,
    /// `F19`.
    f19,
    /// `F20`.
    f20,
    /// `F21`.
    f21,
    /// `F22`.
    f22,
    /// `F23`.
    f23,
    /// `F24`.
    f24,
    /// The `Fn` key. This is typically a hardware-only key that do not generate key events.
    fn_,
    /// `FnLock` or `FLock`. Function Lock key. Found on the Microsoft Natural Keyboard.
    fn_lock,
    /// `PrintScreen` or `PrtScr SysRq`. Sometimes called `Snapshot`.
    print_screen,
    /// `ScrollLock`.
    scroll_lock,
    /// `Pause Break`.
    pause,

    //
    // MEDIA KEYS
    //

    /// Some laptops place this key to the elft of the `↑` key.
    browser_back,
    browser_favorites,
    /// Some laptops place this key to the right of the `↑` key.
    browser_forward,
    browser_home,
    browser_refresh,
    browser_search,
    browser_stop,
    /// `Eject` or `⏏`. This key may be used to eject optical discs.
    eject,
    /// Sometimes labelled `My Computer` or `This PC`.
    launch_app1,
    /// Sometimes labelled `Calculator`.
    launch_app2,
    launch_mail,
    media_play_pause,
    media_select,
    media_stop,
    media_track_next,
    media_track_previous,
    /// Replaces the `Eject` key on some Apple keyboards.
    power,
    sleep,
    audio_volume_down,
    audio_volume_mute,
    audio_volume_up,
    wake_up,

    //
    // UNIDENTIFIED
    //

    /// The key could not be identified.
    unidentified,

    /// Returns the location of the key that generated this event.
    pub fn location(self: KeyCode) KeyLocation {
        return switch (self) {
            .numpad0,
            .numpad1,
            .numpad2,
            .numpad3,
            .numpad4,
            .numpad5,
            .numpad6,
            .numpad7,
            .numpad8,
            .numpad9,
            .numpad_add,
            .numpad_backspace,
            .numpad_clear,
            .numpad_clear_entry,
            .numpad_comma,
            .numpad_decimal,
            .numpad_divide,
            .numpad_enter,
            .numpad_equal,
            .numpad_hash,
            .numpad_memory_add,
            .numpad_memory_clear,
            .numpad_memory_recall,
            .numpad_memory_store,
            .numpad_memory_subtract,
            .numpad_multiply,
            .numpad_paren_left,
            .numpad_paren_right,
            .numpad_star,
            .numpad_subtract,
            => .numpad,
            .alt_left,
            .control_left,
            .meta_left,
            .shift_left,
            => .left,
            .alt_right,
            .control_right,
            .meta_right,
            .shift_right,
            => .right,
            else => .standard,
        };
    }
};

/// A possible location variant for a key.
pub const KeyLocation = enum {
    /// The key is in its standard location.
    standard,
    /// The key is on the "left side" of the keyboard.
    left,
    /// The key is on the "right side" of the keyboard.
    right,
    /// The key is on the "numpad" section of the keyboard.
    numpad,
};
