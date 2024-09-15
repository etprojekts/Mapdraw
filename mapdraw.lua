require "ISUI/Maps/ISWorldMapSymbols"
require "ISUI/Maps/ISWorldMap"
require "ISUI/ISPanelJoypad"
require "ISUI/Maps/ISMap"
require "ZoneCheck"

-- Define colors with alpha channel
local alpha = 0.5

-- assign colors to tiers. Last in first out, otherwise you will skip nested tiers.
function getColorForTier(tier)
    if tier == 4 then
        return {1, 0, 0, alpha} -- Red (Tier 4)
    elseif tier == 3 then
        return {1, 0.5, 0, alpha} -- Bright Orange (Tier 3)
    elseif tier == 2 then
        return {1, 1, 0, alpha} -- Yellow (Tier 2)
    end
    return {0, 1, 0, alpha} -- Green (Tier 1)
end

local symbolCache = {}

-- Function to draw a hatched rectangle for a specific zone
function drawHatchedRectangleForZone(self, zoneName, spacingFactor, hatchSpacing, api)
    local zoneCoordinates = Zone.list[zoneName]

    if zoneCoordinates then
        local startX, startY = zoneCoordinates[1], zoneCoordinates[2]
        local endX, endY = zoneCoordinates[3], zoneCoordinates[4]
        local tier = zoneCoordinates[5]
        local mapAPI = self.mapAPI

        if tier ~= 1 then 
            drawHatchedRectangle(self, startX, startY, endX, endY, spacingFactor, hatchSpacing, tier, mapAPI)
        end
    end
end

function drawHatchedRectangleForNestedZone(self, zoneName, spacingFactor, hatchSpacing, api)
    local zoneCoordinates = NestedZone.list[zoneName]

    if zoneCoordinates then
        local startX, startY = zoneCoordinates[1], zoneCoordinates[2]
        local endX, endY = zoneCoordinates[3], zoneCoordinates[4]
        local tier = zoneCoordinates[5]
        local mapAPI = self.mapAPI

        if tier ~= 1 then 
            drawHatchedRectangle(self, startX, startY, endX, endY, spacingFactor, hatchSpacing, tier, mapAPI)
        end
    end
end

-- Function to draw a hatched rectangle
function drawHatchedRectangle(self, x1, y1, x2, y2, spacingFactor, hatchSpacing, tier, mapAPI)
    local sides = {{x1, y1, x2, y1}, {x2, y1, x2, y2}, {x2, y2, x1, y2}, {x1, y2, x1, y1}}

    for _, side in ipairs(sides) do
        drawMapLine(self, side[1], side[2], side[3], side[4], tier, mapAPI)
    end
end

-- Function to draw a line between two points
function drawMapLine(self, x1, y1, x2, y2, tier, mapAPI)
    local distance = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    local numSymbols = math.ceil(distance / 35)  -- Adjust the divisor as needed
    local spacingX = (x2 - x1) / numSymbols
    local spacingY = (y2 - y1) / numSymbols

    for i = 0, numSymbols do
        local symbolX = spacingX == 0 and x1 or x1 + i * spacingX
        local symbolY = spacingY == 0 and y1 or y1 + i * spacingY
        addMapSymbol(symbolX, symbolY, tier, mapAPI)
    end
end

function addMapSymbol(worldX, worldY, tier, mapAPI)
    local key = string.format("%d_%d_%d", worldX, worldY, tier)
    if not symbolCache[key] then
        local texture = "Asterisk"
        local textureSymbol = mapAPI:getSymbolsAPI():addTexture(texture, worldX, worldY)
        local color = getColorForTier(tier)
        textureSymbol:setRGBA(color[1], color[2], color[3], color[4])
        textureSymbol:setAnchor(0.5, 0.5)
        textureSymbol:setScale(ISMap.SCALE * 2.5)
        symbolCache[key] = textureSymbol
    end
end

local ISWorldMap_render = ISWorldMap.render
function ISWorldMap:render()
    ISWorldMap_render(self)
    local ModDataMapDrawTierZones = ModData.getOrCreate("MapDrawTierZones")

    if not ModDataMapDrawTierZones[getCurrentUserSteamID()] then
        for _, zoneName in ipairs(ZoneNames) do
            drawHatchedRectangleForZone(self, zoneName, 1.0, 750, self.mapAPI)
        end

        for _, nestedZoneName in ipairs(NestedZoneNames) do
            drawHatchedRectangleForNestedZone(self, nestedZoneName, 1.0, 750, self.mapAPI)
        end
        ModDataMapDrawTierZones[getCurrentUserSteamID()] = true
    end
end

-- Right click context menu on worldmap
local ISWorldMap_onRightMouseUp = ISWorldMap.onRightMouseUp
function ISWorldMap:onRightMouseUp(x, y)
    local playerNum = 0
    local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
    
    ISWorldMap_onRightMouseUp(self, x, y)
    
    local ModDataMapDrawTierZones = ModData.getOrCreate("MapDrawTierZones")
    
    if ModDataMapDrawTierZones[getCurrentUserSteamID()] == "CLEARED" then
        local option = context:addOption("Redraw Tier Zone Boundary Lines", self, function()
            ModDataMapDrawTierZones[getCurrentUserSteamID()] = false
            symbolCache = {}
        end)
    end
    
    if ModDataMapDrawTierZones[getCurrentUserSteamID()] == true then
        local option = context:addOption("Clear All Map Markings (WARNING: CLEARS ALL MARKS)", self, function()
            ModDataMapDrawTierZones[getCurrentUserSteamID()] = "CLEARED"
            self.mapAPI:getSymbolsAPI():clear()
            symbolCache = {}
        end)
    end
end