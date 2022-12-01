local M = {
  fps = 50,
  side_noise = true,
  disperse_rate = 3,
}

local frame

local cell_empty = function(grid, x, y)
  if x > 0 and x <= #grid and y > 0 and y <= #grid[x] and grid[x][y].char == " " then
    return true
  end
  return false
end

local swap_cells = function(grid, x1, y1, x2, y2)
  grid[x1][y1], grid[x2][y2] = grid[x2][y2], grid[x1][y1]
end

M.init = function(grid)
  frame = 1
end

M.update = function(grid)
  frame = frame + 1
  -- reset 'processed' flag
  for i = 1, #grid, 1 do
    for j = 1, #grid[i] do
      grid[i][j].processed = false
    end
  end
  local was_state_updated = false
  for x0 = #grid - 1, 1, -1 do
    for i = 1, #grid[x0] do
      -- iterate through grid from bottom to top using snake move
      -- >>>>>>>>>>>>
      -- ^<<<<<<<<<<<
      -- >>>>>>>>>>>^
      local y0
      if (frame + x0) % 2 == 0 then
        y0 = i
      else
        y0 = #grid[x0] + 1 - i
      end
      local cell = grid[x0][y0]

      -- skip spaces and comments or already proccessed cells
      if cell.char == " " or string.find(cell.hl_group or "", "comment") or cell.processed == true then
        goto continue
      end

      cell.processed = true

      -- to introduce some randomness sometimes step aside
      if M.side_noise then
        local random = math.random()
        local side_step_probability = 0.05
        if random < side_step_probability then
          was_state_updated = true
          if cell_empty(grid, x0, y0 + 1) then
            swap_cells(grid, x0, y0, x0, y0 + 1)
          end
        elseif random < 2 * side_step_probability then
          was_state_updated = true
          if cell_empty(grid, x0, y0 - 1) then
            swap_cells(grid, x0, y0, x0, y0 - 1)
          end
        end
      end

      -- either go one down
      if cell_empty(grid, x0 + 1, y0) then
        swap_cells(grid, x0, y0, x0 + 1, y0)
        was_state_updated = true
      else
        -- or to the side
        local disperse_direction = cell.disperse_direction or ({ -1, 1 })[math.random(1, 2)]
        local last_pos = { x0, y0 }
        for d = 1, M.disperse_rate do
          local y = y0 + disperse_direction * d
          -- prevent teleportation
          if not cell_empty(grid, x0, y) then
            cell.disperse_direction = disperse_direction * -1
            break
          elseif last_pos[1] == x0 then
            swap_cells(grid, last_pos[1], last_pos[2], x0, y)
            was_state_updated = true
            last_pos = { x0, y }
          end
          if cell_empty(grid, x0 + 1, y) then
            swap_cells(grid, last_pos[1], last_pos[2], x0 + 1, y)
            was_state_updated = true
            last_pos = { x0 + 1, y }
          end
        end
      end
      ::continue::
    end
  end
  return was_state_updated
end

return M
