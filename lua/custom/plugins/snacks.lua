-- Snacks.nvim - A collection of small QoL plugins
-- https://github.com/folke/snacks.nvim

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- Enable the features that opencode.nvim uses
    input = {
      enabled = true,
    },
    picker = {
      enabled = true,
      actions = {
        opencode_send = function(...)
          return require('opencode').snacks_picker_send(...)
        end,
      },
      win = {
        input = {
          keys = {
            ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
          },
        },
      },
    },
    -- Enable notifier to keep notification history
    notifier = {
      enabled = true,
      timeout = 3000, -- default timeout in ms
    },
    -- You can enable other snacks.nvim features here as needed
    -- bigfile = { enabled = true },
    -- quickfile = { enabled = true },
    -- statuscolumn = { enabled = true },
    -- words = { enabled = true },
  },
  config = function(_, opts)
    require('snacks').setup(opts)
    
    -- Create commands to access notification history
    vim.api.nvim_create_user_command('NotificationHistory', function()
      require('snacks').notifier.show_history()
    end, { desc = 'Show notification history' })
    
    -- Optional: Add a keymap to quickly access notification history
    vim.keymap.set('n', '<leader>nh', function()
      require('snacks').notifier.show_history()
    end, { desc = 'Show notification history' })
  end,
}