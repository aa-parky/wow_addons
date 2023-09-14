-- Initialize command for clearing second marker and turning the addon on and off
SLASH_AUTOMARKER1 = "/clm"
SLASH_NOON1 = "/noon"
SLASH_NOOFF1 = "/nooff"

-- Table to keep track of marked targets
local markedTargets = {}
local addonEnabled = true

-- Function to clear markers from known units and printed units
SlashCmdList["AUTOMARKER"] = function(msg)
    if msg == "" then
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitExists(unit) then
                SetRaidTarget(unit, 0)
            end
        end
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                SetRaidTarget(unit, 0)
            end
        end
        
        -- Clear markers from the recorded enemy units
        for _, unit in ipairs(markedTargets) do
            if UnitExists(unit) then
                SetRaidTarget(unit, 0)
            end
        end
        markedTargets = {} -- Clear the table for future markings
        
        SetRaidTarget("player", 0)
        print("Last marker cleared.")
    end
end

-- turn addon on and off 

SlashCmdList["NOON"] = function()
    addonEnabled = true
    print("No! This one is now ON.")
end

SlashCmdList["NOOFF"] = function()
    addonEnabled = false
    print("No! This one is now OFF.")
end

local currentMarker = 0
local maxMarkers = 2  -- Set to 2 to ensure only two enemies are marked at a time.

local function SetNextMarker(unit)
    if not UnitExists(unit) then return end

    -- If there are already maxMarkers in the table, remove the oldest one
    if #markedTargets == maxMarkers then
        local oldestMarkedUnit = table.remove(markedTargets, 1)  -- remove the oldest entry
        SetRaidTarget(oldestMarkedUnit, 0)  -- remove its marker
    end

    currentMarker = currentMarker % maxMarkers + 1
    SetRaidTarget(unit, currentMarker)

    -- Record the enemy unit that was marked
    table.insert(markedTargets, unit)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:SetScript("OnEvent", function(self, event)
    if addonEnabled and event == "PLAYER_TARGET_CHANGED" then
        if UnitCanAttack("player", "target") and not UnitIsPlayer("target") then
            SetNextMarker("target")
        end
    end
end)
