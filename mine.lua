local M = {}

local movement = require("movement")
local logging = require("logging")
local Level = logging.Level
local im = require("item_manager")
local refuel = require("refuel")


function M:handleFuelStatus()
    if turtle.getFuelLevel() > settings.get("fuel_refill", 280) then
        local current_y = movement.getY()
        refuel:start()

        while current_y ~= movement.getY() do
            if current_y > movement.getY() then
                movement.up()
            else
                movement.down()
            end
        end
    end
end

local OresToMine = {
    "minecraft:iron_ore",
    "minecraft:deepslate_iron_ore",
    "minecraft:redstone_ore",
    "minecraft:deepslate_redstone_ore",
    "minecraft:lapis_ore",
    "minecraft:deepslate_lapis_ore",
}
---@param blockName string
function M:mineVein(blockName)
    local initial = movement.getState()

    ---@type Vec[]
    local ores = {}

    local function getOres()
        local state = movement.getState()

        local is, block = turtle.inspect()
        if is then
            if block.name == blockName then
                local x, z = movement.directionToPos(state.direction)
                table.insert(ores, { x = state.x + x, z = state.z + z, y = state.y })
            end
        end

        is, block = turtle.inspectUp()
        if is then
            if block.name == blockName then
                table.insert(ores, { x = state.x, z = state.z, y = state.y + 1 })
            end
        end

        is, block = turtle.inspectDown()
        if is then
            if block.name == blockName then
                table.insert(ores, { x = state.x, z = state.z, y = state.y - 1 })
            end
        end

        movement.turnLeft()
        state = movement.getState()
        is, block = turtle.inspect()
        if is then
            if block.name == blockName then
                local x, z = movement.directionToPos(state.direction)
                table.insert(ores, { x = state.x + x, z = state.z + z, y = state.y })
            end
        end

        movement.turnRight()
        movement.turnRight()
        state = movement.getState()
        is, block = turtle.inspect()
        if is then
            if block.name == blockName then
                local x, z = movement.directionToPos(state.direction)
                table.insert(ores, { x = state.x + x, z = state.z + z, y = state.y })
            end
        end
    end
end

---@param block ccTweaked.turtle.inspectInfo
function M:handleBlock(block)
    local veinFound = false
    for _, ore in ipairs(OresToMine) do
        if block.name == ore then
            veinFound = true
            self:mineVein(block.name)
            break
        end
    end

    if not veinFound then
        turtle.dig("right")
        movement.forward()
    end
end

function M:mine()
    local is, block = turtle.inspect()
    if is then
        ---@diagnostic disable-next-line: param-type-mismatch
        self:handleBlock(block)
    else
        movement.forward()
    end
end

---@param ores string[]
function M:start(ores)
    logging.log(Level.Info, "Start mining for " .. ores)

    while not im:miningDone() do
        self:mine()
    end
end

return M
