if 1 ~= vim.fn.has("nvim-0.8.0") then
  vim.api.nvim_err_writeln("Cellular-automaton.nvim requires at least nvim-0.8.0")
  return
end

local ok, _ = pcall(require, "nvim-treesitter")
if not ok then
  vim.api.nvim_err_writeln("Cellular-automaton.nvim requires nvim-treesitter/nvim-treesitter plugin to be installed.")
  return
end

if vim.g.loaded_cellular_automaton == 1 then
  return
end
vim.g.loaded_cellular_automaton = 1

vim.api.nvim_set_hl(0, "CellularAutomatonNormal", { default = true, link = "Normal" })

vim.api.nvim_create_user_command("CellularAutomaton", function(opts)
  require("cellular-automaton").start_animation(opts.fargs[1])
end, {
  nargs = 1,
  complete = function(_, line)
    local animation_list = vim.tbl_keys(require("cellular-automaton").animations)
    local l = vim.split(line, "%s+", {})

    if #l == 2 then
      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[2])
      end, animation_list)
    end
  end,
})
