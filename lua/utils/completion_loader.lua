local M = {}

function M.setup()
  local custom_completion_dir = vim.fn.stdpath("config") .. "/lua/custom_completion"
  local custom_completion_files = vim.fn.glob(custom_completion_dir .. "/*.lua", true, true)

  for _, file_path in ipairs(custom_completion_files) do
      local module_name = file_path:match(".*/(.-)%.lua$")
      if module_name then
          local ok, custom_comp_module = pcall(require, "custom_completion." .. module_name)
          if ok and type(custom_comp_module.setup) == "function" then
              custom_comp_module.setup()
          end
      end
  end
end

return M
