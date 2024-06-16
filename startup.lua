local logging = require("logging")
term.clear()
term.setCursorPos(1, 1)
print("Sentien Turtle Version 0.1")
logging.startLoggingTab()


-- What do i need?
-- Sand -> Glass -> Glass Pane
-- Cobblestone -> Furnace -> Stone, Iron Ingot
-- Redstone
-- Iron Ore
-- Log -> Planks -> Chest, Crafting Table
-- Diamond -> Diamond Pickaxe
-- Sugar Cane -> Paper -> Floppy Disk

-- Floppy Disk = Redstone, Any Dye, Paper
-- -> Dye = Flowers
-- -> Paper = 3 Sugar Cane
-- Turtle = Iron Ingot, Computer, Chest
-- -> Iron Ingot = Furnace => Iron Ore
--  -> Furnace = Cobblestone, Cobbled Deepslate
-- -> Computer = Redstone, Stone, Glass Pane
--  -> Stone = Furnace => Cobblestone
--  -> Glass Pane = Glass
--   -> Glass = Furnace => Sand
-- -> Chest = Planks
--  -> Planks = Log

-- Ores to mine
-- Coal = 44
-- Iron, Diamond and Redstone = above bedrock


---
---@param question string
---@param inputValidation fun(input: string): any If the return value is nil, the input was invalid, else that value will be returned
---@return any
local function ask(question, inputValidation)
    assert(type(inputValidation) == "function", "The Input Validation function is not a function")
    local validReturn = nil
    while validReturn == nil do
        term.write(question)
        local result = read()
        local ok = inputValidation(result)
        if ok ~= nil then
            validReturn = ok
        else
            print("The input is invalid")
        end
    end

    return validReturn
end
local movement = require("movement")

local y = ask("Please input the current y height: ", tonumber)
local dir = ask("Direction: (n/s/w/e): ", movement.validate)

movement.init(y, dir)
logging.log(0, "Hello")

print("Start finding bedrock");


require("find_bedrock"):start();
