-- OpenCode AI integration for Neovim
-- https://github.com/nickjvandyke/opencode.nvim

return {
  'nickjvandyke/opencode.nvim',
  version = '*', -- Latest stable release
  event = 'VeryLazy',
  dependencies = {
    'folke/snacks.nvim', -- Now installed separately in snacks.lua
  },
  init = function()
    -- Set options before the plugin loads
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any; goto definition on the type or field for details
      -- Show a notification when OpenCode starts responding
      events = {
        on_event = function(event)
          if event.type == "session.start" then
            vim.notify("🤖 OpenCode is thinking...", vim.log.levels.INFO, { title = "OpenCode" })
          elseif event.type == "session.idle" then
            vim.notify("✓ OpenCode finished", vim.log.levels.INFO, { title = "OpenCode" })
          end
        end,
      },
      -- Server configuration to ensure proper connection
      server = {
        -- Let opencode.nvim find the running server automatically
        url = nil,
        -- Start options for embedded terminal
        start = {
          cmd = "opencode",
          args = { "--port" },
        },
      },
    }

    vim.o.autoread = true -- Required for `opts.events.reload`
  end,
  config = function()
    -- Force statusline redraw on OpenCode events (with error protection)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'OpencodeEvent:*',
      callback = function()
        -- Protected redraw to prevent errors
        pcall(vim.cmd, 'redrawstatus!')
      end,
    })

    -- Recommended/example keymaps (with error protection)
    vim.keymap.set({ 'n', 'x' }, '<C-a>', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        opencode.ask('@this: ', { submit = true })
      else
        vim.notify('OpenCode not ready', vim.log.levels.WARN)
      end
    end, { desc = 'Ask opencode…' })
    
    vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        opencode.select()
      else
        vim.notify('OpenCode not ready', vim.log.levels.WARN)
      end
    end, { desc = 'Select opencode…' })
    
    vim.keymap.set({ 'n', 't' }, '<C-.>', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        opencode.toggle()
      else
        vim.notify('OpenCode not ready', vim.log.levels.WARN)
      end
    end, { desc = 'Toggle opencode' })

    vim.keymap.set({ 'n', 'x' }, 'go', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        return opencode.operator('@this ')
      else
        return ''
      end
    end, { desc = 'Add range to opencode', expr = true })
    
    vim.keymap.set('n', 'goo', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        return opencode.operator('@this ') .. '_'
      else
        return ''
      end
    end, { desc = 'Add line to opencode', expr = true })

    vim.keymap.set('n', '<S-C-u>', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        opencode.command('session.half.page.up')
      end
    end, { desc = 'Scroll opencode up' })
    
    vim.keymap.set('n', '<S-C-d>', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        opencode.command('session.half.page.down')
      end
    end, { desc = 'Scroll opencode down' })

    -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
    vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment under cursor', noremap = true })
    vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement under cursor', noremap = true })
    
    -- Create a user command to check OpenCode status
    vim.api.nvim_create_user_command('OpencodeStatus', function()
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        if opencode.statusline then
          local status_ok, status = pcall(opencode.statusline)
          if status_ok then
            vim.notify('OpenCode status: ' .. (status ~= '' and status or 'Not running'), vim.log.levels.INFO)
          else
            vim.notify('OpenCode statusline error: ' .. tostring(status), vim.log.levels.ERROR)
          end
        else
          vim.notify('OpenCode statusline function not found', vim.log.levels.WARN)
        end
      else
        vim.notify('OpenCode not loaded', vim.log.levels.WARN)
      end
    end, { desc = 'Show OpenCode status' })
    
    -- Alternative: Add to global statusline if mini.statusline doesn't work
    vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold' }, {
      callback = function()
        local ok, opencode = pcall(require, 'opencode')
        if ok and opencode.statusline then
          local status_ok, status = pcall(opencode.statusline)
          if status_ok then
            vim.g.opencode_status = status or ''
          else
            vim.g.opencode_status = ''
          end
        else
          vim.g.opencode_status = ''
        end
      end,
    })
    
    -- Debug command to test OpenCode connection
    vim.api.nvim_create_user_command('OpencodeTest', function()
      vim.notify('Testing OpenCode connection...', vim.log.levels.INFO)
      vim.defer_fn(function()
        local ok, opencode = pcall(require, 'opencode')
        if ok then
          vim.notify('OpenCode module loaded ✓', vim.log.levels.INFO)
          if opencode.statusline then
            vim.notify('Statusline function exists ✓', vim.log.levels.INFO)
            local status_ok, status = pcall(opencode.statusline)
            if status_ok then
              vim.notify('Current status: ' .. (status and tostring(status) or 'nil'), vim.log.levels.INFO)
            else
              vim.notify('Statusline call failed: ' .. tostring(status), vim.log.levels.ERROR)
            end
          else
            vim.notify('Statusline function not found ✗', vim.log.levels.ERROR)
          end
          -- Force a redraw to update statusline
          vim.cmd('redrawstatus!')
        else
          vim.notify('Failed to load OpenCode module ✗', vim.log.levels.ERROR)
        end
      end, 100)
    end, { desc = 'Test OpenCode connection and statusline' })
    
    -- Simple visual indicator when OpenCode is active
    vim.api.nvim_create_autocmd('User', {
      pattern = 'OpencodeEvent:session.start',
      callback = function()
        vim.notify('🤖 OpenCode started processing...', vim.log.levels.INFO)
        vim.cmd('redrawstatus!')
      end,
    })
    
    vim.api.nvim_create_autocmd('User', {
      pattern = 'OpencodeEvent:session.idle',  
      callback = function()
        vim.notify('✓ OpenCode ready', vim.log.levels.INFO)
        vim.cmd('redrawstatus!')
      end,
    })
  end,
}