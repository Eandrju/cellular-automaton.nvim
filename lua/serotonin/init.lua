local M = {}

local animations = {
    make_it_rain = require("serotonin.animations.make_it_rain"),
    game_of_life = require("serotonin.animations.game_of_life")
}

local apply_default_options = function (config)
    local default = {
        name = "",
        update = function () end,
        init = function () end,
        context = {},
        fps = 50,
    }
    for k, v in pairs(config) do
        default[k] = v
    end
    return default
end

M.register_animation = function (config)
    -- "module" should implement update_grid(grid) method which takes 2D "grid"
    -- table of cells and update it inplace. Each "cell" is a table with following
    -- fields {"hl_group", "char"}
    if config.update_grid == nil then
        error("Animation module must implement update_grid function")
        return
    end
    if config.name == nil then
        error("Animation module must have 'name' field")
        return
    end

    animations[module.name] = apply_default_options(config)
end

M.start_animation = function(animation_name)
    if animations[animation_name] == nil then
        error("Unknown animation " .. animation_name)
    end
    require("serotonin.manager").execute_animation(animations[animation_name])
end

return M
