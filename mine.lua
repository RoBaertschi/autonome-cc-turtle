
local M = {}

local movement = require("movement")
local logging = require("logging")
local Level = logging.Level



---comment
---@param ores string[]
function M.start(ores)
    logging.log(Level.Info, "Start mining for " .. ores)


    for i=1,#ores do
        local ore = ores[i]
    end
end

return M