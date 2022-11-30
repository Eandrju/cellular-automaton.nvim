
local function setup_viewport(lines, win_options)
    local options = win_options or {}
    local buffnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffnr, 0, -1, false, lines)
    vim.api.nvim_win_set_buf(0, buffnr)
    for _, option in ipairs(options) do
        vim.cmd("set " .. option)
    end
end

describe("integration", function ()
    it("quiting with :q doesnt break next animations", function ()
        setup_viewport({"aaaaa", "     "}, {})
        vim.cmd("CellularAutomaton make_it_rain")
        vim.cmd("q")
        vim.cmd("CellularAutomaton make_it_rain")
    end)
end)
