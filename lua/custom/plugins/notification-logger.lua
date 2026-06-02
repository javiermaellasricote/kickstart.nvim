-- Simple notification logger to keep track of all notifications
-- This captures all vim.notify calls and logs them to a buffer

return {
  'rcarriga/nvim-notify',
  lazy = false,
  priority = 1000,
  config = function()
    local notify = require('notify')
    
    -- Set up nvim-notify as the default notification handler
    vim.notify = notify
    
    -- Configure notify
    notify.setup({
      -- Keep notifications on screen longer
      timeout = 5000,
      -- Save notification history
      max_history = 100,
      -- Positioning
      top_down = false,
    })
    
    -- Create command to show notification history
    vim.api.nvim_create_user_command('Notifications', function()
      notify.history()
    end, { desc = 'Show notification history' })
    
    -- Create a keymap for quick access
    vim.keymap.set('n', '<leader>fn', '<cmd>Notifications<cr>', { desc = 'Find notifications' })
    
    -- Alternative: Open notification history in telescope (if you have telescope)
    vim.keymap.set('n', '<leader>sn', function()
      local ok, telescope = pcall(require, 'telescope')
      if ok then
        telescope.extensions.notify.notify()
      else
        notify.history()
      end
    end, { desc = 'Search notifications' })
  end,
}