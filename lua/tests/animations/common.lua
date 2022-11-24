local common = {}

common.get_grid = function (pattern)
    local grid = {}
    for _, line in ipairs(pattern) do
        local row = {}
        for i = 1, #line do
            local char = line:sub(i, i)
            local cell = {char = char}
            if char == "#" then
                cell.hl_group = "@comment"
            end
            table.insert(row, cell)
        end
        table.insert(grid, row)
    end
    return grid
end

local extract_only_chars_from_grid = function (grid)
    local only_chars_grid = {}
    for i, row in ipairs(grid) do
        table.insert(only_chars_grid, {})
        for j, cell in ipairs(row) do
            only_chars_grid[i][j] = {char = cell.char}
        end
    end
    return only_chars_grid
end

common.assert_grid_equals = function (grid, pattern)
    local received_grid = extract_only_chars_from_grid(grid)
    local expected_grid = extract_only_chars_from_grid(common.get_grid(pattern))
    assert.are.same(received_grid, expected_grid)
end

common.assert_grid_different = function (grid, pattern)
    local received_grid = extract_only_chars_from_grid(grid)
    local expected_grid = extract_only_chars_from_grid(common.get_grid(pattern))
    assert.are.not_.same(received_grid, expected_grid)
end

return common
