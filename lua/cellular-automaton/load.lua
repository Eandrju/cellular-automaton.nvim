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

M.load_base_grid = function(window, buffer)
  local window_width = get_usable_window_width()
  local vertical_range = {
    start = vim.fn.line("w0") - 1,
    end_ = vim.fn.line("w$"),
  }
  local horizontal_range = {
    start = vim.fn.winsaveview().leftcol,
    end_ = vim.fn.winsaveview().leftcol + window_width,
  }

  -- initialize the grid
  local grid = {}
  for i = 1, vim.api.nvim_win_get_height(window) do
    grid[i] = {}
    for j = 1, window_width do
      grid[i][j] = { char = " ", hl_group = "" }
    end
  end
  local data = vim.api.nvim_buf_get_lines(buffer, vertical_range.start, vertical_range.end_, true)

  ---@type string?
  local hl_group

  -- update with buffer data
  for i, line in ipairs(data) do
    -- *col* is the column counter, while *chars_processed*
    -- is the counter for UTF-8 symbols being processed
    local col = 0
    local chars_processed = 0

    -- NOTE(libro): Since we need to iterate over (possibly)
    --   multibyte symbols we need to know first column's byte index
    local first_byte_pos = vim.fn.getpos(tostring(vertical_range.start + i - 1))[3]

    -- TODO(libro): Check it when invalid UTF-8 bytes are present in the line
    for utf8_char in line:sub(first_byte_pos, -1):gmatch("[\x01-\x7F\xC2-\xF4%z][\x80-\xBF]*") do
      ---@type string[]
      local symbols = {}

      local char_display_width = vim.fn.strdisplaywidth(utf8_char, horizontal_range.start + col)

      if #utf8_char == 1 and utf8_char:byte(1, 1) == 0x09 then
        -- If it's tab (09h, \t), then ask *strdisplaywidth()* how many columns
        -- it's occupying in the initial line (respecting softtab options etc.)
        -- and then replace it with corresponding amount of spaces
        for _ = 1, char_display_width do
          hl_group = ""
          symbols[#symbols + 1] = " "
        end
      elseif char_display_width == 1 then
        symbols[#symbols + 1] = utf8_char
        hl_group = nil
      else
        -- If symbol occupies more than one cell (column)
        -- then also replace it with something meaningful (?)
        -- TODO(libro): Make replacers actually meaningful :)
        local replacer = "@"
        hl_group = "WarningMsg"
        for _ = 1, char_display_width do
          symbols[#symbols + 1] = replacer
        end
      end

      chars_processed = chars_processed + 1
      for _, symbol in ipairs(symbols) do
        col = col + 1
        if col > window_width then
          goto to_another_line
        end

        grid[i][col].char = symbol
        grid[i][col].hl_group = hl_group
          or get_dominant_hl_group(buffer, vertical_range.start + i, horizontal_range.start + chars_processed)
      end
    end
    ::to_another_line::
  end
  return grid
end

return M
