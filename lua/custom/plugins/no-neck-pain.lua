-- Center the active buffer with equal-width scratch buffers on either side,
-- but only while a single file window is open. As soon as a second file
-- window (a split) appears, the padding is removed so the files use the full
-- width of the screen; centering returns once you are back to one window.
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
    -- True only once the plugin is loaded AND currently centering a tab.
    -- Reads the global state directly so it never force-loads the lazy plugin.
    local function is_centered()
      return _G.NoNeckPain ~= nil and _G.NoNeckPain.state ~= nil and _G.NoNeckPain.state.enabled
    end

    -- Number of "file windows" in the current tab: ordinary, non-floating
    -- windows holding a real buffer. no-neck-pain's padding buffers (buftype
    -- "nofile", filetype "no-neck-pain") and floating windows (pickers, etc.)
    -- are excluded, so they never count toward the total.
    local function file_window_count()
      local count = 0
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == '' then
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == '' and vim.bo[buf].filetype ~= 'no-neck-pain' then
            count = count + 1
          end
        end
      end
      return count
    end

    -- Enable centering for a lone file window, disable it once there are two
    -- or more. enable()/disable() run only when the state must change, and
    -- no-neck-pain's own enable() is additionally idempotent, so this can't
    -- thrash or loop when the plugin opens/closes its own side windows.
    local function sync()
      -- Ignore events fired while focused in a floating window (e.g. a
      -- Telescope prompt): the file-window count is unaffected by them.
      if vim.api.nvim_win_get_config(0).relative ~= '' then
        return
      end

      local windows = file_window_count()
      if windows == 1 and not is_centered() then
        require('no-neck-pain').enable()
      elseif windows >= 2 and is_centered() then
        require('no-neck-pain').disable()
      end
    end

    -- Coalesce a burst of window events into one deferred check, and run it
    -- after Neovim has finished the current operation so the window list (and
    -- any window about to close) is accurate.
    local scheduled = false
    local function schedule_sync()
      if scheduled then
        return
      end
      scheduled = true
      vim.schedule(function()
        scheduled = false
        sync()
      end)
    end

    vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter', 'WinClosed' }, {
      group = vim.api.nvim_create_augroup('NoNeckPainAutoCenter', { clear = true }),
      callback = schedule_sync,
      desc = 'Center the buffer only while a single file window is open',
    })
  end,
}
