local m = require "serotonin.animations.make_it_rain"
local c = require "tests.animations.common"
-- local c = require "serotonin.testharness.animations.common"
--

local get_grid = function (pattern)
        local grid = c.get_grid(pattern)
        m.init(grid)
        m.side_noise = false
        return grid
end

describe("make_it_rain", function()
    it("can be required", function()
        require("serotonin")
    end)

    it("cell falls down if it can", function()
        local grid = get_grid({
            " x ",
            "   ",
        })
        m.update(grid)
        c.assert_grid_equals(grid, {
            "   ",
            " x ",
        })
    end)

    it("cell with right disperse direction falls right-down", function()
        local grid = get_grid({
            " x ",
            " # ",
        })
        grid[1][2].disperse_direction = 1
        m.update(grid)
        c.assert_grid_equals(grid, {
            "   ",
            " #x",
        })
    end)

    it("cell with right disperse direction falls right-right-down", function()
        local grid = get_grid({
            " x  ",
            " ## "
        })
        grid[1][2].disperse_direction = 1
        m.update(grid)
        c.assert_grid_equals(grid, {
            "    ",
            " ##x",
        })
    end)

    it("cell with right disperse direction moves right", function()
        local grid = get_grid({
            " x #",
            " ###"
        })
        grid[1][2].disperse_direction = 1
        m.update(grid)
        c.assert_grid_equals(grid, {
            "  x#",
            " ###",
        })
    end)

    it("cell with nil disperse direction falls to randomly chosen side", function()
        local grid = get_grid({
            " x ",
            " # "
        })
        m.update(grid)
        c.assert_grid_different(grid, {
            " x ",
            " # ",
        })
    end)

    it("cell moves 3 cells to the right if none is available at lower level", function()
        local grid = get_grid({
            "##x     ",
            "####### ",
        })
        m.update(grid)
        c.assert_grid_equals(grid, {
            "##   x  ",
            "####### ",
        })
    end)
end)
