-- Reads requirements.conf (shared with scripts/check_requirements.sh) and
-- checks the tools it lists. Used by :checkhealth core and at startup.
local M = {}

local conf_path = vim.fn.stdpath('config') .. '/requirements.conf'

local function trim(value)
  return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

--- @return { tool: string, min_version: string?, install_hint: string }[]
M.load = function()
  local requirements = {}

  local file = io.open(conf_path, 'r')
  if not file then
    return requirements
  end

  for line in file:lines() do
    local tool, min_version, install_hint = line:match('^([^|#]+)|([^|]*)|(.*)$')
    if tool then
      table.insert(requirements, {
        tool = trim(tool),
        min_version = trim(min_version) ~= '' and trim(min_version) or nil,
        install_hint = trim(install_hint),
      })
    end
  end

  file:close()
  return requirements
end

local function installed_version(tool)
  if tool == 'nvim' then
    local v = vim.version()
    return string.format('%d.%d.%d', v.major, v.minor, v.patch)
  end

  -- Not every tool speaks --version (tmux only takes -V), so try the common
  -- spellings until one prints something that looks like a version
  for _, flag in ipairs({ '--version', '-V', 'version' }) do
    local result = vim.system({ tool, flag }, { text = true }):wait()
    local output = (result.stdout or '') .. (result.stderr or '')
    local version = output:match('%d+%.%d+%.%d+') or output:match('%d+%.%d+')
    if version then
      return version
    end
  end
end

--- @return { ok: boolean, message: string }[]
M.check = function()
  local results = {}

  for _, requirement in ipairs(M.load()) do
    if vim.fn.executable(requirement.tool) ~= 1 then
      table.insert(results, {
        ok = false,
        message = string.format('%s is missing. Install with: %s', requirement.tool, requirement.install_hint),
      })
    elseif requirement.min_version then
      local version = installed_version(requirement.tool)
      if not version then
        table.insert(results, {
          ok = false,
          message = string.format(
            '%s found but its version could not be read (need >= %s)',
            requirement.tool,
            requirement.min_version
          ),
        })
      elseif vim.version.lt(version, requirement.min_version) then
        table.insert(results, {
          ok = false,
          message = string.format(
            '%s %s is too old, need >= %s. Update with: %s',
            requirement.tool,
            version,
            requirement.min_version,
            requirement.install_hint
          ),
        })
      else
        table.insert(results, { ok = true, message = string.format('%s %s', requirement.tool, version) })
      end
    else
      table.insert(results, { ok = true, message = requirement.tool })
    end
  end

  return results
end

-- Runs the check off the startup path and notifies once if anything is off
M.notify_missing = function()
  vim.defer_fn(function()
    local problems = {}
    for _, result in ipairs(M.check()) do
      if not result.ok then
        table.insert(problems, '- ' .. result.message)
      end
    end

    if #problems > 0 then
      vim.notify('Missing requirements (see :checkhealth core):\n' .. table.concat(problems, '\n'), vim.log.levels.WARN)
    end
  end, 1000)
end

return M
