if 1 ~= vim.fn.has("nvim-0.9.0") then
  vim.api.nvim_err_writeln("Cellular-automaton.nvim requires at least nvim-0.9.0")
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
