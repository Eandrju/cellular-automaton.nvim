local assert = require("luassert")
local l = require("cellular-automaton.load")
local mock = require("luassert.mock")

local function setup_viewport(win_height, win_width, lines, ver_scroll, hor_scroll, win_options)
  local options = win_options or {}
  -- split the windows so that the main is resizable
  vim.api.nvim_command("bufdo bwipeout!")
  vim.api.nvim_command("vsplit")
  vim.api.nvim_command("split")
  local buffnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffnr, 0, -1, false, lines)
  vim.api.nvim_win_set_buf(0, buffnr)
  vim.api.nvim_win_set_width(0, win_width)
  vim.api.nvim_win_set_height(0, win_height)
  if ver_scroll > 0 then
    vim.cmd(string.format([[exec "normal! %s\<C-e>"]], ver_scroll))
  end
  -- set nowrap - otherwise horizontall scrolling doesnt work
  vim.opt.wrap = false
  if hor_scroll > 0 then
    vim.cmd(string.format([[exec "normal! %szl"]], hor_scroll))
  end
  for _, option in ipairs(options) do
    vim.cmd("set " .. option)
  end
end

describe("load_base_grid", function()
  local window_option_cases = {
    {
      options = {
        "numberwidth=4",
        "relativenumber",
        "number",
        "foldcolumn=0",
        "signcolumn=yes",
      },
      side_col_width = 4 + 2,
    },
    {
      options = {
        "numberwidth=4",
        "norelativenumber",
        "nonumber",
        "foldcolumn=1",
        "signcolumn=yes",
      },
      side_col_width = 2 + 1,
    },
    {
      options = {
        "numberwidth=3",
        "number",
        "norelativenumber",
        "foldcolumn=0",
        "signcolumn=no",
      },
      side_col_width = 3,
    },
    {
      options = {
        "numberwidth=5",
        "relativenumber",
        "number",
        "foldcolumn=2",
        "signcolumn=no",
      },
      side_col_width = 5 + 2,
    },
  }

  describe("hl_groups", function()
    it("gets treesitter's captures for correct position", function()
      local treesitter = mock(vim.treesitter, true)
      treesitter.get_captures_at_pos.returns({})
      setup_viewport(
        1,
        1,
        { "123", "456", "abc" },
        2,
        2,
        { "nonumber", "norelativenumber", "signcolumn=no", "noshowmode", "noshowcmd" }
      )
      l.load_base_grid(0, 0)
      assert.stub(treesitter.get_captures_at_pos).was_called_with(0, 2, 2)
      mock.revert(treesitter)
    end)
  end)

  describe("chars", function()
    it("loads grid from viewport", function()
      for idx, case in ipairs(window_option_cases) do
        local width = 20
        local height = 10
        setup_viewport(height, width, { "1234", "56789" }, 0, 0, case.options)
        local grid = l.load_base_grid(0, 0)
        assert.equals(height, #grid, idx)
        assert.equals(width - case.side_col_width, #grid[1], idx)
        assert.same("1", grid[1][1].char, idx)
        assert.same("9", grid[2][5].char, idx)
      end
    end)

    it("loads grid when buffer content is wider than viewport ", function()
      for idx, case in ipairs(window_option_cases) do
        local width = 10
        local height = 20
        setup_viewport(height, width, { "1234567890abcde" }, 0, 0, case.options)
        local grid = l.load_base_grid(0, 0)
        assert.equals(height, #grid, idx)
        assert.equals(width - case.side_col_width, #grid[1], idx)
        assert.same("3", grid[1][3].char, idx)
      end
    end)

    it("loads grid when buffer content is longer than viewport ", function()
      for idx, case in ipairs(window_option_cases) do
        local width = 10
        local height = 3
        setup_viewport(height, width, { "1", "2", "3", "4", "5" }, 0, 0, case.options)
        local grid = l.load_base_grid(0, 0)
        assert.equals(height, #grid, idx)
        assert.equals(width - case.side_col_width, #grid[1], idx)
        assert.same("3", grid[3][1].char, idx)
      end
    end)

    it("loads grid from vertically scrolled viewport", function()
      for idx, case in ipairs(window_option_cases) do
        local width = 10
        local height = 3
        setup_viewport(height, width, { "1", "2", "3", "4", "5" }, 2, 0, case.options)
        local grid = l.load_base_grid(0, 0)
        assert.equals(height, #grid, idx)
        assert.equals(width - case.side_col_width, #grid[1], idx)
        assert.same("3", grid[1][1].char, idx)
        assert.same("5", grid[3][1].char, idx)
      end
    end)

    it("loads grid from horizontally scrolled viewport", function()
      for idx, case in ipairs(window_option_cases) do
        local width = 10
        local height = 3
        setup_viewport(height, width, { "1234567890abcde" }, 0, 2, case.options)
        local grid = l.load_base_grid(0, 0)
        assert.equals(height, #grid, idx)
        assert.equals(width - case.side_col_width, #grid[1], idx)
        assert.same("3", grid[1][1].char, idx)
      end
    end)
  end)
end)
