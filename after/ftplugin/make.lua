-- Make's grammar requires recipe lines to start with a literal TAB character;
-- expanding tabs to spaces produces "missing separator" errors at runtime.
vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 0
vim.opt_local.softtabstop = 0
