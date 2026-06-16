" Map BrightScript file extensions to the `brightscript` filetype.
" Neovim 0.12 core already detects *.brs; this also covers *.bs and older Neovim,
" and makes the plugin work standalone (outside a lazy `init` filetype hook).
au BufRead,BufNewFile *.brs,*.bs set filetype=brightscript
