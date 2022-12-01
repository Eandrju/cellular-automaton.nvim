local M = {}

-- get milisecs from some arbitray point in time
M.time = function()
  return vim.fn.reltimefloat(vim.fn.reltime()) * 1000
end

M.round = function(x)
  return math.floor(x + 0.5)
end

return M
