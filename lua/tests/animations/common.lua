local M = {}

M.get_grid = function(pattern)
  local grid = {}
  for _, line in ipairs(pattern) do
    local row = {}
    for i = 1, #line do
      local char = line:sub(i, i)
      local cell = { char = char }
      if char == "#" then
        cell.hl_group = "@comment"
      end
      table.insert(row, cell)
    end
    table.insert(grid, row)
  end
  return grid
end

local convert_grid_to_string = function(grid)
  local result = ""
  for _, row in ipairs(grid) do
    for _, cell in ipairs(row) do
      result = result .. cell.char
    end
    result = result .. "\n"
  end
  return string.sub(result, 1, -2)
end

local replace_spaces = function(str)
  local result = ""
  for i = 1, #str do
    local char = string.sub(str, i, i)
    if char == " " then
      result = result .. "."
    else
      result = result .. char
    end
  end
  return result
end

M.assert_grid_same = function(grid, pattern, error_msg)
  local got = "\n" .. convert_grid_to_string(grid) .. "\n"
  local expected = "\n" .. table.concat(pattern, "\n") .. "\n"
  assert.are.same(replace_spaces(got), replace_spaces(expected), error_msg)
end

M.assert_grid_different = function(grid, pattern, error_msg)
  local got = "\n" .. convert_grid_to_string(grid) .. "\n"
  local expected = "\n" .. table.concat(pattern, "\n") .. "\n"
  assert.are.not_.same(replace_spaces(got), replace_spaces(expected), error_msg)
end

return M
