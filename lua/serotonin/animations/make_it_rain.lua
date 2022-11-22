local common = require("serotonin.common")

local M = {}

M.fps = 20

local gravity = 0.1

local get_cell_center = function (x, y)
    return x + 0.5,  y + 0.5
end

local frame

M.init = function (grid)
    for i = 1, #grid do
        for j = 1, #(grid[i]) do
            grid[i][j].disperse_direction = 0
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
    -- grid[x1][y1].x, grid[x1][y1].y = get_cell_center(x1, y1)
    -- grid[x2][y2].x, grid[x2][y2].y = get_cell_center(x2, y2)
end

M.update = function (grid)
    -- local updated_grid = vim.deepcopy(grid)
    -- reset processed flag
    for i = 1, #grid, 1 do
        for j = 1, #(grid[i]) do
            grid[i][j].processed = false
        end
    end
    -- P(grid)
    local was_state_updated = false
    for x0 = #grid - 1, 1, -1 do
        for i = 1, #(grid[x0]) do
            -- iterate through grid from bottom to top using snake move
            -- >>>>>>>>>>>>
            -- ^<<<<<<<<<<<
            -- >>>>>>>>>>>^
            frame = frame + 1
            local y0
            if (frame + x0) % 2 == 0 then
                y0 = i
            else
                y0 = #(grid[x0]) + 1 - i
            end
            local cell = grid[x0][y0]

            -- skip spaces and comments or already proccessed cells
            if cell.char == " "
                or string.find(cell.hl_group, "comment")
                or cell.processed == true then
                goto continue
            end

            cell.processed = true

            -- to introduce some randomness sometimes step aside
            local random = math.random()
            if random < 0.05 then
                was_state_updated = true
                if cell_empty(grid, x0, y0 + 1) then
                    swap_cells(grid, x0, y0, x0, y0 + 1)
                end
            elseif random < 0.1 then
                was_state_updated = true
                if cell_empty(grid, x0, y0 - 1) then
                    swap_cells(grid, x0, y0, x0, y0 - 1)
                end
            end

            -- either go one down
            if cell_empty(grid, x0 + 1, y0) then
                swap_cells(grid, x0, y0, x0 + 1, y0)
                was_state_updated = true
            -- or down diagonally
            elseif cell_empty(grid, x0 + 1, y0 - 1)
                or cell_empty(grid, x0 + 1, y0 + 1) then
                local order = ({{1, -1}, {-1, 1}})[math.random(1, 2)]
                for _, direction in ipairs(order) do
                    if cell_empty(grid, x0 + 1, y0 + direction) then
                        swap_cells(grid, x0, y0, x0 + 1, y0 + direction)
                        break
                    end
                end
                was_state_updated = true
            -- or spread horizontally
            elseif cell_empty(grid, x0, y0 - 1)
                or cell_empty(grid, x0, y0 + 1) then
                local order = ({{1, -1}, {-1, 1}})[math.random(1, 2)]
                for _, direction in ipairs(order) do
                    if cell_empty(grid, x0, y0 + direction) then
                        swap_cells(grid, x0, y0, x0, y0 + direction)
                        break
                    end
                end
                was_state_updated = true
            --
            --
            --
            --
            --
            -- else
            --     local max_disperse = 3
            --     local dis_right, dis_left = 0, 0
            --     -- check how far can we go to the right
            --     for d = 1, max_disperse do
            --         if not cell_empty(updated_grid, x0, y0 + d) then
            --             break
            --         end
            --         dis_right = d
            --     end
            --     -- updated_grid[x0][y0].char = tostring(dis_right)
            --     -- -- check how far can we go to the left
            --     -- for d = 1, max_disperse do
            --     --     if not cell_empty(updated_grid, x0, y0 - d) then
            --     --         break
            --     --     end
            --     --     dis_left = d
            --     -- end
            --     --
            --     local found_empty_cell = false
            --     for i = 1, dis_right do
            --         if cell_empty(updated_grid, x0 + 1, y0 + i) then
            --             swap_cells(updated_grid, x0, y0, x0 + 1, y0 + i)
            --             was_state_updated = true
            --             found_empty_cell = true
            --             break
            --         end
            --     end
            --
            --     if found_empty_cell == false then
            --         -- print('moving horizontally', x0, y0, dis_right)
            --         swap_cells(updated_grid, x0, y0, x0, y0 + dis_right)
            --         was_state_updated = true
            --     end
            --
            --
            --     -- if cell.disperse_direction == 1 then
            --     --     if dis_right == 0 then
            --     --         cell.disperse_direction = 1
            --     --     else
            --     --         swap_cells(updated_grid, x0, y0, x0, y0 + dis_right)
            --     --         was_state_updated = true
            --     --     end
            --     -- elseif cell.disperse_direction == -1 then
            --     --     if dis_left == 0 then
            --     --         cell.disperse_direction = -1
            --     --     else
            --     --         swap_cells(updated_grid, x0, y0, x0, y0 - dis_left)
            --     --         was_state_updated = true
            --     --     end
            --     -- -- elseif dis_left < dis_right then
            --     -- --     swap_cells(grid, x0, y0, x0, y0 + dis_right)
            --     -- --     cell.disperse_direction = 1
            --     -- --     state_updated = true
            --     -- -- elseif dis_left > dis_right then
            --     -- --     swap_cells(grid, x0, y0, x0, y0 - dis_left)
            --     -- --     state_updated = true
            --     -- --     cell.disperse_direction = -1
            --     -- else
            --     --     local direction = ({1, -1})[math.random(1, 2)]
            --     --     cell.disperse_direction = direction
            --     --     local distance = direction * dis_left
            --     --     swap_cells(updated_grid, x0, y0, x0, y0 + distance)
            --     --     if distance > 0 then
            --     --         was_state_updated = true
            --     --     end
            --     -- end
            end
            ::continue::
        end
    end
    return was_state_updated
end

return M
