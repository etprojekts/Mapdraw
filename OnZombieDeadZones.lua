----------------------------------------------
--This mod created for Sunday Drivers server--
--mod by lect---------------------------------
--Free to use with permission-----------------
----------------------------------------------

local function splitString(sandboxvar, delimiter)
    local ztable = {}
    local pattern = "[^ %;,]+"

    for match in sandboxvar:gmatch(pattern) do
        table.insert(ztable, match)
    end
    return ztable
end

-- Pré-calcule as tabelas fora do evento
local table1 = splitString(SandboxVars.OZD.table1)
local table2 = splitString(SandboxVars.OZD.table2)
local table3 = splitString(SandboxVars.OZD.table3)
local table4 = splitString(SandboxVars.OZD.table4)

local dropTables = {
    [4] = {table4, table3, table2, table1},
    [3] = {table3, table2, table1},
    [2] = {table2, table1},
    [1] = {table1}
}

local rollVars = {
    SandboxVars.OZD.roll4,
    SandboxVars.OZD.roll3,
    SandboxVars.OZD.roll2,
    SandboxVars.OZD.roll1
}

local function OnZombieDeadItemDrop(zombie)
    local player = getSpecificPlayer(0)
    local tierzone = checkZone()
    
    if tierzone > 0 and tierzone <= 4 then
        player:getXp():AddXP(Perks.Strength, tierzone * 5)
        player:getXp():AddXP(Perks.Fitness, tierzone * 5)
        
        for i, table in ipairs(dropTables[tierzone]) do
            if ZombRand(rollVars[5-i]) == 0 then
                local item = table[ZombRand(#table) + 1]
                zombie:getInventory():AddItem(item)
                break
            end
        end
    end
end

Events.OnZombieDead.Add(OnZombieDeadItemDrop)