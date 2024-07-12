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
  if vim.bo[buffer].fileencoding ~= "utf-8" then
    -- NOTE(libro): Is it necessary? Previously this plugin didn't handle
    --   multibyte-chars properly - so if buffer is not UTF8-encoded then
    --   the animation will be rusty as it was for UTF-8 buffers earlier
    error("Only UTF-8 buffers are supported")
  end

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

  -- update with buffer data
  for i, line in ipairs(data) do
    local j = 0
    local chars_displayed = 0
    -- NOTE(libro): Since we need to iterate over (possibly)
    --   multibyte symbols we need to know first column's byte index
    local byte_pos = vim.fn.getpos(vertical_range.start + i - 1)[3]
    for utf8_char in line:sub(byte_pos, -1):gmatch("[\x01-\x7F\xC2-\xF4%z][\x80-\xBF]*") do
      chars_displayed = chars_displayed + vim.fn.strdisplaywidth(utf8_char)
      if chars_displayed > window_width then
        break
      end

      j = j + 1
      byte_pos = byte_pos + #utf8_char

      grid[i][j].char = utf8_char
      grid[i][j].hl_group = get_dominant_hl_group(buffer, vertical_range.start + i, horizontal_range.start + j)
    end
  end
  return grid
end

return M
