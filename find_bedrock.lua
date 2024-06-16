local M = {}

local movement = require("movement")
local logging = require("logging")
local Level = logging.Level


local function check_bedrock()
    local ok, block = turtle.inspectDown()
    if ok then
        if block.name == "minecraft:bedrock" then
            logging.log(logging.Level.Info, "Found bedrock")
            return true
        end
    end
    return false
end

function M.start()
    while not check_bedrock() do
        if turtle.detectDown() then
            if not turtle.digDown("right") then
                logging.log(Level.Error, "Error: Could not dig down, abort")
                printError("Error: Could not dig down, abort")
                return false
            end
        end
        movement.down()
    end
    return true
end

return M