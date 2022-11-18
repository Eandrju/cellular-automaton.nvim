local M = {}

local ui = require("serotonin.ui")
local common = require("serotonin.common")

local function process_frame(grid, animation_config, win_id)
    -- quit if animation already interrupted
    if win_id == nil or not vim.api.nvim_win_is_valid(win_id) then
        return
    end
    -- proccess frame
    ui.render_frame(grid)
    local render_at = common.time()
    local state_changed = animation_config.update(grid)

    -- schedule next frame
    local fps = animation_config.fps or 50
    local time_since_render = common.time() - render_at
    local timeout = math.max(0, 1000 / fps - time_since_render)
    if state_changed then
        vim.defer_fn(
            function () 
                process_frame(grid, animation_config, win_id)
            end,
            timeout
        )
    end
end

M.execute_animation = function(animation_config)
    local host_win_id = vim.api.nvim_get_current_win()
    local host_bufnr = vim.api.nvim_get_current_buf()
    local grid = require("serotonin.load").load_base_grid(host_win_id, host_bufnr)
    if animation_config.init ~= nil then
        animation_config.init(grid)
    end
    local win_id = ui.open_window(host_win_id)
    process_frame(grid, animation_config, win_id)
end

return M
