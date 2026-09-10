local M = {}

M.check = function()
  vim.health.start('Requirements from requirements.conf')

  for _, result in ipairs(require('core.requirements').check()) do
    if result.ok then
      vim.health.ok(result.message)
    else
      vim.health.error(result.message)
    end
  end
end

return M
