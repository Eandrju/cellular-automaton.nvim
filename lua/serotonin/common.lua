local M = {}

-- get milisecs from some arbitray point in time
M.time = function ()
    return vim.fn.reltimefloat(vim.fn.reltime()) * 1000
end

M.round = function (x)
    return math.floor(x + 0.5)
end

-- copied from DavidMcLaughlin208
-- returns path of matrix cells from point1 to point2
-- example: 
-- shortest_path({0, -2}, {4, 0}) => {{1, -1}, {2, -1}, {3, 0}, {4, 0}}
--
--           0 1 2 3 4
--         0       * B
--         1   * *
--         2 A
--
M.shortest_path = function (point1, point2)
    local points = {}
    local x1, y1 = point1[1], point1[2]
    local x2, y2 = point2[1], point2[2]

    if x1 == x2 and y1 == y2 then
        return points
    end

    local x_diff = x1 - x2
    local y_diff = y1 - y2
    local x_diff_is_larger = math.abs(x_diff) > math.abs(y_diff)

    local x_modifier, y_modifier
    if x_diff < 0 then
        x_modifier = 1
    else
        x_modifier = -1
    end
    if y_diff < 0 then
        y_modifier = 1
    else
        y_modifier = -1
    end

    local longer_side_length = math.max(math.abs(x_diff), math.abs(y_diff))
    local shorter_side_length = math.min(math.abs(x_diff), math.abs(y_diff))
    local slope
    if shorter_side_length == 0 or longer_side_length == 0 then
        slope = 0
    else
        slope = shorter_side_length / longer_side_length
    end

    for i = 1, longer_side_length do
        local shorter_side_increase = M.round(i * slope)
        local y_increase, x_increase
        if x_diff_is_larger then
            x_increase = i
            y_increase = shorter_side_increase
        else
            x_increase = shorter_side_increase
            y_increase = i
        end
        table.insert(points, {
            x1 + x_increase * x_modifier,
            y1 + y_increase * y_modifier
        })
    end
    return points
end

return M
