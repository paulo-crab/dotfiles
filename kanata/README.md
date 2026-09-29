# Your first Kanata setup

This is the level 0 navigation setup with your requested CAGS home-row order,
plus the modifier swap for your Windows keyboard and Swedish letters. The
config uses ANSI US QWERTY key positions. Keep macOS’s input source set to
**U.S.** so the Swedish shortcuts produce the correct characters.

| Key | Tap | Hold |
| --- | --- | --- |
| A | A | Left Control ⎈ |
| S | S | Left Option ⎇ |
| D | D | Left Command ◆ |
| F | F | Left Shift |
| J | J | Right Shift |
| K | K | Right Command ◆ |
| L | L | Right Option ⎇ |
| ;, the key immediately right of L | ; / ö with Left Option | Right Control ⎈ |
| Caps Lock | Escape | Navigation layer |

Left to right, the home row is **C A G S · · S G A C**. G and H are ordinary
letters. CAGS means Control, Alt/Option, GUI/Command, Shift; see the
[CAGS explanation](https://precondition.github.io/home-row-mods#cags).

While holding **Caps Lock**, use **H = Left, J = Down, K = Up, L = Right**.
Release Caps Lock to return to typing. Your familiar **Right Command +
H/J/K/L** also navigates. Other Right Command shortcuts still work. Physical
Shift + navigation selects text.

**Caps Lock + Space sends Backspace** on both keyboards. Tap Space to
delete one character or keep it held to repeat. Release Caps Lock to type
spaces normally. This sends plain Backspace even with other modifiers held;
Right Command + Space keeps its usual Command+Space shortcut.

**Caps Lock + N sends Return** on both keyboards.
Hold Caps Lock, tap N, then release Caps Lock to continue typing. This sends
plain Return even with other modifiers held. N types normally outside the
Caps layer; Left and Right Command + N retain their usual shortcuts.

## More Caps navigation and editing

Hold Caps Lock and press these keys on either keyboard:

| Key with Caps held | Sends | Action |
| --- | --- | --- |
| `,` | Forward Delete | Delete the next character |
| B | Option + Left | Previous word |
| W | Option + Right | Next word |
| 0 | Command + Left | Beginning of line |
| 4 or `$` (Shift + 4) | Command + Right | End of line |
| U | Page Up | Page up |
| D | Page Down | Page down |
| G | Command + Down | End of document |
| T | Command + Up | Beginning of document |
| N | Return | Enter |
| `[` | Escape | Escape |
| M | Backspace | Delete the previous character |
| X | Control + D | Your requested forward-delete shortcut |

Caps+Space is also Backspace. H/J/K/L remain the arrow keys. Add physical
Shift to B/W, 0, U/D, or G/T for selection where the app supports it.
Both 4 and Shift+4 move to the end of the line without selecting, so `$`
has the same action as 4. The new mappings require Caps; Right Command
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

## Swedish letters with Left Option

Hold **Left Option** for Swedish letters at their familiar Swedish keyboard
positions. Release it to type ordinary U.S. punctuation. There is no language
toggle; keep macOS’s input source set to **U.S.**.

| US key label | With Left Option | With Left Option + Shift |
| --- | --- | --- |
| `[` (immediately right of P) | å | Å |
| `;` (immediately right of L) | ö | Ö |
| `'` (immediately right of `;`) | ä | Ä |

On your MacBook, use the physical **Left Option** key. On your Microsoft
keyboard, use **Left Windows**, which Kanata maps to Left Option. In the
CAGS configuration, holding **S** also provides Left Option; pause first,
then hold S for about 220 ms before tapping the vowel key.

The semicolon key still holds Right Control. Physical Shift or an activated
home-row F/J hold produces capitals. Caps navigation, Caps+Space Backspace,
Caps+N Return, and held Tab for Homerow remain available.

Without Left Option, `[`, `;`, and `'` keep their normal U.S. punctuation,
including `{`, `:`, and `"` with Shift. Other keys keep their usual behavior,
including their native macOS Option combinations. These three Left Option
combinations now produce Swedish letters. Control, Command, and Right Option
combinations with them retain their ordinary shortcut events, including
Control+[ for Vim and Command+[ for browser/Finder Back. Control+Shift+S is
available to apps again.

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

Pause briefly before starting a home-row shortcut, and hold the modifier for
about a quarter of a second before pressing the other key. During quick
typing, the config favors letters. In this starter, holding one of the eight
modifier letters does not normally repeat that letter; quickly tap it, then
press and hold it again within 200 ms to request a repeating letter.

For a shortcut with multiple home-row modifiers, activate them one at a time:
hold the first for about 220 ms, then hold the second for about 220 ms, then
press the target key. Pressing several keys together may be treated as typing
by this conservative starter's protection rules.

This gives Vim-style movement across apps, including word, line, page, and
document motions on the Caps layer.

## Running through Homebrew on this Mac

Your Homebrew service uses the compatible Kanata build at:

- Config: `~/.config/kanata/kanata.kbd`
- Binary: `~/.config/kanata/bin/kanata`
- Navigation-only alternative: `~/.config/kanata/navigation-only.kbd`
- Saved service definition: `~/.config/kanata/homebrew-service.plist`

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
4. On the Windows keyboard, hold Right Alt and press H/J/K/L. Try physical
   Shift with those arrows to select text. Both Alt+C shortcuts should copy.
   On a Mac keyboard, use Right Command for the same exercise.
5. Pause, hold F for about 220 ms, tap H, then release F: expect capital H.
6. Hold Left Option (Left Windows on the Microsoft keyboard), then tap
   `[`, `;`, and `'`: expect **åöä**. Add Shift: expect **ÅÖÄ**. Release
   Option and check that the same keys type ordinary U.S. punctuation.
7. Select harmless text, pause, hold K for about 220 ms, tap C, and release
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
2. **Next:** practice Caps+B/W for words, 0/4 for lines, U/D for pages,
   and G/T for the document. Try Shift with the selection motions.
3. **Later:** tune timing per finger, add further selection and editing actions, and
   consider a persistent navigation mode.

Change one thing at a time so it is easy to tell what helped. After editing
the installed config, check it with:

```sh
"$HOME/.config/kanata/bin/kanata" --check --cfg "$HOME/.config/kanata/kanata.kbd"
```

Then press Control+Shift+R to reload. This folder contains the reviewed CAGS
config with the Windows modifier swap; future edits go into the installed
config. Backups from before the modifier swap, CAGS change, and Swedish shortcut changes are saved under
`~/.config/kanata/backups/`.

## Timing you can tune later

The first values in `defvar` are the ones to adjust:

- **hold-time = 220 ms:** time before a home-row modifier activates. If it
  feels slow, try 200. If you trigger shortcuts by accident, try 250.
- **typing-idle = 150 ms:** recent typing forces a letter instead of a
  modifier. This is why a short pause before a shortcut helps.
- **tap-time = 200 ms:** window for tapping, then quickly holding the same
  key to repeat its normal letter.

The same-hand key lists also favor ordinary typing while a decision is
pending. Once a hold has already activated, shortcuts work with either
hand.

## Build and verification notes

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
See `VERIFICATION.txt`. Try the shortcuts in your usual apps after reloading.

References:

- [Kanata macOS setup](https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md)
- [Tap/hold behavior](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#tap-hold)
- [Prior-idle typing protection](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#tap-hold-require-prior-idle)
- [Keyboard-specific mappings](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#definputdevices)
