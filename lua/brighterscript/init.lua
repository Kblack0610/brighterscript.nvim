-- brighterscript.nvim
-- Barebones BrightScript / BrighterScript support for Neovim:
--   * syntax highlighting  (syntax/brightscript.vim)
--   * LSP                  (this file — RokuCommunity's `bsc --lsp --stdio`)
--
-- The LSP engine (https://github.com/rokucommunity/brighterscript) models Roku's
-- stdlib. Syntax errors, formatting, and navigation/hover/rename/completion on your
-- own symbols are accurate. Semantic diagnostics will false-flag BrightSign-specific
-- objects (roVideoPlayer, roNetworkConfiguration, ...) as unknown — see README.
--
-- Requires Neovim 0.11+ (native vim.lsp.config / vim.lsp.enable). No nvim-lspconfig
-- or mason dependency: the `bsc` binary is resolved from PATH, then mason's bin dir.

local M = {}

local DEFAULTS = {
  -- Override to pin a specific binary, e.g. cmd = { "/path/to/bsc", "--lsp", "--stdio" }.
  cmd = nil,
  filetypes = { "brightscript", "brs", "bs" },
  root_markers = { "bsconfig.json", "manifest", ".git" },
  -- Set false to register the server config without enabling auto-attach.
  auto_enable = true,
  -- Optional per-client hooks; capabilities/keybindings normally come from your
  -- host config's vim.lsp.config("*", ...) and LspAttach autocmd.
  on_attach = nil,
  capabilities = nil,
  settings = nil,
}

-- Resolve the `bsc` executable: PATH first (global `npm i -g brighterscript`),
-- then mason's bin dir (`:MasonInstall brighterscript`).
local function resolve_bsc()
  if vim.fn.exepath("bsc") ~= "" then
    return "bsc"
  end
  local mason = vim.fs.normalize(vim.fn.stdpath("data") .. "/mason/bin/bsc")
  if (vim.uv or vim.loop).fs_stat(mason) then
    return mason
  end
  return "bsc" -- last resort; the LSP client logs a clear error if it's absent
end

function M.setup(opts)
  local cfg = vim.tbl_deep_extend("force", {}, DEFAULTS, opts or {})

  local cmd = cfg.cmd or { resolve_bsc(), "--lsp", "--stdio" }

  -- Distinct server name (NOT "bright_script") so this never collides with the
  -- definition nvim-lspconfig ships or anything mason-lspconfig might auto-enable.
  vim.lsp.config("brighterscript", {
    cmd = cmd,
    filetypes = cfg.filetypes,
    root_markers = cfg.root_markers,
    on_attach = cfg.on_attach,
    capabilities = cfg.capabilities,
    settings = cfg.settings,
  })

  if cfg.auto_enable then
    vim.lsp.enable("brighterscript")
  end
end

return M
