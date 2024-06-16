local M = {}

---@enum Level
M.Level = {
    Debug = 0,
    Info = 1,
    Warn = 2,
    Error = 3,
    Fatal = 4,
}

---@param text string
---@param level Level
function M.log(level, text)
    os.queueEvent("log_message", level, text)
end

local id = nil

function M.startLoggingTab()
    if multishell == nil then
        print("Non advanced turtle, disabeling logging")
        return
    end
    id = shell.openTab("log.lua")
end

return M
