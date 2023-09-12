local f = CreateFrame("Frame")

-- Register for buff/debuff changes on the player
f:RegisterEvent("UNIT_AURA")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_AURA" and arg1 == "player" then
        for i = 1, 40 do
            local name, _, _, _, _, _, _, _, caster = UnitBuff("player", i)
            if name and caster and caster ~= "player" then
                local casterName = UnitName(caster)
                if casterName then
                    local playerLink = "|Hplayer:"..casterName.."|h["..casterName.."]|h"
                    print(playerLink .. " cast " .. name .. " on you.")
                end
            end
        end
    end
end)

local Timers = {
    DisplayDuration = 10,
    SaveTime = 2 * 60000,
    DefaultDuration = 10, 
    DefaultSaveTime = 2 * 60000,
}

local PlayerGUID, LastTime, Ticker
local BuffText = "%s Buffed you with: %s" -- %s 1 = player link, %s 2 = buff name
local SavedBuffs = {}

local function RemoveOldBuffs()
    if #SavedBuffs == 0 then return end
    local time = debugprofilestop()
    for i=#SavedBuffs, 1, -1 do
        if LastTime and SavedBuffs[i].time + Timers.SaveTime < time then
            tremove(SavedBuffs, i)
        end
    end
    if #SavedBuffs == 0 then
        Ticker:Cancel()
        Ticker = nil
    end
end

-- ... rest of the original code ...

if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER and (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH") and auraType == "BUFF" and destGUID == PlayerGUID and sourceGUID ~= PlayerGUID then
    LastTime = debugprofilestop()
    
    -- ... rest of the event logic ...

    local playerLink = "|Hplayer:"..sourceName.."|h["..sourceName.."]|h"
    local text = format(BuffText, playerLink, spellName)
    
    -- ... rest of the event logic ...
end
