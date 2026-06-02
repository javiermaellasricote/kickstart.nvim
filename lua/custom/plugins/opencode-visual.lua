-- Additional visual indicators for OpenCode status
-- This provides a more prominent visual indicator when OpenCode is active

return {
  'j-hui/fidget.nvim',
  event = 'VeryLazy',
  opts = {
    notification = {
      window = {
        winblend = 0,
      },
    },
  },
  config = function(_, opts)
    require('fidget').setup(opts)
    
    -- Create an autocmd to show OpenCode status
    vim.api.nvim_create_autocmd("User", {
      pattern = "OpencodeEvent:*",
      callback = function(args)
        local event = args.data.event
        
        -- Show different notifications based on event type
        if event.type == "session.start" then
          require('fidget').notify("OpenCode started", vim.log.levels.INFO, { key = "opencode_status" })
        elseif event.type == "session.idle" then
          require('fidget').notify("OpenCode ready", vim.log.levels.INFO, { key = "opencode_status", ttl = 2 })
        elseif event.type == "session.interrupt" then
          require('fidget').notify("OpenCode interrupted", vim.log.levels.WARN, { key = "opencode_status" })
        elseif event.type == "edit.apply" then
          require('fidget').notify("Applying OpenCode edits...", vim.log.levels.INFO, { key = "opencode_edit" })
        elseif event.type == "permission.request" then
          require('fidget').notify("OpenCode permission request", vim.log.levels.WARN, { key = "opencode_permission" })
        end
      end,
    })
  end,
}