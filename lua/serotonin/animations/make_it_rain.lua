local M = {
    fps = 20,
    side_noise = false,
}

local frame

M.init = function (grid)
    for i = 1, #grid do
        for j = 1, #(grid[i]) do
            grid[i][j].disperse_direction = nil
        end
    end
    frame = 1
end

local cell_empty = function (grid, x, y)
    if (
        x > 0 and
        x <= #grid and
        y > 0 and
        y <= #(grid[x]) and
        grid[x][y].char == " "
    ) then
        return true
    end
    return false
end

local swap_cells = function (grid, x1, y1, x2, y2)
    grid[x1][y1], grid[x2][y2] = grid[x2][y2], grid[x1][y1]
end

M.update = function (grid)
    frame = frame + 1
    -- reset processed flag
    for i = 1, #grid, 1 do
        for j = 1, #(grid[i]) do
            grid[i][j].processed = false
            -- grid[i][j].disperse_direction = nil
        end
    end
    local was_state_updated = false
    for x0 = #grid - 1, 1, -1 do
        for i = 1, #(grid[x0]) do
            -- iterate through grid from bottom to top using snake move
            -- >>>>>>>>>>>>
            -- ^<<<<<<<<<<<
            -- >>>>>>>>>>>^
            local y0
            if (frame + x0) % 2 == 0 then
                y0 = i
            else
                y0 = #(grid[x0]) + 1 - i
            end
            local cell = grid[x0][y0]

            -- skip spaces and comments or already proccessed cells
            if cell.char == " "
                or string.find(cell.hl_group or "", "comment")
                or cell.processed == true then
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
                -- cell.disperse_direction = nil
            else
                local disperse_direction = cell.disperse_direction or
                                           ({-1, 1})[math.random(1, 2)]
                local disperse_distance = 3
                local last_valid_pos = {x0, y0}
                for d = 1, disperse_distance do
                    local x = x0 + 1
                    local y = y0 + disperse_direction * d
                    if cell_empty(grid, x, y) then
                        last_valid_pos = {x, y}
                        break
                    end
                    x = x0
                    if not cell_empty(grid, x, y) then
                        cell.disperse_direction = disperse_direction * -1
                        break
                    end
                    last_valid_pos = {x, y}
                end
                was_state_updated = true
                swap_cells(grid, x0, y0, last_valid_pos[1], last_valid_pos[2])
            end
            -- if cell.disperse_direction == -1 then
            --     cell.char = "<"
            -- elseif cell.disperse_direction == nil then
            --     cell.char = 'n'
            -- elseif cell.disperse_direction == 1 then
            --     cell.char = ">"
            -- elseif cell.disperse_direction == 0 then
            --     cell.char = "0"
            -- else
            --     cell.char = cell.disperse_direction
            -- end
            -- or down diagonally
            -- elseif cell_empty(grid, x0 + 1, y0 - 1)
            --     or cell_empty(grid, x0 + 1, y0 + 1) then
            --     local order = ({{1, -1}, {-1, 1}})[math.random(1, 2)]
            --     for _, direction in ipairs(order) do
            --         if cell_empty(grid, x0 + 1, y0 + direction) then
            --             swap_cells(grid, x0, y0, x0 + 1, y0 + direction)
            --             break
            --         end
            --     end
            --     was_state_updated = true
            -- -- or down diagonally but further
            -- elseif cell_empty(grid, x0 + 1, y0 - 2)
            --     or cell_empty(grid, x0 + 1, y0 + 2) then
            --     local order = ({{2, -2}, {-2, 2}})[math.random(1, 2)]
            --     for _, direction in ipairs(order) do
            --         if cell_empty(grid, x0 + 1, y0 + direction) then
            --             swap_cells(grid, x0, y0, x0 + 1, y0 + direction)
            --             break
            --         end
            --     end
            --     was_state_updated = true
            -- -- or spread horizontally
            -- elseif cell_empty(grid, x0, y0 - 1)
            --     or cell_empty(grid, x0, y0 + 1) then
            --     local order = ({{1, -1}, {-1, 1}})[math.random(1, 2)]
            --     for _, direction in ipairs(order) do
            --         if cell_empty(grid, x0, y0 + direction) then
            --             swap_cells(grid, x0, y0, x0, y0 + direction)
            --             break
            --         end
            --     end
            --     was_state_updated = true
            -- end
            ::continue::
        end
    end
    return was_state_updated
end

return M
