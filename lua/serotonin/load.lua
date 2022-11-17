local M = {}

local get_dominant_hl_group = function (buffer, i, j)
    local captures = vim.treesitter.get_captures_at_pos(buffer, i - 1 , j - 1)
    for c = #captures, 1, -1 do
        if captures[c].capture ~= "spell" and captures[c].capture ~= "@spell" then
            return "@" .. captures[c].capture
        end
    end
    return ""
end

M.load_grid = function (window, buffer)
    local view_range = {start = vim.fn.line('w0') - 1, end_ = vim.fn.line('w$')}
    -- initialize the grid
    local grid = {}
    for i = 1, vim.api.nvim_win_get_height(window) do
        grid[i] = {}
        for j = 1, vim.api.nvim_win_get_width(window) do
            grid[i][j] = {char = " ", hl_group = ""}
        end
    end
    local data = vim.api.nvim_buf_get_lines(
        buffer, view_range.start, view_range.end_, true
    )
    -- update with buffer data
    for i, line in ipairs(data) do
        for j = 1, string.len(line) do
            grid[i][j].char = string.sub(line, j, j)
            grid[i][j].hl_group = get_dominant_hl_group(
                buffer, view_range.start + i, j
            )
        end
    end
    return grid
end


return M
