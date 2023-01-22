local mock = require("luassert.mock")

local function setup_viewport(lines, win_options)
  local options = win_options or {}
  local buffnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffnr, 0, -1, false, lines)
  vim.api.nvim_win_set_buf(0, buffnr)
  for _, option in ipairs(options) do
    vim.cmd("set " .. option)
  end
end

describe("integration", function()
  local mocked_treesitter = nil
  before_each(function()
    require("cellular-automaton.manager").clean()
    mocked_treesitter = mock(require("nvim-treesitter.parsers"), true)
    mocked_treesitter.has_parser.returns(true)
  end)

  it("unhandled error doesn't break next animations", function()
    local test_animation = {
      name = "test",
      update = function()
        error("test error")
      end,
    }
    require("cellular-automaton").register_animation(test_animation)
    setup_viewport({ "aaaaa", "     " }, {})
    local ok, _ = pcall(vim.cmd, "CellularAutomaton test")
    assert.is_false(ok)
    vim.cmd("CellularAutomaton make_it_rain")
  end)

  it("quiting with :q doesnt break next animations", function()
    vim.cmd("CellularAutomaton make_it_rain")
    setup_viewport({ "aaaaa", "     " }, {})
    vim.cmd("q")
    vim.cmd("CellularAutomaton make_it_rain")
  end)

  it("'list' window option is turned off to prevent marking trailing spaces", function()
    vim.cmd("set list")
    vim.cmd("CellularAutomaton make_it_rain")
    assert.is_false(vim.api.nvim_win_get_option(0, "list"))
  end)

  it("raises an error if treesitter parser is missing", function()
    mocked_treesitter.has_parser.returns(false)
    local ok, _ = pcall(vim.cmd, "CellularAutomaton make_it_rain")
    assert.is_false(ok)
  end)
end)
