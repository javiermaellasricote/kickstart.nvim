-- AI coding assistant (Cursor-like) for Neovim
-- https://github.com/yetone/avante.nvim

return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false,
  build = 'make',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
    'MeanderingProgrammer/render-markdown.nvim',
    -- Supplies vim.ui.input / vim.ui.select backends; required by Avante's "dressing" input provider.
    'stevearc/dressing.nvim',
  },
  opts = {
    provider = 'claude',
    providers = {
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-opus-4-7',
        extra_request_body = {
          -- Adaptive thinking requires temperature = 1 (or omitted); override Avante's 0.75 default.
          temperature = 1,
          max_tokens = 128000,
          thinking = { type = 'adaptive', display = 'summarized' },
          output_config = { effort = 'max' },
        },
      },
    },
    -- "native" provider mis-calls vim.ui.select and also can't handle concealed input;
    -- dressing.nvim supplies both, and Avante's own warning recommends it for password prompts.
    input = { provider = 'dressing' },
    behaviour = {
      auto_suggestions = false,
      auto_apply_diff_after_generation = false,
    },
    windows = {
      position = 'right',
      width = 35,
      sidebar_header = { align = 'center', rounded = true },
    },
  },
}
