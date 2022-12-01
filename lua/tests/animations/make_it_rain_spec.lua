local assert = require("luassert")
local m = require("cellular-automaton.animations.make_it_rain")
local c = require("tests.animations.common")

local get_grid = function(pattern)
  local grid = c.get_grid(pattern)
  m.init(grid)
  m.side_noise = false
  m.disperse_rate = 2
  return grid
end

describe("make_it_rain", function()
  it("cell prefers falling down than going sideways", function()
    local grid = get_grid({
      " x ",
      "   ",
    })
    m.update(grid)
    c.assert_grid_same(grid, {
      "   ",
      " x ",
    })
  end)

  describe("cell with right disperse direction behaviour", function()
    it("basic cases", function()
      local cases = {
        {
          initial = {
            " x   ",
            " #   ",
          },
          expected = {
            "     ",
            " # x ",
          },
        },
        {
          initial = {
            " x   ",
            " # # ",
          },
          expected = {
            "     ",
            " #x# ",
          },
        },
        {
          initial = {
            " x   ",
            " ### ",
          },
          expected = {
            "   x ",
            " ### ",
          },
        },
        {
          initial = {
            " x # ",
            " ### ",
          },
          expected = {
            "  x# ",
            " ### ",
          },
        },
        {
          initial = {
            " x## ",
            " ### ",
          },
          expected = {
            " x## ",
            " ### ",
          },
        },
      }
      for _, case in ipairs(cases) do
        local grid = get_grid(case.initial)
        grid[1][2].disperse_direction = 1
        m.update(grid)
        c.assert_grid_same(grid, case.expected)
      end
    end)

    it("switches disperse_direction to right if was blocked horizontally", function()
      local grid = get_grid({
        "#x ",
        "###",
      })
      grid[1][2].disperse_direction = -1
      m.update(grid)
      assert.are.equal(grid[1][2].disperse_direction, 1)
    end)
  end)

  describe("cell with left disperse direction behaviour", function()
    it("basic cases", function()
      local cases = {
        {
          initial = {
            "   x ",
            "   # ",
          },
          expected = {
            "     ",
            " x # ",
          },
        },
        {
          initial = {
            "   x ",
            " # # ",
          },
          expected = {
            "     ",
            " #x# ",
          },
        },
        {
          initial = {
            "   x ",
            " ### ",
          },
          expected = {
            " x   ",
            " ### ",
          },
        },
        {
          initial = {
            " # x ",
            " ### ",
          },
          expected = {
            " #x  ",
            " ### ",
          },
        },
        {
          initial = {
            " ##x ",
            " ### ",
          },
          expected = {
            " ##x ",
            " ### ",
          },
        },
      }
      for i, case in ipairs(cases) do
        local grid = get_grid(case.initial)
        grid[1][4].disperse_direction = -1
        m.update(grid)
        c.assert_grid_same(grid, case.expected, "Fked up case: " .. i)
      end
    end)

    it("switches disperse_direction to right if was blocked horizontally", function()
      local grid = get_grid({
        "#x ",
        "###",
      })
      grid[1][2].disperse_direction = -1
      m.update(grid)
      assert.are.equal(grid[1][2].disperse_direction, 1)
    end)
  end)

  it("cell with nil disperse direction falls to randomly chosen side", function()
    local grid = get_grid({
      " x ",
      " # ",
    })
    m.update(grid)
    c.assert_grid_different(grid, {
      " x ",
      " # ",
    })
  end)
end)
