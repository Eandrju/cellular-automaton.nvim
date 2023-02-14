# cellular-automaton.nvim
A useless plugin that might help you cope with stubbornly broken tests or overall lack of sense in life. It lets you execute aesthetically pleasing, cellular automaton animations based on the content of neovim buffer.

https://user-images.githubusercontent.com/37074839/204104990-6ebd7767-92e9-43b9-878a-3493a08a3308.mov


## What is cellular automata
From the [Wiki](https://en.wikipedia.org/wiki/Cellular_automaton):

> A cellular automaton is a model used in computer science and mathematics. The idea is to model a dynamic system by using a number of cells. 
> Each cell has one of several possible states. With each "turn" or iteration the state of the current cell is determined by two things: 
> its current state, and the states of the neighbouring cells.

## But.. why?
There is no pragmatic use case whatsoever. However, there are some pseudo-scientifically proven "use-cases":
- Urgent deadline approaches? Don't worry. With this plugin you can procrastinate even more!
- Are you stuck and don't know how to proceed? You can use this plugin as a visual stimulant for epic ideas!
- Those nasty colleagues keep peeking over your shoulder and stealing your code? Now you can obfuscate your editor! Good luck stealing that. 
- Working with legacy code? Just create a `<leader>fml` mapping and see it melt.

## Requirements
- neovim >= 0.8
- nvim-treesitter plugin

## Installation
```
use 'eandrju/cellular-automaton.nvim' 
```

## Usage
You can trigger it using simple command to run a random registered animation:
``` 
:CellularAutomaton
```
or specifying the animation name like:
```
:CellularAutomaton make_it_rain
```
or
```
:CellularAutomaton game_of_life
```
Or just create a mapping:
```lua
vim.keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>")
```
You can close animation window with one of: `q`/`<Esc>`/`<CR>`

## Known issues
- folding and wrapping is not supported ATM

## Supported animations
### Make it Rain

https://user-images.githubusercontent.com/37074839/204104990-6ebd7767-92e9-43b9-878a-3493a08a3308.mov

### Game of Life

https://user-images.githubusercontent.com/37074839/204162517-35b429ad-4cef-45b1-b680-bc7a69a4e8c7.mov


## Implementing your own cellular automaton logic
Using a simple interface you can implement your own cellular automaton animation. You need to provide a configuration table with an `update` function, which takes a 2D grid of cells and modifies it in place. Each cell by default consist of two fields: 
- `char` - single string character
- `hl_group` - treesitter's highlight group

Example sliding animation:
```lua
local config = {
    fps = 50,
    name = 'slide',
}

-- init function is invoked only once at the start
-- config.init = function (grid)
--
-- end

-- update function
config.update = function (grid)
    for i = 1, #grid do
        local prev = grid[i][#(grid[i])]
        for j = 1, #(grid[i]) do
            grid[i][j], prev = prev, grid[i][j]
        end
    end
    return true
end

require("cellular-automaton").register_animation(config)
```
Result:

https://user-images.githubusercontent.com/37074839/204161376-3b10aadd-90e1-4059-b701-ce318085622c.mov

## Inspiration and references
- https://www.youtube.com/watch?v=5Ka3tbbT-9E
- https://www.youtube.com/watch?v=prXuyMCgbTc



