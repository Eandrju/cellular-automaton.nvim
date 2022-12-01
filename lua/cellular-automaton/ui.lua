local M = {}

local window_id = nil
local buffers = nil
local namespace = vim.api.nvim_create_namespace("cellular-automaton")

-- Each frame is rendered in different buffer to avoid flickering
-- caused by lack of higliths right after setting the buffer data.
-- Thus we are switching between two buffers throughtout the animation
local get_buffer = (function()
  local count = 0
  return function()
    count = count + 1
    return buffers[count % 2 + 1]
  end
end)()

M.open_window = function(host_window)
  buffers = {
    vim.api.nvim_create_buf(false, true),
    vim.api.nvim_create_buf(false, true),
  }
  local buffnr = get_buffer()
  window_id = vim.api.nvim_open_win(buffnr, true, {
    relative = "editor",
    width = vim.api.nvim_win_get_width(host_window),
    height = vim.api.nvim_win_get_height(host_window),
    border = "none",
    row = 0,
    col = 0,
  })
  vim.api.nvim_win_set_option(window_id, "winhl", "Normal:CellularAutomatonNormal")
  vim.api.nvim_win_set_option(window_id, "list", false)
  return window_id, buffers
end

M.render_frame = function(grid)
  -- quit if animation already interrupted
  if window_id == nil or not vim.api.nvim_win_is_valid(window_id) then
    return
  end
  local buffnr = get_buffer()
  -- update data
  local lines = {}
  for _, row in ipairs(grid) do
    local chars = {}
    for _, cell in ipairs(row) do
      table.insert(chars, cell.char)
    end
    table.insert(lines, table.concat(chars, ""))
  end
  vim.api.nvim_buf_set_lines(buffnr, 0, vim.api.nvim_win_get_height(window_id), false, lines)
  -- update highlights
  vim.api.nvim_buf_clear_namespace(buffnr, namespace, 0, -1)
  for i, row in ipairs(grid) do
    for j, cell in ipairs(row) do
      vim.api.nvim_buf_add_highlight(buffnr, namespace, cell.hl_group or "", i - 1, j - 1, j)
    end
  end
  -- swap buffers
  vim.api.nvim_win_set_buf(window_id, buffnr)
end

M.clean = function()
  buffers = buffers or {}
  for _, buffnr in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buffnr) then
      vim.api.nvim_buf_delete(buffnr, { force = true })
    end
  end
  window_id = nil
  buffers = nil
end

return M
