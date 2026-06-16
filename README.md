# brighterscript.nvim

[BrightScript](https://developer.roku.com/docs/references/brightscript/language/brightscript-language-reference.md)
/ BrighterScript support for Neovim — syntax highlighting and LSP for Roku and BrightSign `.brs` files.

- **Syntax highlighting** — a self-contained vim syntax file (`*.brs`, `*.bs`). No
  Tree-sitter parser or external grammar required.
- **LSP** — wraps RokuCommunity's [`brighterscript`](https://github.com/rokucommunity/brighterscript)
  language server (`bsc --lsp --stdio`): diagnostics, completion, hover, goto-definition,
  rename, document symbols, and formatting.

Requires **Neovim 0.11+** (native `vim.lsp.config` / `vim.lsp.enable`). No `nvim-lspconfig`
or `mason` dependency.

> The LSP is provided by RokuCommunity's
> [brighterscript](https://github.com/rokucommunity/brighterscript); this plugin is the
> Neovim glue (filetype, syntax, and server registration).

![brighterscript.nvim: syntax highlighting and LSP on a BrightSign autorun script](assets/screenshot.png)

> Highlighting and live LSP diagnostics on a BrightSign `autozip.brs`. The two flagged
> lines are the expected Roku-vs-BrightSign false positives — see [BrightSign caveat](#brightsign-caveat).

### Before / after

The same BrightSign script (`autorun.brs`) with the plugin disabled and enabled:

| Plain text (no plugin) | With `brighterscript.nvim` |
|:---:|:---:|
| ![before: no highlighting](assets/no-highlight.png) | ![after: syntax highlighting](assets/highlight.png) |

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
| `auto_enable` | `true` | register and enable the server |
| `on_attach` / `capabilities` / `settings` | `nil` | standard LSP overrides |

Completion capabilities and keybindings normally come from your global
`vim.lsp.config("*", { capabilities = ... })` and an `LspAttach` autocmd, so you don't
need to repeat them here.

## Highlighting and the LSP are independent layers

Highlighting and the language server are separate systems:

- **Base colors** come from the bundled vim syntax file, not the LSP. They render with the
  LSP stopped or with `bsc` not installed.
- **The LSP** (`bsc`) adds semantic-token highlighting (parse-aware coloring) plus
  diagnostics, completion, hover, goto-definition, rename, and symbols.

Turning off the LSP does not remove the colors; the syntax file still applies. The toggles
are independent:

```vim
" diagnostics only (colors stay):
:lua vim.diagnostic.enable(false)        " back on: vim.diagnostic.enable(true)

" syntax-file colors (this buffer):
:setlocal syntax=OFF                     " back on: :setlocal syntax=brightscript
```

For a monochrome buffer, disable the syntax and detach the LSP (which also removes its
semantic-token colors):

```vim
:setlocal syntax=OFF
:lua vim.lsp.enable("brighterscript", false)
:lua for _, c in ipairs(vim.lsp.get_clients({ name = "brighterscript" })) do vim.lsp.stop_client(c.id) end
```

### Highlighting without the LSP

The syntax file is self-contained. For highlighting alone, install the plugin without `bsc`,
or copy `syntax/brightscript.vim` and `ftdetect/brightscript.vim` into your config's
`syntax/` and `ftdetect/` directories.

## Formatting

The `brighterscript` language server does **not** provide LSP formatting. RokuCommunity
ships formatting as a separate tool —
[`brighterscript-formatter`](https://github.com/rokucommunity/brighterscript-formatter),
the `bsfmt` CLI. Wire it into your formatter runner, e.g.
[conform.nvim](https://github.com/stevearc/conform.nvim):

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

To suppress these in a BrightSign project, add a `bsconfig.json` at the project root:

```json
{ "diagnostic": { "suppress": ["1001"] } }
```

(`1001` = "cannot find function"). Real syntax errors still surface.

## Credits

- [rokucommunity/brighterscript](https://github.com/rokucommunity/brighterscript) — the
  language server (`bsc`) behind the LSP features.
- [rokucommunity/brighterscript-formatter](https://github.com/rokucommunity/brighterscript-formatter)
  — the `bsfmt` formatter.
- [RokuCommunity.brightscript](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript)
  — the VS Code extension this plugin mirrors for Neovim.

## License

MIT
