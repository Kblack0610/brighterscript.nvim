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
  "kblack0610/brighterscript.nvim",
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

## License

MIT
