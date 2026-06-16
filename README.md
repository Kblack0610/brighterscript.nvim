# brighterscript.nvim

Barebones [BrightScript](https://developer.roku.com/docs/references/brightscript/language/brightscript-language-reference.md)
/ BrighterScript support for Neovim — works for both **Roku** and **BrightSign** `.brs` files.

- **Syntax highlighting** — a self-contained vim syntax file (`*.brs`, `*.bs`). No
  Tree-sitter parser or external grammar required.
- **LSP** — wraps RokuCommunity's [`brighterscript`](https://github.com/rokucommunity/brighterscript)
  language server (`bsc --lsp --stdio`): diagnostics, completion, hover, goto-definition,
  rename, document symbols, and formatting.

Requires **Neovim 0.11+** (native `vim.lsp.config` / `vim.lsp.enable`). No `nvim-lspconfig`
or `mason` dependency.

> The LSP is powered entirely by RokuCommunity's
> **[brighterscript](https://github.com/rokucommunity/brighterscript)** — this plugin is
> just the Neovim glue (filetype, syntax, and server registration).

![brighterscript.nvim: syntax highlighting and LSP on a BrightSign autorun script](assets/screenshot.png)

> Highlighting and live LSP diagnostics on a BrightSign `autozip.brs`. The two flagged
> lines are the expected Roku-vs-BrightSign false positives — see [BrightSign caveat](#brightsign-caveat).

## Install the `bsc` binary

Either source works; the plugin resolves `bsc` from `$PATH` first, then Mason's bin dir.

```sh
npm install -g brighterscript      # global
# or, with mason.nvim:
:MasonInstall brighterscript
```

## Setup (lazy.nvim)

```lua
{
  "Kblack0610/brighterscript.nvim",
  ft = "brightscript",
  init = function()
    -- ensure .bs also resolves to the brightscript filetype before the ft-load fires
    vim.filetype.add({ extension = { bs = "brightscript" } })
  end,
  opts = {},
}
```

`opts` is passed to `require("brighterscript").setup()`:

| key | default | meaning |
|---|---|---|
| `cmd` | auto (`bsc --lsp --stdio`) | override the server command |
| `filetypes` | `{ "brightscript", "brs", "bs" }` | filetypes the LSP attaches to |
| `root_markers` | `{ "bsconfig.json", "manifest", ".git" }` | project root detection |
| `auto_enable` | `true` | register **and** enable the server |
| `on_attach` / `capabilities` / `settings` | `nil` | standard LSP overrides |

Completion capabilities and keybindings normally come from your global
`vim.lsp.config("*", { capabilities = ... })` and an `LspAttach` autocmd, so you don't
need to repeat them here.

## Highlighting and the LSP are independent layers

Worth knowing when toggling or debugging — the colors and the language-server features are
two **separate** systems:

- **Colors** come from the bundled vim syntax file, **not** the LSP. They work even with the
  LSP stopped, and with no `bsc` installed at all.
- **The LSP** (`bsc`) layers diagnostics, completion, hover, goto-definition, rename, and
  symbols on top. In a *static* view (e.g. a screenshot) the only LSP-visible thing is the
  diagnostics; everything else is interactive.

Toggle each independently for the current buffer:

```vim
:setlocal syntax=OFF                 " colors off       → back on: :setlocal syntax=brightscript
:lua vim.diagnostic.enable(false)    " diagnostics off  → back on: vim.diagnostic.enable(true)
```

To fully detach the LSP for the session (stops it re-attaching on the next keystroke):

```vim
:lua vim.lsp.enable("brighterscript", false)
:lua for _, c in ipairs(vim.lsp.get_clients({ name = "brighterscript" })) do vim.lsp.stop_client(c.id) end
```

## Formatting

The `brighterscript` language server does **not** provide LSP formatting. RokuCommunity
ships formatting as a separate tool —
[`brighterscript-formatter`](https://github.com/rokucommunity/brighterscript-formatter),
the `bsfmt` CLI (this is what the VS Code extension uses too). Wire it into your existing
formatter runner, e.g. [conform.nvim](https://github.com/stevearc/conform.nvim):

```sh
npm install -g brighterscript-formatter   # or :MasonInstall brighterscript-formatter
```

```lua
require("conform").setup({
  formatters_by_ft = {
    brightscript = { "bsfmt" },
  },
  formatters = {
    bsfmt = {
      command = "bsfmt",
      args = { "--write", "$FILENAME" },  -- bsfmt has no stdin; format the tempfile in place
      stdin = false,                      -- conform reads the file back after --write
    },
  },
})
```

## BrightSign caveat

The `brighterscript` engine models **Roku's** standard library. Syntax errors, formatting,
and navigation/hover/rename/completion on your *own* symbols are accurate. *Semantic*
diagnostics, however, will flag BrightSign-specific objects (`roVideoPlayer`,
`roNetworkConfiguration`, `roBrightPackage`, …) as unknown functions/components.

To quiet that noise in a BrightSign project, add a `bsconfig.json` at the project root:

```json
{ "diagnostic": { "suppress": ["1001"] } }
```

(`1001` = "cannot find function"). Real syntax errors still surface.

## Credits

- [rokucommunity/brighterscript](https://github.com/rokucommunity/brighterscript) — the
  language server (`bsc`) that powers all LSP features here.
- [rokucommunity/brighterscript-formatter](https://github.com/rokucommunity/brighterscript-formatter)
  — the `bsfmt` formatter.
- [RokuCommunity.brightscript](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript)
  — the VS Code extension this plugin mirrors for Neovim.

## License

MIT
