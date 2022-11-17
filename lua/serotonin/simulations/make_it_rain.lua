local M = {}

M.update_state = function (grid)
    local state_updated = false
    for i = #grid - 1, 1, -1 do
        for j = 1, #(grid[i]) do
            local cell = grid[i][j]
            if cell.char == " " or string.find(cell.hl_group, "comment") then
                goto continue
            end
            if grid[i + 1][j].char == " " then
                grid[i + 1][j], grid[i][j] = grid[i][j], grid[i + 1][j]
                state_updated = true
            elseif j > 1 and grid[i + 1][j - 1].char == " " then
                grid[i + 1][j - 1], grid[i][j] = grid[i][j], grid[i + 1][j - 1]
                state_updated = true
            elseif j < #(grid[i + 1]) and grid[i + 1][j + 1].char == " " then
                grid[i + 1][j + 1], grid[i][j] = grid[i][j], grid[i + 1][j + 1]
                state_updated = true
            end
            ::continue::
        end
    end
    return state_updated
end

return M
