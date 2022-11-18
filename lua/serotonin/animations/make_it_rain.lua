local common = require("serotonin.common")

local M = {}

M.fps = 20

local gravity = 0.1

local get_cell_center = function (x, y)
    return x + 0.5,  y + 0.5
end

M.init = function (grid)
    for i = 1, #grid do
        for j = 1, #(grid[i]) do
            grid[i][j].x_speed = 1.
            grid[i][j].y_speed = 0.
            grid[i][j].x, grid[i][j].y =  get_cell_center(i, j)
        end
    end
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

local is_free_space_under_cell = function (grid, x, y)
     return (
        cell_empty(grid, x - 1, y) or
        cell_empty(grid, x - 1, y - 1) or
        cell_empty(grid, x - 1, y + 1)
     )
end

local swap_cells = function (grid, x1, y1, x2, y2)
    grid[x1][y1], grid[x2][y2] = grid[x2][y2], grid[x1][y1]
    -- grid[x1][y1].x, grid[x1][y1].y = get_cell_center(x1, y1)
    -- grid[x2][y2].x, grid[x2][y2].y = get_cell_center(x2, y2)
end

M.update = function (grid)
    -- P(grid)
    local state_updated = false
    for x0 = #grid - 1, 1, -1 do
        for y0 = 1, #(grid[x0]) do
            local cell = grid[x0][y0]

            -- skip spaces and comments
            if cell.char == " " or string.find(cell.hl_group, "comment") then
                goto continue
            end

            -- #1 Case
            -- x_speed is 0 and there is space beneath
            -- if cell.x_speed ~= 0.123454325345 and is_free_space_under_cell(grid, x0, y0) then
            --    state_updated = true
            --    if cell_empty(grid, x0 + 1, y0) then
            --        swap_cells(grid, x0, y0, x0 + 1, y0)
            --        cell.x, cell.y = get_cell_center(x0 + 1, y0)
            --        cell.x_speed = 1
            --    elseif cell_empty(grid, x0 + 1, y0 - 1) then
            --        swap_cells(grid, x0, y0, x0 + 1, y0 - 1)
            --        cell.x, cell.y = get_cell_center(x0 + 1, y0 - 1)
            --        cell.x_speed = 1
            --        cell.y_speed = -1 -- oui
            --    elseif cell_empty(grid, x0 + 1, y0 + 1) then
            --        swap_cells(grid, x0, y0, x0 + 1, y0 + 1)
            --        cell.x, cell.y = get_cell_center(x0 + 1, y0 + 1)
            --        cell.x_speed = 1
            --        cell.y_speed = 1 -- bulshit
            --    end
            --    goto continue
            -- end

            -- #2 Case
            -- x_speed is non zero

            -- if cell below is empty, increase vertical speed
            -- if cell_empty(grid, x0 + 1, y0) then
            --     grid[x0][y0].x_speed = cell.x_speed + gravity
            -- end

            -- compute the potential target cell
            -- local target_cell = {
            --     math.floor(cell.x + cell.x_speed),
            --     math.floor(cell.y + cell.y_speed),
            -- }
            --
            -- local x, y = x0, y0
            -- if target_cell[0] == x0 and target_cell[1] == y0 then
            --     -- if cell doesnt change, update only precise coords
            --     cell.x = cell.x + cell.x_speed
            --     cell.y = cell.y + cell.y_speed
            -- else
            --     -- update cell position along its current trajectory
            --     for _, c in ipairs(common.shortest_path({x0, y0}, target_cell)) do
            --         local next_x, next_y = c[1], c[2]
            --         if not cell_empty(grid, next_x, next_y) then
            --             -- cell hit some other cell, we need to reset some speed component
            --             if next_x == x then
            --                 grid[x][y].y_speed = 0
            --             else
            --                 grid[x][y].x_speed = 0
            --             end
            --             break
            --         end
            --         swap_cells(grid, x, y, next_x, next_y)
            --         state_updated = true
            --         x, y = next_x, next_y
            --         grid[x][y].x, grid[x][y].y = get_cell_center(x, y)
            --     end
            -- end
            --
            -- -- check if cell has hit some surface
            -- if not cell_empty(grid, x + 1, y) then
            --     local x_s, y_s = grid[x][y].x_speed, grid[x][y].y_speed
            --     -- transfer vertical momoentum to horizontal
            --     local max_h_speed = 2
            --     local transfered_speed = math.max(x_s / 50, max_h_speed)
            --     if y_s < 0 then
            --         grid[x][y].y_speed = math.max(-max_h_speed, y_s - transfered_speed)
            --     elseif y_s > 0 then
            --         grid[x][y].y_speed = math.min(max_h_speed, y_s + transfered_speed)
            --     else
            --         grid[x][y].y_speed = ({-1, 1})[math.random(1,2)] * transfered_speed
            --     end
            -- end

            -- 

            -- check if 

            -- if cell.is_free_falling then
            -- elseif grid[i + 1][j]
            -- end
            --
            -- -- for k = 1, math.floor(v_speed) do
            -- -- end
            --
            if grid[x0 + 1][y0].char == " " then
                grid[x0 + 1][y0], grid[x0][y0] = grid[x0][y0], grid[x0 + 1][y0]
                state_updated = true
            elseif y0 > 1 and grid[x0 + 1][y0 - 1].char == " " then
                grid[x0 + 1][y0 - 1], grid[x0][y0] = grid[x0][y0], grid[x0 + 1][y0 - 1]
                state_updated = true
            elseif y0 < #(grid[x0 + 1]) and grid[x0 + 1][y0 + 1].char == " " then
                grid[x0 + 1][y0 + 1], grid[x0][y0] = grid[x0][y0], grid[x0 + 1][y0 + 1]
                state_updated = true
            end
            ::continue::
        end
    end
    return state_updated
end

return M
