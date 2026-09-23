# Replace which-key.nvim with mini.clue

## Context

The config currently pulls in `folke/which-key.nvim` purely to label seven `<leader>` prefix
groups. That is the only thing it does — `delay = 300` and a list of `group =` entries at the
bottom of `keymaps.lua`. Meanwhile the config is already deeply invested in the mini ecosystem:
`mini.nvim` is installed as the full monorepo and eleven modules are set up across
`mini.lua`, `ui.lua`, `navigation.lua`, `formatting.lua` and `keymaps.lua`.

`mini.clue` does everything which-key is doing here, ships in a package that is already on disk,
and removes an external dependency. This swap also buys something which-key was never configured
to provide in this setup: hint windows for built-in Vim prefixes (`g`, `z`, marks, registers,
`<C-w>`, insert-mode completion), using descriptions mini.clue generates itself.

Outcome: `which-key.nvim` is gone from the config, the lockfile, and the disk; pressing `<leader>`
behaves as it does today; `g`/`z`/`"`/`'`/`<C-w>`/`<C-x>` gain hint windows for free.

## Key difference from which-key

which-key hooks `timeoutlen` globally. mini.clue instead installs a **buffer-local keymap for each
trigger key** and takes over the key sequence from there. Practical consequences:

- Only keys listed in `triggers` get a popup. There is no "show everything" mode.
- Descriptions are read from each mapping's `desc` field automatically, exactly like which-key —
  so none of the ~35 existing `map(..., { desc = ... })` calls need to change.
- `clues` entries are only needed for **group labels** (the prefix itself) and for keys that have
  no `desc`.

## Files to modify

### 1. `nvim/lua/config/keymaps.lua` — replace lines 191–206

Delete the entire `-- Which-key` block (the `pcall(require, "which-key")` guard, `wk.setup`, and
`wk.add`). Replace it with a mini.clue setup placed **after** the `mini.basics` setup at
lines 208–216, so the file reads: mappings → basics → clue.

```lua
-- Hints for key sequences
local miniclue = require("mini.clue")

miniclue.setup({
	triggers = {
		-- Leader
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- `g` and `z`
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },

		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },

		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },
	},

	clues = {
		-- Leader groups (mirrors the old which-key `group =` entries)
		{ mode = "n", keys = "<Leader>b", desc = "+[B]uffers" },
		{ mode = "n", keys = "<Leader>c", desc = "+[C]ode" },
		{ mode = "n", keys = "<Leader>d", desc = "+[D]iagnostics" },
		{ mode = "n", keys = "<Leader>f", desc = "+[F]iles / Find" },
		{ mode = "n", keys = "<Leader>g", desc = "+[G]it" },
		{ mode = "n", keys = "<Leader>T", desc = "+[T]oggle common options" },

		-- Visual-mode groups: `<leader>ca`, `<leader>fw`, `<leader>gs` all have x/v mappings
		{ mode = "x", keys = "<Leader>c", desc = "+[C]ode" },
		{ mode = "x", keys = "<Leader>f", desc = "+[F]iles / Find" },
		{ mode = "x", keys = "<Leader>g", desc = "+[G]it" },

		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},

	window = {
		delay = 300,
		config = { width = "auto" },
	},
})
```

Notes on the translation:

- `window.delay = 300` preserves the current which-key `delay = 300` feel.
- The `+` prefix on group descriptions is the mini.clue convention for "this is a group, not a
  mapping".
- **Drop `<leader>t` "[T]ests"** (old line 203). It is a dead group — no mapping starting with
  `<leader>t` exists anywhere in the config, so which-key was advertising an empty prefix. Re-add
  it only when test mappings actually land.
- No clue is needed for `<leader>h` (Help, `keymaps.lua:187`) — it is a leaf mapping with a `desc`,
  so mini.clue picks it up automatically.
- No clues are needed for any of the `<leader>T*` option toggles — `mini.basics` sets those with
  proper `desc` values via `option_toggle_prefix` (`keymaps.lua:212`).
- No `pcall` guard is needed: `mini.nvim` is a hard dependency of this config already
  (`mini.lua` requires seven modules unguarded).

### 2. `nvim/lua/config/packages.lua` — remove line 15

Delete `PackAdd("folke/which-key.nvim")`. The `-- UI` block then holds only the two colorschemes.
No `PackAdd` is needed for mini.clue: it lives inside the already-installed `nvim-mini/mini.nvim`
monorepo (`packages.lua:3`).

### 3. `nvim/nvim-pack-lock.json` — remove the `which-key.nvim` entry (lines 47–51)

Preferably by letting `vim.pack.del` rewrite the file (see verification step 1). If the lockfile
is not updated automatically, delete the block by hand and fix the trailing comma on the
`nvim-tree.lua` entry above it.

### 4. Nerd Font icons in descriptions

mini.clue has no icon system at all — verified: zero occurrences of "icon" in
`mini.nvim/lua/mini/clue.lua`, and its whole config surface is `clues` / `triggers` / `window`.
Rows render as plain `keys │ desc`. which-key, by contrast, is decorating your popup today
(`icons.mappings = true` by default, 27 keyword rules matched against `desc`, colors from
mini.icons). Note that which-key never reads `vim.g.have_nerd_font`, so the `false` at
`options.lua:1` is not suppressing anything.

The only way to keep glyphs under mini.clue is to put them in the description text itself.

#### Where each icon has to go — this is not a free choice

From `H.clues_get` (`mini/clue.lua:1740-1770`), descriptions are resolved in three passes:

1. config `clues`, in array order — later entries overwrite earlier ones
2. **global keymaps — `res_data.desc = map_data.desc or ''`, an unconditional overwrite**
3. **buffer-local keymaps — same unconditional overwrite**

So a real keymap's `desc` always beats a config clue. Consequences:

- **Leaf mappings**: the icon must go in the `vim.keymap.set(..., { desc = ... })` call.
  Putting it in `clues` silently does nothing — pass 2 overwrites it.
- **Group prefixes** (`<leader>b`, `<leader>c`, …): these have no mapping, so the `clues` entry
  is the only source. Icons go there.
- **`gen_clues` sets**: their descriptions survive only for keys with no real mapping. `zz`,
  `<C-w>s`, `` `a `` etc. keep mini.clue's text; but `gd`/`gD` (`keymaps.lua:30-31`) and the
  LspAttach `grn`/`gra`/`grD` (`lsp.lua:21-23`) override `gen_clues.g()` with their own descs.
- A mapping with **no** `desc` sets the entry to `''` and wipes any clue for that key. Not a
  problem here — every mapping in `keymaps.lua` has a `desc`.

#### What is decorated today, and what is missing

Matching your descriptions against which-key's rule list (`which-key.nvim/lua/which-key/icons.lua:16-56`):

Already covered by a rule — `buffer`, `file`, `find`, `diagnostic`, `code`, `toggle`, `window`.

**Not matched by any rule** (these are the "missing" ones, and they are most of your Git and
LSP mappings): `Rename symbol`, `References`, `Document symbols`, `Workspace symbols`,
`Implementations`, `Added diff`, `Commit`, `Commit amend`, `Diff`, `Log`, `Show at cursor`,
`Show at selection`, `[B]lame line`, `Live grep`, `Fuzzy grep`, `Grep word / selection`, `Help`.

Worth knowing: the `%f[%a]git` rule needs the literal word "git" in the description, and none of
your Git descriptions contain it. What the Git group actually gets today is the *`buffer`* rule
firing on `Added diff buffer`, `Diff buffer` and `Log buffer` — a file icon on three Git
mappings, which is simply wrong. Moving to explicit glyphs fixes that mislabelling as a side
effect.

#### Proposed glyphs

Nerd Font names are given so any glyph that renders as tofu can be swapped from a cheat sheet
without guessing. Where which-key already had a sensible choice it is reused, so the popup looks
familiar. `󰊢` for Git is deliberate — it is the glyph already used in the blame float
(`keymaps.lua:109`).

Groups — these go in `clues`:

| Prefix | Description | Glyph | Nerd Font name |
|---|---|---|---|
| `<leader>b` | `󰈔 +[B]uffers` | 󰈔 | nf-md-file_document |
| `<leader>c` | ` +[C]ode` |  | nf-fa-code |
| `<leader>d` | `󱖫 +[D]iagnostics` | 󱖫 | nf-md-monitor_eye |
| `<leader>f` | ` +[F]iles / Find` |  | nf-fa-search |
| `<leader>g` | `󰊢 +[G]it` | 󰊢 | nf-md-source_branch |
| `<leader>T` | ` +[T]oggle common options` |  | nf-fa-toggle_on |

Leaves — these go in the `desc` of each `vim.keymap.set` call:

| Mapping | New description | Nerd Font name |
|---|---|---|
| `<leader>bb` | `󰈔 Switch buffer` | nf-md-file_document |
| `<leader>bd` | `󰅖 Delete buffer` | nf-md-close |
| `<leader>bn` | `󰒭 Next buffer` | nf-md-skip_next |
| `<leader>bp` | `󰒮 Previous buffer` | nf-md-skip_previous |
| `<leader>db` | `󱖫 Buffer diagnostics` | nf-md-monitor_eye |
| `<leader>dw` | `󱖫 Workspace diagnostics` | nf-md-monitor_eye |
| `<leader>dd` | `󰋽 Diagnostic details` | nf-md-information |
| `<leader>ca` | `󰌵 Code action` | nf-md-lightbulb |
| `<leader>cr` | `󰑕 Rename symbol` | nf-md-rename_box |
| `<leader>cR` | `󰌹 References` | nf-md-link_variant |
| `<leader>cs` | `󰙅 Document symbols` | nf-md-file_tree |
| `<leader>cS` | `󰠭 Workspace symbols` | nf-md-view_list |
| `<leader>ci` | `󰡱 Implementations` | nf-md-function_variant |
| `<leader>ga` | ` Added diff` | nf-oct-diff_added |
| `<leader>gA` | ` Added diff buffer` | nf-oct-diff_added |
| `<leader>gc` | ` Commit` | nf-oct-git_commit |
| `<leader>gC` | ` Commit amend` | nf-oct-git_commit |
| `<leader>gd` | ` Diff` | nf-oct-diff |
| `<leader>gD` | ` Diff buffer` | nf-oct-diff |
| `<leader>gl` | ` Log` | nf-fa-history |
| `<leader>gL` | ` Log buffer` | nf-fa-history |
| `<leader>go` | ` Toggle overlay` | nf-fa-eye |
| `<leader>gs` | ` Show at cursor` / `Show at selection` | nf-fa-info_circle |
| `<leader>gb` | `󰊢 Blame line` | nf-md-source_branch |
| `<leader>fe` | ` Toggle file explorer` | nf-fa-folder_open |
| `<leader>fm` | `󰉋 Toggle mini.files` | nf-md-folder |
| `<leader>ff` | ` Find files` | nf-fa-search |
| `<leader>fg` | `󰱼 Live grep` | nf-md-file_search |
| `<leader>fz` | `󰱼 Fuzzy grep` | nf-md-file_search |
| `<leader>fw` | `󰱼 Grep word / selection` | nf-md-file_search |
| `<leader>fd` | `󰉖 Find directories` | nf-md-folder_search |
| `<leader>h` | `󰋖 Help` | nf-md-help_circle_outline |

While editing `<leader>gb`, drop the `[B]` bracket from `[B]lame line` for consistency with the
other Git descriptions, and move the stray `-- Files / Find` comment off the end of
`keymaps.lua:152` to above the `nvimtree_toggle` function where it belongs.

#### One prerequisite

Flip `vim.g.have_nerd_font` to `true` at `options.lua:1`. It is currently `false` while the config
already relies on Nerd Font glyphs in the statusline (`ui.lua:26-39`), the blame float
(`keymaps.lua:109`) and blink's `nerd_font_variant = "mono"` — so the flag is already inaccurate,
and adding icons to descriptions makes it more so. Plugins that respect it will stop degrading to
ASCII fallbacks.

## Things to watch after the swap

These are consequences of mini.clue's trigger model, not bugs. Each has a one-line escape hatch.

- **`<C-r>` in insert mode** overlaps with `mini.pick`'s prompt. If typing `<C-r>` in a picker feels
  laggy, remove the `{ mode = "i", keys = "<C-r>" }` trigger.
- **`'` and `` ` `` triggers** add a 300ms window before mark jumps render their popup. The jump
  itself is never delayed; only the hint window waits. Drop those four trigger lines if the popup
  is noise.
- **`g` trigger** will now surface `gd`/`gD` (`keymaps.lua:30-31`), the LspAttach-local `grn`/`gra`/
  `grD` (`lsp.lua:21-23`), and `mini.basics`' `g`-prefixed clipboard mappings — all with their
  existing descriptions. This is a gain, not a regression.
- **nvim-tree and mini.files buffers** set their own buffer-local `g?` help mappings. mini.clue
  triggers are also buffer-local and are (re)installed on `BufEnter`, so both coexist; the plugin
  mapping shows up as an entry in the `g` window.

## Verification

1. **Uninstall the plugin.** In a running nvim (before reloading the new config, so the plugin is
   still registered):
   ```
   :lua vim.pack.del({ 'which-key.nvim' })
   ```
   Then confirm the lockfile no longer mentions it:
   ```
   rg 'which-key' nvim/nvim-pack-lock.json
   ```
   If it is still there, remove the block manually per step 3 above.

2. **Confirm no stale references.** From the repo root:
   ```
   rg -n 'which.key|which_key' nvim/
   ```
   Should return nothing.

3. **Restart nvim and confirm clue is live:**
   ```
   :lua= MiniClue.config.window.delay   " -> 300
   ```

4. **Exercise each leader group.** Press `<leader>` and wait ~300ms in normal mode. Confirm the
   window lists `b`, `c`, `d`, `f`, `g`, `h`, `T` with the `+[B]uffers` style labels, and that `t`
   is absent. Then drill into each: `<leader>b` should show the four buffer mappings with their
   descriptions, `<leader>g` the eleven git mappings, `<leader>T` the mini.basics option toggles.

5. **Exercise visual mode.** Select a few lines, press `<leader>`, confirm `c`, `f` and `g` appear,
   and that `<leader>gs` still runs `MiniGit.show_at_cursor()` on the selection.

6. **Exercise the built-in triggers.** Press `g`, `z`, `"`, `'`, `<C-w>` in normal mode and `<C-x>`
   in insert mode; each should produce a populated hint window after the delay.

7. **Confirm nothing is swallowed.** Type quickly without pausing: `<leader>ff` opens the fff
   picker, `gd` jumps to definition, `zz` centers the line, `"ayy` yanks to register `a`. mini.clue
   must not intercept any of these when typed at speed.

8. **Check every glyph renders.** Open each leader group and scan for tofu boxes (`􏿽`) or
   double-width smearing that misaligns the `│` separator column. Any glyph that fails gets
   swapped from the Nerd Font cheat sheet using the `nf-*` name in the table above. Pay particular
   attention to the `nf-md-*` glyphs (`󰱼`, `󰡱`, `󰠭`, `󰉖`), which live in a higher plane than the
   FontAwesome ones and are the likeliest to be absent from an older patched font.
