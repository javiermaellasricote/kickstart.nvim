return {
  'sindrets/diffview.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function(_, opts)
    require('diffview').setup(opts)
    
    -- Create a custom command that always includes untracked files
    vim.api.nvim_create_user_command('DV', function(args)
      local cmd = 'DiffviewOpen --untracked-files'
      if args.args ~= '' then
        cmd = cmd .. ' ' .. args.args
      end
      vim.cmd(cmd)
    end, { nargs = '*', complete = 'file' })
  end,
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewToggleFiles',
    'DiffviewFocusFiles',
    'DiffviewRefresh',
    'DiffviewFileHistory',
  },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen --untracked-files<cr>', desc = 'Open [G]it [D]iffview (with untracked)' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File [G]it [H]istory' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = '[G]it [H]istory (all files)' },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        -- Config for changed files, staged files, and conflicts
        layout = 'diff2_horizontal',
        winbar_info = false,
      },
      merge_tool = {
        -- Config for resolving merge conflicts
        layout = 'diff3_horizontal',
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        -- Config for file history view
        layout = 'diff2_horizontal',
        winbar_info = false,
      },
    },
    file_panel = {
      listing_style = 'tree',
      tree_options = {
        flatten_dirs = true,
        folder_statuses = 'only_folded',
      },
      win_config = {
        position = 'left',
        width = 35,
      },
    },
    hooks = {},
    keymaps = {
      disable_defaults = false,
      view = {
        -- The `view` bindings are active in the diff buffers
        { 'n', '<tab>', '<cmd>DiffviewToggleFiles<cr>', { desc = 'Toggle file panel' } },
        { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' } },
      },
      file_panel = {
        -- The `file_panel` bindings are active in the file panel
        { 'n', '<cr>', '<cmd>.DiffviewOpen<cr>', { desc = 'Open diff for file' } },
        { 'n', '<tab>', '<cmd>DiffviewToggleFiles<cr>', { desc = 'Toggle file panel' } },
        { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' } },
      },
    },
  },
}