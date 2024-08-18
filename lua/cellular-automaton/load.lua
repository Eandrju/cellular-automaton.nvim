local unpack = unpack or table.unpack

local M = {}

local get_dominant_hl_group = function(buffer, i, j)
  local captures = vim.treesitter.get_captures_at_pos(buffer, i - 1, j - 1)
  for c = #captures, 1, -1 do
    if captures[c].capture ~= "spell" and captures[c].capture ~= "@spell" then
      return "@" .. captures[c].capture
    end
  end
  return ""
end

local get_usable_window_width = function()
  -- getting number of visible columns in vim is PITA
  -- below vimscript function was taken from
  -- https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
  local window_width = vim.api.nvim_exec(
    [[
      function! BufferWidth()
        let width = winwidth(0)
        let numberwidth = max([&numberwidth, strlen(line('$')) + 1])
        let numwidth = (&number || &relativenumber) ? numberwidth : 0
        let foldwidth = &foldcolumn

        if &signcolumn == 'yes'
          let signwidth = 2
        elseif &signcolumn =~ 'yes'
          let signwidth = &signcolumn
          let signwidth = split(signwidth, ':')[1]
          let signwidth *= 2  " each signcolumn is 2-char wide
        elseif &signcolumn == 'auto'
          let supports_sign_groups = has('nvim-0.4.2') || has('patch-8.1.614')
          let signlist = execute(printf('sign place ' . (supports_sign_groups ? 'group=* ' : '')
              \. 'buffer=%d', bufnr('')))
          let signlist = split(signlist, "\n")
          let signwidth = len(signlist) > 2 ? 2 : 0
        elseif &signcolumn =~ 'auto'
          let signwidth = 0
          if len(sign_getplaced(bufnr(),{'group':'*'})[0].signs)
            let signwidth = 0
            for l:sign in sign_getplaced(bufnr(),{'group':'*'})[0].signs
              let lnum = l:sign.lnum
              let signs = len(sign_getplaced(bufnr(),{'group':'*', 'lnum':lnum})[0].signs)
              let signwidth = (signs > signwidth ? signs : signwidth)
            endfor
          endif
          let signwidth *= 2   " each signcolumn is 2-char wide
        else
          let signwidth = 0
        endif

        return width - numwidth - foldwidth - signwidth
      endfunction
      echo BufferWidth()
    ]],
    true
  )
  return tonumber(window_width)
end

---Load base grid (replace multicell
---symbols and tabs with replacers)
---@param window integer?
---@param buffer integer?
---@return { char: string, hl_group: string [][]}
M.load_base_grid = function(window, buffer)
  if window == nil or window == 0 then
    -- NOTE: virtcol call with *winid*
    --   arg == 0 always returns zeros
    window = vim.api.nvim_get_current_win()
  end
  if buffer == nil or buffer == 0 then
    buffer = vim.api.nvim_get_current_buf()
  end

  local window_width = get_usable_window_width()
  local vertical_range = {
    start = vim.fn.line("w0") - 1,
    end_ = vim.fn.line("w$"),
  }
  local first_visible_virtcol = vim.fn.winsaveview().leftcol + 1
  local last_visible_virtcol = first_visible_virtcol + window_width

  -- initialize the grid
  ---@type {char: string, hl_group: string}[][]
  local grid = {}
  for i = 1, vim.api.nvim_win_get_height(window) do
    grid[i] = {}
    for j = 1, window_width do
      grid[i][j] = { char = " ", hl_group = "" }
    end
  end
  local data = vim.api.nvim_buf_get_lines(buffer, vertical_range.start, vertical_range.end_, true)

  -- update with buffer data
  for i, line in ipairs(data) do
    local jj = 0
    local col = 0
    local virtcol = 0
    local lineno = vertical_range.start + i

    ---@type integer
    local char_screen_col_start

    ---@type integer
    local char_screen_col_end

    while true do
      col = col + 1
      virtcol = virtcol + 1
      char_screen_col_start, char_screen_col_end = unpack(vim.fn.virtcol({ lineno, virtcol }, 1, window))
      if char_screen_col_start == 0 and char_screen_col_end == 0 or char_screen_col_start > last_visible_virtcol then
        break
      end

      ---@type string
      local char = vim.fn.strcharpart(line, col - 1, 1)
      if char == "" then
        break
      end
      virtcol = virtcol + #char - 1

      if char_screen_col_end < first_visible_virtcol then
        goto to_next_char
      end
      local columns_occupied = char_screen_col_end - char_screen_col_start + 1

      if columns_occupied > 1 then
        local is_tab = char == "\t"
        local replacer = is_tab and " " or "@"
        local hl_group = is_tab and "" or "WarningMsg"
        for _ = math.max(first_visible_virtcol, char_screen_col_start), char_screen_col_end do
          jj = jj + 1
          if jj > window_width then
            goto to_next_line
          end
          grid[i][jj].char = replacer
          grid[i][jj].hl_group = hl_group
        end
      else
        jj = jj + 1
        if jj > window_width then
          goto to_next_line
        end
        grid[i][jj].char = char
        grid[i][jj].hl_group = get_dominant_hl_group(buffer, lineno, virtcol)
      end
      ::to_next_char::
    end
    ::to_next_line::
  end
  return grid
end

return M
