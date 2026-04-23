-- Center the active buffer with equal-width scratch buffers on either side
-- https://github.com/shortcuts/no-neck-pain.nvim

return {
  'shortcuts/no-neck-pain.nvim',
  cmd = { 'NoNeckPain', 'NoNeckPainResize', 'NoNeckPainToggleLeftSide', 'NoNeckPainToggleRightSide' },
  opts = function()
    -- Content column stays ≥ 1/2 of terminal width; never below 100 cols on narrow screens.
    return { width = math.max(100, math.floor(vim.o.columns / 2)) }
  end,
  keys = {
    { '<leader>zz', '<cmd>NoNeckPain<CR>', desc = '[Z]en mode — toggle centered layout' },
  },
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      once = true,
      callback = function()
        vim.cmd.NoNeckPain()
      end,
    })
  end,
}
