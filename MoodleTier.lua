if not getActivatedMods():contains("MoodleFramework") then return end
require "ZoneCheck"
require "MF_ISMoodle"

-- Função para criar e configurar um moodle
local function createAndSetupMoodle(name, isGood, chevronIsUp, color, descriptions)
    MF.createMoodle(name)
    
    Events.OnCreatePlayer.Add(function()
        local moodle = MF.getMoodle(name)
        if moodle then
            if isGood then
                moodle:setThresholds(nil, nil, nil, nil, 0.55, 0.65, 0.75, 0.85)
            else
                moodle:setThresholds(0.15, 0.25, 0.35, 0.45, nil, nil, nil, nil)
            end
            moodle:setChevronIsUp(chevronIsUp)
            
            for i = 1, 4 do
                local texture = getTexture("media/ui/Moodle_Bkg_" .. color .. "_" .. i .. ".png")
                moodle:setBackground(1, i, texture)
                moodle:setBackground(2, i, texture)
                moodle:setDescription(1, i, descriptions[i])
                moodle:setDescription(2, i, descriptions[i])
            end
        end
    end)
end

-- Crie e configure os moodles
createAndSetupMoodle("Tier1", true, true, "Good", {"Zona Segura", "Zona Segura", "Zona Segura", "Zona Segura"})
createAndSetupMoodle("Tier2", false, false, "Bad", {"Zona de Risco Baixo", "Zona de Risco Baixo", "Zona de Risco Baixo", "Zona de Risco Baixo"})
createAndSetupMoodle("Tier3", false, false, "Bad", {"Zona de Risco Médio", "Zona de Risco Médio", "Zona de Risco Médio", "Zona de Risco Médio"})
createAndSetupMoodle("Tier4", false, false, "Bad", {"Zona de Alto Risco", "Zona de Alto Risco", "Zona de Alto Risco", "Zona de Alto Risco"})

local lastCheckMoodle = 0
local function EveryOneMinute()
    local player = getSpecificPlayer(0)
    if player then
        local checkMoodleTier, zoneName = checkZone()
        if checkMoodleTier ~= lastCheckMoodle then
            for i = 1, 4 do
                MF.getMoodle("Tier" .. i):setValue(0.5)
            end

            local tierValues = {0.55, 0.30, 0.20, 0.10}
            if checkMoodleTier >= 1 and checkMoodleTier <= 4 then
                MF.getMoodle("Tier" .. checkMoodleTier):setValue(tierValues[checkMoodleTier])
            end
            lastCheckMoodle = checkMoodleTier
        end
    end
end
Events.EveryOneMinute.Add(EveryOneMinute)