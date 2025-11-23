local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = "*.go",
    callback = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] -- cursor position AFTER the typed character (0-indexed)

      -- Check if the last typed character was a comma
      if col > 0 and line:sub(col, col) == "," then
        -- The character BEFORE the comma should not be an opening parenthesis to avoid double-wrapping
        if col > 1 and line:sub(col - 1, col - 1) == "(" then
          return -- Already inside parentheses, do nothing
        end

        -- Extract the part of the line before the comma (1-indexed for Lua string functions)
        local text_before_comma = line:sub(1, col - 1)

        -- Pattern to match: "func FuncName(...) ReturnType" where ReturnType is not already in parentheses
        -- The ([%w%[%]%*]+) captures the actual return type.
        local func_return_type_pattern = "^func%s+%w+%s*%(.*%)%s*([%w%[%]%*]+)$"
        local match = text_before_comma:match(func_return_type_pattern)

        if match then
          local return_type = match -- This is the captured return type, e.g., "int"

          -- Calculate the start column of the 'return_type' within the current line (0-indexed)
          -- The end of 'text_before_comma' is `col - 1`.
          -- The length of 'return_type' is `#return_type`.
          -- So, the start column (0-indexed) of 'return_type' is `(col - 1) - #return_type`.
          local start_col_return_type = (col - 1) - #return_type
          local end_col_after_comma = col -- The comma was typed at 'col', so we replace up to and including 'col'

          -- Construct the new text to insert
          local new_text = "(" .. return_type .. ", )"

          -- Get current line number (0-indexed)
          local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

          -- Replace the text: from start_col_return_type to end_col_after_comma (0-indexed, exclusive end)
          -- The old text to replace is "int,"
          -- The new text is "(int, )"
          vim.api.nvim_buf_set_text(0, lnum, start_col_return_type, lnum, end_col_after_comma, {new_text})

          -- Reposition the cursor
          -- The cursor should be after the space in "(int, )"
          -- So, new position is start_col_return_type + length of "(return_type, " = start_col_return_type + 1 + #return_type + 2 = start_col_return_type + #return_type + 3
          local new_cursor_col = start_col_return_type + #return_type + 3
          vim.api.nvim_win_set_cursor(0, {lnum + 1, new_cursor_col})
        end
      end
    end,
  })
end

return M
