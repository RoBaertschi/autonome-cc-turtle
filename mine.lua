local M = {}

local movement = require("movement")
local logging = require("logging")
local Level = logging.Level
local im = require("item_manager")
local refuel = require("refuel")


function M:handle_fuel_status()
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

---comment
---@param ores string[]
function M:start(ores)
    logging.log(Level.Info, "Start mining for " .. ores)

    while not im:miningDone() do

    end
end

return M
