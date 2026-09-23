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
