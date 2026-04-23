-- In-buffer markdown rendering
-- https://github.com/MeanderingProgrammer/render-markdown.nvim

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  ft = { 'markdown' },
  opts = {
    completions = { blink = { enabled = true } },
  },
  keys = {
    { '<leader>mp', '<cmd>RenderMarkdown buf_toggle<CR>', desc = '[M]arkdown [P]review toggle (buffer)', ft = 'markdown' },
  },
}
