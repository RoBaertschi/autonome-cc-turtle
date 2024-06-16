local M = {
    -- Disable, when not mining anymore
    disabled = false,
}

---@type {item: string, has_tags?: string, max_needed: number}[]
local ItemsNeeded = {
    -- Furnace, Stone
    {item = "minecraft:cobblestone", max_needed = 64},
    {item = "minecraft:redstone", max_needed = 64},
    {item = "minecraft:coal", max_needed = 64},
    {item = "minecraft:diamond", max_needed = 64},
    {item = "minecraft:raw_iron", max_needed = 64},
    {item = "", has_tags = "minecraft:logs", max_needed = 64},
    {item = "minecraft:chest", max_needed = 64},
    {item = "minecraft:sand", max_needed = 64},
    {item = "minecraft:lapis_lazuli", max_needed = 64},
    {item = "minecraft:sugar_cane", max_needed = 64},
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

function M.clean_inventory()
    for index, slot in ipairs(CheckedSlots) do
        
    end
end

function M.update()

    for i = 1, 16, 1 do
        if not has_value(CheckedSlots, i) then
            ---@type ccTweaked.turtle.slotInfoDetailed
            local item_info = turtle.getItemDetail(i, true)

            
            if item_info ~= nil then 
                for _, tab in ipairs(ItemsNeeded) do
                    if item_info.tags[tab.has_tags] then
                        table.insert(CheckedSlots, {slot = i, count = item_info.count})
                        goto continue
                    end
                    if tab.item == item_info.name then 
                        table.insert(CheckedSlots, {slot = i, count = item_info.count})
                        goto continue
                    end
                end
                print(textutils.serialise(item_info))
            end

            turtle.select(i)
            turtle.drop()
        end
        ::continue::
    end
    print(textutils.serialise(CheckedSlots))

end

return M