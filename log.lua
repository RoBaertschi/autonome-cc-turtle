
local logging = require("logging")


while true do
    local event, level, message = os.pullEvent("log_message")

    if level >= logging.Level.Warn then
        term.setTextColor(colors.orange)
        print(message)
        term.setTextColor(colors.white)
    elseif level >= logging.Level.Error then
        term.setTextColor(colors.red)
        print(message)
        term.setTextColor(colors.white)
    end
end