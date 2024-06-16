---@enum Direction
local Direction = {
    North = 0,
    East = 1,
    South = 2,
    West = 3,
}


local State = {
    ---@type integer
    x = 0,
    ---@type integer
    y = 0,
    ---@type integer
    z = 0,
    ---@type Direction
    direction = Direction.North,
}
local M = {}

---Initializes the movement state with the required arguments
---@param y integer
---@param dir Direction
function M.init(y, dir)
    State.y = y
    State.direction = dir
end

function M.up()
    State.y = State.y + 1
    return turtle.up()
end

function M.down()
    State.y = State.y - 1
    return turtle.down()
end

---@param direction Direction
---@return integer, integer
function M.directionToPos(direction)
    if direction == Direction.North then
        return 0, -1
    elseif direction == Direction.South then
        return 0, 1
    elseif direction == Direction.West then
        return -1, 0
    else
        return 1, 0
    end
end

function M.forward()
    local x, z = M.directionToPos(State.direction)
    State.x = x + State.x
    State.z = z + State.z
    return turtle.forward()
end

function M.turnLeft()
    State.direction = State.direction - 1
    if State.direction < Direction.North then
        State.direction = Direction.West
    end
    return turtle.turnLeft()
end

function M.turnRight()
    State.direction = State.direction + 1
    if State.direction > Direction.West then
        State.direction = Direction.North
    end
    return turtle.turnRight()
end

function M.validate(input)
    if input == "n" then
        return Direction.North
    elseif input == "s" then
        return Direction.South
    elseif input == "w" then
        return Direction.West
    elseif input == "e" then
        return Direction.East
    end
    return nil
end

function M.getY()
    return State.y
end

---@return {x: integer, y: integer, z: integer, direction: Direction}
function M.getState()
    return State
end

return M
