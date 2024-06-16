local logging = require("logging")
term.clear()
term.setCursorPos(1, 1)
print("Sentien Turtle Version 0.1")
logging.startLoggingTab()

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


require("find_bedrock").start();