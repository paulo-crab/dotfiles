# Kanata keymap

This README describes the current [`kanata.kbd`](kanata.kbd): CAGS home-row
modifiers, Caps navigation, Space numbers/symbols, Swedish letters, the Microsoft keyboard
modifier swap, and Violento practice mode. It uses ANSI U.S. QWERTY positions.
Keep macOS’s input source set to **U.S.** for the Swedish shortcuts.

| Key | Tap | Hold |
| --- | --- | --- |
| A | A | Left Control ⎈ |
| S | S | Left Option ⎇ |
| D | D | Left Command ◆ |
| F | F | Left Shift |
| J | J | Right Shift |
| K | K | Right Command ◆ |
| L | L | Right Option ⎇ |
| ;, the key immediately right of L | ; / ö with either Option | Right Control ⎈ |
| Caps Lock | Escape | Navigation layer |
| Space | Space | Number/symbol layer after 220 ms |

Left to right, the home row is **C A G S · · S G A C**. G and H are ordinary
letters. CAGS means Control, Alt/Option, GUI/Command, Shift; see the
[CAGS explanation](https://precondition.github.io/home-row-mods#cags).

Use **Caps+;** for Forward Delete, **Caps+M** for Backspace, and **Caps+Space**
for Return. Caps+V/B/N retain the earlier versions of those actions.
Option+N and Option+V retain their normal macOS behavior, so
holding Option to type Swedish cannot trigger these editing keys.

## Violento practice mode

Hold the **physical Control + Alt/Option + Command/Windows** keys, tap **V**,
then release them to turn practice mode on. Use the same physical keys and V
to turn it off. On the Microsoft keyboard, press its physical Control, Alt,
and Windows keys; Kanata recognizes them even while their normal output is
disabled. V keeps its normal behavior without the full three-key chord.

While practice mode is on, the original physical **Shift, Control, Alt/Option,
and Command/Windows** keys are silent on both keyboards. The original
**Backspace, Forward Delete, Return, Escape, arrow keys, Home, End, Page Up,
Page Down, and number keys 1–0** are also silent. This blocks their shifted
symbols too. Use the CAGS home-row holds for modifiers; use Caps for navigation,
Return, Backspace, and Forward Delete. Hold Space for numbers and symbols.
The physical grave, minus, and equals keys remain available.
Tap Caps for Escape. Normal letters, Space, and Tab still work. The Swedish
letters remain available through the home-row S or L Option hold.

To check the mode, type a lowercase letter while holding physical Shift: it
should stay lowercase. Hold F or J instead to type a capital. Tapping physical
Backspace should do nothing; Caps+M or Caps+B should delete a character.
Caps+Space should insert Return.
The physical 1–0 keys should do nothing; hold Space and use the left-hand
WER/SDF/XCV/B numpad for 0–9.
The mode starts off whenever Kanata starts. A full service restart returns to
normal if you cannot use the toggle.

While holding **Caps Lock**, use
**H = Left, J = Down, K = Up, L = Right**. Release Caps to
return to typing. Your familiar **Right Command +
H/J/K/L** also navigates. Other Right Command shortcuts still work. Physical
Shift + navigation selects text.

## Hold Space for numbers and symbols

Tap **Space** normally for a space. Hold it for about **220 ms** for the
`numbers-symbols` layer. The held Space does not insert a space.

The left hand has a numpad, with the surrounding symbols following the
Miryoku Num-layer idea. The right-hand **J/K/L/;** keys retain
**Shift/Command/Option/Control** while Space is held. This fits a right-thumb
Space hold and adapts Miryoku's grid to staggered QWERTY keys:

```text
Physical keys     Q W E R T
Space held        [ 7 8 9 ]
Space + Shift     { & * ( }

Physical keys     A S D F G
Space held        ; 4 5 6 =
Space + Shift     : $ % ^ +

Physical keys     Z X C V B
Space held        ` 1 2 3 0
Space + Shift     ~ ! @ # )

Physical keys     Tab  key left of 1  1
Space held         .         -        \
Space + Shift      >         _        |
```

Because Space is the layer key rather than a spare thumb key, **0** is on B.
The decimal point is on Tab, minus on the key left of 1, and backslash on
physical 1 while Space is held. On an ISO MacBook, the key left of 1 is `§`;
the separate grave key near Z also sends minus in this layer. On an ANSI
keyboard, the grave key left of 1 sends minus. For shifted symbols, **hold Space first**,
then hold **J** for Shift for about 200 ms, then tap a left-hand key. For
example, **Space+J+X** types `!`, **Space+J+Q** types `{`, and **Space+J+G**
types `+`. Physical Shift also works if pressed after Space; in Violento mode,
use J because physical Shift is disabled. The layer assumes the macOS **U.S.**
input source. Tab keeps its normal tap/Homerow hold behavior when Space is not
held. The physical Control+Alt+Command+V shortcut still toggles Violento when
Space is not held. Caps remains the navigation key, with Escape on tap.

If a modifier is held *before* Space, Space keeps its normal shortcut,
including Command+Space, Control+Space, Option+Space, and Shift+Space.
To repeat spaces, quickly tap Space, then press and hold it again within
200 ms.

**Caps Lock + Space sends Return** on both keyboards. Hold Caps first, then
tap Space. Release Caps Lock to type spaces normally. Holding a modifier with
Caps+Space sends the modified Return, such as Shift+Return. Right Command +
Space keeps its usual Command+Space shortcut.

**Caps Lock + N sends Return** on both keyboards. Hold Caps Lock, tap N,
then release it to continue typing. This sends plain Return even with other
modifiers held. N types normally outside the Caps layer; Left and Right
Command + N retain their usual shortcuts.

## More navigation and editing

Hold Caps Lock and press these keys on either keyboard:

| Left home key with Caps held | Modifier |
| --- | --- |
| A | Control |
| S | Option |
| D | Command |
| F | Shift |

Hold Caps **before** a modifier key. These are direct modifiers while Caps is
held, so **Caps+S+L** moves to the next word, **Caps+F+L** selects one character,
and **Caps+S+F+L** selects the next word in apps using standard macOS text
shortcuts. **Caps+D+L** sends Command+Right, which moves to the end of the line
in standard macOS text fields. **Caps+A+L** sends Control+Right to an app.
Right Command+A/S/D/F retain their ordinary shortcuts.

| Key with Caps held | Sends | Action |
| --- | --- | --- |
| `,` | Forward Delete | Delete the next character |
| V | Forward Delete | Delete the next character |
| `;` | Forward Delete | Delete the next character; combines with modifiers |
| B | Backspace | Delete the previous character |
| W | Option + Right | Next word |
| 0 | Command + Left | Beginning of line |
| 4 or `$` (Shift + 4) | Command + Right | End of line |
| U | Page Up | Page up |
| O | Page Down | Page down |
| G | Command + Down | End of document |
| T | Command + Up | Beginning of document |
| N | Return | Enter |
| Space | Return | Enter; combines with modifiers |
| `[` | Escape | Escape |
| M | Backspace | Delete the previous character; combines with modifiers |
| X | Control + D | Your requested forward-delete shortcut |

H/J/K/L remain the arrow keys. Add Caps+F or physical Shift to arrows for
selection. Physical Shift also combines with W, 0, U/O, or G/T for selection
where the app supports it.
Both 4 and Shift+4 move to the end of the line without selecting, so `$`
has the same action as 4. These mappings require Caps navigation; Right Command
keeps its ordinary shortcuts on these keys.

## Hold Tab for Homerow

Tap **Tab** for normal Tab. Hold it for about **250 ms** to send
**Shift + Command + Space**, your Homerow activation shortcut, once.
Release Tab, then use Homerow's hints normally. Continuing to hold Tab
does not repeatedly activate Homerow.

This works on both keyboards. With a
modifier already held, Tab keeps its ordinary shortcut: Command+Tab,
Command+Shift+Tab, Shift+Tab, Control+Tab, and Option+Tab remain available.
An activated home-row modifier also preserves its Tab shortcut.

## Swedish letters and symbols with either Option

Hold **either Option key** for Swedish keys at their familiar Swedish keyboard
positions. Release it to type ordinary U.S. punctuation. There is no language
toggle; keep macOS’s input source set to **U.S.**.

| US key label | With either Option | With Option + Shift |
| --- | --- | --- |
| `[` (immediately right of P) | å | Å |
| `]` (immediately right of `[`) | ¨ (dead key) | ^ (dead key) |
| `;` (immediately right of L) | ö | Ö |
| `'` (immediately right of `;`) | ä | Ä |
| `\` (above Return) | `'` | `*` |
| `=` (immediately right of `-`) | ´ (dead key) | grave accent (\`) (dead key) |

Dead keys combine with the next letter after you release Option: for example,
Option+`=` then E types é; Option+Shift+`]` then E types ê. Press Space after
a dead key to insert its accent alone. The apostrophe and asterisk type
immediately.

For the Portuguese tilde, hold **both Option keys** and press `]` (the Swedish
¨/^ position), then release them and type A or O for ã or õ. Press Space
instead for a standalone tilde. On the Microsoft keyboard, use both physical
Windows keys if present; holding home-row S and L also supplies the two
Options, including in Violento. The native Option+N tilde dead key is also
available again. With both Options held, Shift does not change the `]` chord.
For the plain ASCII `~` used in paths, press Shift+the key left of 1.

On your MacBook, use physical **Left or Right Option**. On the Microsoft
keyboard, use **Left or Right Windows** (when present); Kanata maps them to
Option. In the CAGS configuration, holding **S or L** also provides Option;
hold it for about 200 ms before tapping the vowel key.
In Violento mode, use S or L for Option and F or J for Shift because the
physical modifier keys are silent. Activate each home-row hold before pressing
the Swedish symbol key.

The semicolon key still holds Right Control. Physical Shift or an activated
home-row F/J hold produces capitals. Caps navigation, held-Space numbers/symbols,
Caps+Space Return, Caps+N Return, and held Tab for Homerow remain
available.

Without Option, these keys keep their normal U.S. punctuation,
including `{`, `:`, and `"` with Shift. Other keys keep their usual behavior,
including their native macOS Option combinations outside the six Swedish
positions above. With either Option key, these positions produce Swedish
letters or symbols. Control and
Command combinations with them retain their ordinary shortcut events, including
Control+[ for Vim and Command+[ for browser/Finder Back. Control+Shift+S is
available to apps again.

## MacBook function row

Kanata maps the MacBook's bare F1–F12 keys to their printed actions:

| Keys | Action |
| --- | --- |
| F1 / F2 | Brightness down / up |
| F3 / F4 | Mission Control / Spotlight |
| F5 / F6 | Dictation / Do Not Disturb |
| F7 / F8 / F9 | Previous / play-pause / next |
| F10 / F11 / F12 | Mute / volume down / volume up |

The Microsoft keyboard's F1–F12 keys remain ordinary function keys. When
Kanata detects the MacBook's Fn key, Fn+F1–F12 also send ordinary function
keys. The explicit MacBook mapping works around Kanata 1.12 passing the top
row through as F1–F12 instead of the Apple media actions.

## Windows keyboard on your Mac

Your connected Microsoft keyboard gets these mappings:

| Physical key | macOS action |
| --- | --- |
| Left Alt | Left Command ⌘ |
| Right Alt / AltGr | Right Command ⌘ |
| Left Windows | Left Option ⌥ |
| Right Windows, if present | Right Option ⌥ |

Use **Alt+C** for Copy, **Alt+V** for Paste, and **Alt+Tab** to switch apps.
**Right Alt + H/J/K/L** navigates, because Right Alt now acts as Right
Command. For ordinary arrow navigation, use Caps Lock + H/J/K/L as above.

The swap is matched to your Microsoft keyboard. Connect it before starting
Kanata, and restart Kanata if you reconnect it while Kanata is running.

## Home-row shortcuts

For a home-row shortcut, use the modifier on the opposite hand from the other
key: hold **K**, then tap **C** to copy; hold **D**, then tap **L** for
Command+L. To type a capital H, hold **F**, then tap **H**.

Hold the modifier for about 200 ms before pressing the other key. A hold can
start immediately after typing another key. While the hold decision is pending,
pressing another key on the same hand still favors the letter. Holding a
modifier letter does not normally repeat it; quickly tap it, then
press and hold it again within 200 ms to request a repeating letter.

For a shortcut with multiple home-row modifiers, activate them one at a time:
hold the first for about 200 ms, then hold the second for about 200 ms, then
press the target key. For A + F + R to reload, hold A, wait, hold F, wait,
then tap R. Pressing several keys together may be treated as typing
by this conservative starter's protection rules.

This gives Vim-style movement across apps, including word, line, page, and
document motions on the Caps layer.

## Running through Homebrew on this Mac

Your Homebrew service uses the compatible Kanata build at:

- Config: `~/.config/kanata/kanata.kbd`
- Binary: `~/.config/kanata/bin/kanata`
- Navigation-only alternative: `~/.config/kanata/navigation-only.kbd`
- Saved service definition: `~/.config/kanata/homebrew-service.plist`

The main config path is a symlink to your dotfile at
`~/workspace/dotfiles/dotfiles/kanata/kanata.kbd`. Edit that target, or follow
the symlink when saving; replacing the symlink with a regular file would
disconnect the dotfile from the service. The service uses the `.kbd` extension.

The service is registered to start at boot. The updated config is saved.
Use **Control + Shift + R** to reload it in the running service, then release
the keys. If the running configuration
does not yet contain that reload shortcut, reload the service in Terminal:

```sh
sudo brew services restart kanata --file="$HOME/.config/kanata/homebrew-service.plist"
```

macOS requests your administrator password. The saved service definition
keeps Homebrew using your compatible build and allows the emergency exit
shortcut to stop remapping without restarting it immediately.

If macOS permissions need enabling, add the binary above in **System
Settings → Privacy & Security → Input Monitoring** and **Accessibility**.
Use the **+** button, then **Command+Shift+G** in the file picker to enter
`~/.config/kanata/bin/kanata`.

In **Karabiner-Elements → Devices**, turn off **Modify events** for keyboards
handled by Kanata. Keep Karabiner’s VirtualHID driver installed. Your old
Karabiner rules are saved and can be restored by re-enabling Modify events
after stopping Kanata. The Alt/Windows swap is handled by Kanata; Karabiner’s
additional Menu/Insert remaps pause while Modify events is off.

To start a stopped Homebrew service:

```sh
sudo brew services start kanata --file="$HOME/.config/kanata/homebrew-service.plist"
```

Release all keys during Kanata’s short startup delay.

**Stop immediately:** hold the **physical Left Control + Space + Escape**
keys together. Use the actual Escape key for this exit shortcut. This stops
remapping for this session. If Control or Escape is remapped by macOS or
keyboard firmware, use its actual input mapping for the exit shortcut.

To stop the service and disable automatic startup:

```sh
sudo brew services stop kanata
```

`start-kanata.command` remains available for a foreground trial after
stopping the Homebrew service. Keep its terminal open during the trial;
physical Control+C also stops that foreground process.

## Five-minute first exercise

1. Type a few sentences normally, including `after`, `fish`, `jazz`, and
   `a;jf`. They should behave as ordinary text.
2. Tap Caps Lock: it should act as Escape.
3. Hold Caps Lock and press H/J/K/L, then release it and type `hjkl`.
   Hold Caps, then A, then L to test Control+Right in an app that uses it.
   Caps+Space should send Return; Caps+M and Caps+; should delete backward
   and forward.
   Hold Space for about 220 ms, then tap W/E/R, S/D/F, X/C/V, and B:
   expect `7894561230`. Keep holding Space, hold J for about 200 ms, then tap
   X/C/V and Q/T: expect `!@#{}`. Tap Space normally between words.
4. On the Windows keyboard, hold Right Alt and press H/J/K/L. Try physical
   Shift with those arrows to select text. Both Alt+C shortcuts should copy.
   On a Mac keyboard, use Right Command for the same exercise.
5. Hold F for about 200 ms, tap H, then release F: expect capital H.
6. Hold either Option (either Windows key on the Microsoft keyboard), then tap
   `[`, `;`, and `'`: expect **åöä**. Add Shift: expect **ÅÖÄ**. Release
   Option and check that the same keys type ordinary U.S. punctuation.
7. Select harmless text, hold K for about 200 ms, tap C, and release
   K: expect Copy. Use your physical Command key for other shortcuts while
   getting comfortable.

If the home-row modifiers feel distracting, stop Kanata and use the
navigation-only alternative:

```sh
sudo brew services stop kanata
sudo "$HOME/.config/kanata/bin/kanata" --cfg "$HOME/.config/kanata/navigation-only.kbd"
```

This alternative also includes the Swedish letters. Stop the foreground trial
and start the Homebrew service with its saved definition to return to CAGS.

## Turn it up a little at a time

1. **Now:** practice CAGS and basic navigation. Start using D/K for Command
   and F/J for Shift, then practice A/; for Control and S/L for Option.
   Test any Option-based symbols you use.
2. **Next:** practice Caps with M/;/Space for editing, W for the next word,
   0/4 for lines, U/O for pages,
   and G/T for the document. Try held Space for numbers and symbols.
3. **Later:** tune timing per finger, add further selection and editing actions, and
   consider a persistent navigation mode.

Change one thing at a time so it is easy to tell what helped. After editing
the installed config, check it with:

```sh
"$HOME/.config/kanata/bin/kanata" --check --cfg "$HOME/.config/kanata/kanata.kbd"
```

Then press Control+Shift+R to reload. This folder contains the active CAGS
config through the symlink described above; future edits should update
`kanata.kbd` here. Backups are saved under
`~/.config/kanata/backups/`.

## Timing you can tune later

The first values in `defvar` are the ones to adjust:

- **hold-time = 200 ms:** time before a home-row modifier activates.
  If you trigger shortcuts by accident, raise this to 220 ms. Space remains 220 ms;
  Tab remains 250 ms.
- **typing-idle = 0 ms:** recent typing no longer forces a letter immediately.
  A deliberate hold works even directly after another keystroke. Same-hand
  key presses still favor a letter while the hold timer is pending.
- **tap-time = 200 ms:** window for tapping, then quickly holding the same
  key to repeat its normal letter.

The same-hand key lists also favor ordinary typing while a decision is
pending. Once a hold has already activated, shortcuts work with either
hand.

## Build and verification notes

The scenario counts below describe earlier revisions. The current Caps V/B/N
bindings and the previous right-hand Space layer were checked on the keyboard.
The left-hand Miryoku-style numpad and its shifted symbols were confirmed after
reloading. The ISO `§` key's Space-layer minus mapping was also confirmed.
After reloading, Caps+Space Return, Caps+M Backspace, Caps+; Forward Delete,
and Caps+A+L Control+Right were confirmed on the keyboard.

Your installed Karabiner VirtualHID package is **8.5.0** and uses client
protocol **7**. Stable Kanata **1.12.0** expects the older driver family, so
the installed binary was built from upstream revision
`a02d65b603cb74d7f4ae55e45f6138eb14e7950f` with
`karabiner-driverkit 0.4.0`, which uses protocol 7. Its reported version is
`1.12.1-prerelease-1`; this is a development build, not the stable release.
The existing driver and Karabiner configuration were kept intact.

Both configurations pass Kanata’s configuration check. All 82 existing CAGS
scenarios retain their previous output events. Another 300 focused checks
verify both configurations and both keyboard mappings: Swedish vowels and
capitals, ordinary U.S. symbols, Control/Command/Right Option shortcuts,
Caps navigation and editing, held Tab for Homerow, and removal of the language
toggle. Home-row S works for the vowel shortcuts in the CAGS config.
The vowel sequences were translated through macOS’s real U.S. keyboard
layout; every simulated scenario ends with all output keys released.
The extended Caps layer passes another 216 checks, covering every mapping,
Shift selection, the 4/$ equivalence, normal typing, Command shortcuts,
Caps+[ while Option is held, and releasing Caps before a held motion key.
The 382 existing Swedish and CAGS scenarios also retain their output events.
Earlier held-Space navigation checks covered taps, typing rolls, selection,
modifier+Space shortcuts, release order, and tap-then-hold repeat. Current
Space numbers/symbols and Caps navigation pass focused checks across both
keyboard mappings.
Violento mode passes 130 focused checks on both keyboard mappings, including
all disabled keys, the physical toggle with left and right modifiers, the
home-row and navigation replacements, and toggling back off. All 738 earlier
behavior checks still pass in normal mode.
Both Option keys now produce the Swedish letters and capitals in both
configurations. The main configuration passes 90 focused checks and 408
existing normal-mode scenarios; the navigation-only fallback passes 56
focused checks and 318 existing scenarios. The intentional changes are the
three Right Option letter positions.
Try the shortcuts in your usual apps after reloading.

References:

- [Kanata macOS setup](https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md)
- [Tap/hold behavior](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#tap-hold)
- [Prior-idle typing protection](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#tap-hold-require-prior-idle)
- [Keyboard-specific mappings](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#definputdevices)
