if 1 ~= vim.fn.has "nvim-0.8.0" then
  vim.api.nvim_err_writeln "Cellular-automaton.nvim requires at least nvim-0.8.0"
  return
end

if vim.g.loaded_serotonin == 1 then
  return
end
vim.g.loaded_serotonin = 1

-- TODO remove loop
local highlights = {
  SerotoninNormal = { default = true, link = "Normal" },
}

for k, v in pairs(highlights) do
  vim.api.nvim_set_hl(0, k, v)
end

vim.api.nvim_create_user_command("CellularAutomaton", function(opts)
  local sim_fn = require("cellular-automaton.animations.make_it_rain").update_state
  require("cellular-automaton").start_animation(sim_fn)
end, {})
