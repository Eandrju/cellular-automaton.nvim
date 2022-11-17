local M = {}

local printer = require("serotonin.render")
local loader = require("serotonin.load")

local function process_frame (grid, update_fn, clean_fn)
    local state_changed = update_fn(grid)
    printer.render_frame(grid)
    if state_changed then
        vim.defer_fn(
            function() process_frame(grid, update_fn, clean_fn) end, 20
        )
    else
        clean_fn()
    end
end

M.start_simulation = function(update_fn)
    local win_id = vim.api.nvim_get_current_win()
    local buf_id = vim.api.nvim_get_current_buf()
    local grid = loader.load_grid(win_id, buf_id)
    printer.open_window(win_id)
    process_frame(grid, update_fn, printer.clean)
end

return M
