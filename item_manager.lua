local M = {
    -- Disable, when not mining anymore
    disabled = false,
}

---@type {item: string, has_tags?: string, max_needed: number}[]
local ItemsNeeded = {
    -- Furnace, Stone
    { item = "minecraft:cobblestone",  max_needed = 64 },
    { item = "minecraft:redstone",     max_needed = 64 },
    { item = "minecraft:coal",         max_needed = 64 },
    { item = "minecraft:diamond",      max_needed = 64 },
    { item = "minecraft:raw_iron",     max_needed = 64 },
    { item = "",                       has_tags = "minecraft:logs", max_needed = 64 },
    { item = "minecraft:chest",        max_needed = 64 },
    { item = "minecraft:sand",         max_needed = 64 },
    { item = "minecraft:lapis_lazuli", max_needed = 64 },
    { item = "minecraft:sugar_cane",   max_needed = 64 },
}

---@type {slot: number, count: number}[]
local CheckedSlots = {}

---Check if val is in tab
---@param tab table
---@param val any
---@return boolean
local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

---Check if key_to_find is in the table
---@param tab table
---@param key_to_find any
---@return boolean
local function has_key(tab, key_to_find)
    for key, _ in pairs(tab) do
        if key == key_to_find then
            return true
        end
    end
    return false
end

---Gets item with the tag or name from the ItemsNeeded list
---@param name_or_tag string
---@return { item: string, has_tags: string|nil, max_needed: number }|nil
local function get_item(name_or_tag)
    for _, value in ipairs(ItemsNeeded) do
        if value.item == name_or_tag or value.has_tags == name_or_tag then
            return value
        end
    end
    return nil
end

function M:clean_inventory()
    ---@type { [string]: integer }
    local to_clean = {}
    for _, slot in ipairs(CheckedSlots) do
        local detail = turtle.getItemDetail(slot.slot, false)

        if detail == nil then
            goto continue
        end

        if to_clean[detail.name] == nil then
            to_clean[detail.name] = detail.count
        else
            to_clean[detail.name] = to_clean[detail.name] + detail.count

            local item = get_item(detail.name)
            if item == nil then
                for _, tag in ipairs(turtle.getItemDetail(slot.slot, true).tags) do
                    item = get_item(tag)
                    if item == nil then
                        goto item_found
                    end
                end
                goto continue
                ::item_found::
            end

            if to_clean[detail.name] > item.max_needed then
                M.removeFromInventory(slot.slot, to_clean[detail.name] - item.max_needed)
                to_clean[detail.name] = to_clean[detail.name] - item.max_needed
            end
        end
        ::continue::
    end
end

---Tries in any possible way to drop an item
---@param slot ccTweaked.turtle.slot
---@param amount integer?
function M.removeFromInventory(slot, amount)
    turtle.select(slot)

    local function digAndTryUp()
        if not turtle.digUp("right") and turtle.dropUp(amount) then
            return false
        end
        return true
    end

    local function digAndTryDown()
        if not turtle.digDown("right") and turtle.dropDown(amount) then
            return false
        end
        return true
    end

    local function digAndTry()
        if not turtle.dig("right") and turtle.drop(amount) then
            return false
        end
        return true
    end

    if not turtle.drop(amount) then
        if not turtle.dropDown(amount) then
            if not turtle.dropUp(amount) then
                if not digAndTry() then
                    if not digAndTryUp() then
                        if not digAndTryDown() then
                            printError("Error: Could not drop item in slot " .. slot .. " in any way easely possible")
                        end
                    end
                end
            end
        end
    end
end

function M:update()
    for i = 1, 16, 1 do
        if not has_value(CheckedSlots, i) then
            turtle.select(i)
            local item_info = turtle.getItemDetail(i, true)


            if item_info ~= nil then
                for _, tab in ipairs(ItemsNeeded) do
                    if item_info.tags[tab.has_tags] then
                        table.insert(CheckedSlots, { slot = i, count = item_info.count })
                        goto continue
                    end
                    if tab.item == item_info.name then
                        table.insert(CheckedSlots, { slot = i, count = item_info.count })
                        goto continue
                    end
                end
                self.removeFromInventory(i)
            end
        end
        ::continue::
    end
    self:clean_inventory()
end

return M
