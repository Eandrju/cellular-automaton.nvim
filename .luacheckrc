-- Rerun tests only if their modification time changed.
cache = true

std = luajit
codes = true

read_globals = {
  "vim",
  "assert",
}

ignore = {
  "212", -- Unused argument 
  "122", -- Indirectly setting a readonly global
}
