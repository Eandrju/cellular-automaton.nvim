local M = {
  fps = 10,
  overpopultion_thr = 4,
  underpopulation_thr = 1,
  respawn_condition = 3,
}

local function is_cell_alive(grid, x, y)
  if x > 0 and x <= #grid and y > 0 and y <= #grid[x] and grid[x][y].char ~= " " then
    return true
  end
  return false
end

local function get_neighbours(grid, x, y)
  local neighbours = {}
  local coords = {
    { -1, 0 },
    { -1, -1 },
    { 0, -1 },
    { 1, -1 },
    { 1, 0 },
    { 1, 1 },
    { 0, 1 },
    { -1, 1 },
  }
  for _, n in ipairs(coords) do
    local nx = x + n[1]
    local ny = y + n[2]
    if is_cell_alive(grid, nx, ny) then
      table.insert(neighbours, grid[nx][ny])
    end
  end
  return neighbours
end

local function count_neighbours(grid, x, y)
  return #(get_neighbours(grid, x, y))
end

local function kill_cell(grid, x, y)
  grid[x][y] = { char = " " }
end

local function respawn_cell(grid, prev_grid, x, y)
  local neighbours = get_neighbours(prev_grid, x, y)
  grid[x][y] = vim.deepcopy(neighbours[math.random(1, #neighbours)])
end

M.update = function(grid)
  local reference = vim.deepcopy(grid)
  local was_state_updated = false
  for i = 1, #grid do
    for j = 1, #grid[i] do
      local n = count_neighbours(reference, i, j)
      if is_cell_alive(reference, i, j) then
        if n >= M.overpopultion_thr or n <= M.underpopulation_thr then
          kill_cell(grid, i, j)
          was_state_updated = true
        end
      else
        if n == M.respawn_condition then
          respawn_cell(grid, reference, i, j)
          was_state_updated = true
        end
      end
    end
  end
  return was_state_updated
end

return M
