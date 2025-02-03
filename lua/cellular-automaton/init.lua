local M = {}

local manager = require("cellular-automaton.manager")

M.animations = {
  make_it_rain = require("cellular-automaton.animations.make_it_rain"),
  game_of_life = require("cellular-automaton.animations.game_of_life"),
  scramble = require("cellular-automaton.animations.scramble"),
}

local apply_default_options = function(config)
  local default = {
    name = "",
    update = function() end,
    init = function() end,
    fps = 50,
  }
  for k, v in pairs(config) do
    default[k] = v
  end
  return default
end

local get_random_animation = function()
  local keyset = {}
  for k in pairs(M.animations) do
    table.insert(keyset, k)
  end
  return M.animations[keyset[math.random(#keyset)]]
end

M.register_animation = function(config)
  -- "module" should implement update_grid(grid) method which takes 2D "grid"
  -- table of cells and updates it in place. Each "cell" is a table with following
  -- fields {"hl_group", "char"}
  if config.update == nil then
    error("Animation module must implement update function")
    return
  end
  if config.name == nil then
    error("Animation module must have 'name' field")
    return
  end

  M.animations[config.name] = apply_default_options(config)
end

M.start_animation = function(animation_name)
  local animation = animation_name and M.animations[animation_name] or get_random_animation()
  -- Make sure animaiton exists
  if animation == nil then
    error("Error while starting an animation. Unknown cellular-automaton animation: " .. animation_name)
  end
  -- Make sure nvim treesitter parser exists for current buffer
  local filetype = vim.bo.filetype
  local function raise_if_parser_missing()
    vim.treesitter.language.inspect(vim.treesitter.language.get_lang(filetype) or filetype)
  end
  local success, err = pcall(raise_if_parser_missing)
  if not success then
    error(
      "Error while starting an animation. Current buffer doesn't have associated tree-sitter parser for "
        .. filetype
        .. ".\n"
        .. err
    )
  end

  manager.execute_animation(animation)
end

return M
