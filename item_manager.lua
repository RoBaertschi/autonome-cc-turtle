local M = {
}

-- Disable, when not mining anymore
M.disabled = false

---@type {item: string, has_tags?: string, max_needed: number}[]
M.ItemsNeeded = {
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

local ItemsNeeded = M.ItemsNeeded

local MiningRequiredItems = {
    ["minecraft:redstone"] = 4,
    ["minecraft:lapis_lazuli"] = 1,
    ["minecraft:diamond"] = 3,
}

---@type {[string]: {slots: {count: number, slot: integer}[], tag?: boolean, count: integer}}
local CheckedSlots = {}

---Get count of an item in inventory
---@param name string
---@return integer
function M:getAllCount(name)
    if CheckedSlots[name] == nil then
        return 0
    end

    return CheckedSlots[name].count

    -- local slots = CheckedSlots[name].slots
    -- local count = 0
    -- for _, slot in ipairs(slots) do
    --     count = count + slot.count
    -- end
    -- return count
end

function M:miningDone()
    for key, value in pairs(MiningRequiredItems) do
        local slot = CheckedSlots[key]
        if slot ~= nil and slot.count < value then
            return false
        end
    end
    return true
end

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
local function getItem(name_or_tag)
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
    for _, slot in pairs(CheckedSlots) do
        for _, slot_detail in ipairs(slot.slots) do
            local detail = turtle.getItemDetail(slot_detail.slot, false)

            if detail == nil then
                goto continue
            end

            if to_clean[detail.name] == nil then
                to_clean[detail.name] = detail.count
            else
                to_clean[detail.name] = to_clean[detail.name] + detail.count

                local item = getItem(detail.name)
                if item == nil then
                    for _, tag in ipairs(turtle.getItemDetail(slot_detail.slot, true).tags) do
                        item = getItem(tag)
                        if item == nil then
                            goto item_found
                        end
                    end
                    goto continue
                    ::item_found::
                end

                if to_clean[detail.name] > item.max_needed then
                    M.removeFromInventory(slot_detail.slot, to_clean[detail.name] - item.max_needed)
                    to_clean[detail.name] = to_clean[detail.name] - item.max_needed
                end
            end
            ::continue::
        end
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

function M:has_item_at(slot)
    for _, value in pairs(CheckedSlots) do
        for _, slot_and_count in ipairs(value.slots) do
            if slot == slot_and_count.slot then
                return true
            end
        end
    end
    return false
end

function M:update()
    for i = 1, 16, 1 do
        if not self.has_item_at(CheckedSlots, i) then
            turtle.select(i)
            local item_info = turtle.getItemDetail(i, true)


            if item_info ~= nil then
                for _, tab in ipairs(ItemsNeeded) do
                    local function add_to_checked_slots(name, tag)
                        if CheckedSlots[name] == nil then
                            CheckedSlots[name] = { slots = {}, tag = tag, count = 0 }
                        end
                        table.insert(CheckedSlots[name].slots, { count = item_info.count, slot = i })
                        CheckedSlots[name].count = CheckedSlots[name].count + item_info.count
                    end

                    if item_info.tags[tab.has_tags] then
                        add_to_checked_slots(tab.has_tags, true)
                        goto continue
                    end
                    if tab.item == item_info.name then
                        add_to_checked_slots(tab.item, false)
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
