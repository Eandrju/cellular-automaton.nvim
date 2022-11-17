local M = {}

local window = nil
local buffers = nil

-- Each frame is rendered in different buffer to avoid flickering
-- caused by lack of higliths right after setting the buffer data. 
-- Thus we are switching between two buffers throught the simulation
local get_buffer = (function ()
    local count = 0
    return function ()
        count = count + 1
        return buffers[count % 2 + 1]
    end
end)()

M.open_window = function (host_window)
    buffers = {
        vim.api.nvim_create_buf(false, true),
        vim.api.nvim_create_buf(false, true),
    }
    local buffer = get_buffer()
    window = vim.api.nvim_open_win(buffer, true, {
        relative = "win",
        width = vim.api.nvim_win_get_width(host_window),
        height = vim.api.nvim_win_get_height(host_window),
        border = "none",
        win = host_window,
        row = 0,
        col = 0,
    })
    -- vim.api.nvim_win_set_option(window, "winhl", "Normal:SerotoninNormal")
    vim.api.nvim_win_set_option(window, "winhl", "Normal:TelescopeNormal")
end


M.render_frame = function (grid)
    local buffer = get_buffer()
    -- update data
    local lines = {}
    for _, row in ipairs(grid) do
        local chars = {}
        for _, cell in ipairs(row) do
            table.insert(chars, cell.char)
        end
        table.insert(lines, table.concat(chars, ''))
    end
    vim.api.nvim_buf_set_lines(
        buffer, 0, vim.api.nvim_win_get_height(window), false, lines
    )
    -- update highlights
    for i, row in ipairs(grid) do
        for j, cell in ipairs(row) do
            vim.api.nvim_buf_add_highlight(
                buffer, -1, cell.hl_group, i - 1, j - 1, j
            )
        end
    end
    -- swap buffers
    vim.api.nvim_win_set_buf(window, buffer)
end

M.clean = function ()
    vim.api.nvim_buf_delete(buffers[0], {force = true})
    vim.api.nvim_buf_delete(buffers[1], {force = true})
    window = nil
    buffers = nil
end

return M

