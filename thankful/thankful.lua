local Timers = {
    SaveTime = 2 * 60000,
    DefaultSaveTime = 2 * 60000,
}

local PlayerGUID, LastTime, Ticker
local BuffText = "%s %s Buffed you with: %s"
local SavedBuffs = {}

local function RemoveOldBuffs()
    if #SavedBuffs == 0 then return end
    local time = debugprofilestop()
    for i = #SavedBuffs, 1, -1 do
        if LastTime and SavedBuffs[i].time + Timers.SaveTime < time then
            tremove(SavedBuffs, i)
        end
    end
    if #SavedBuffs == 0 and Ticker then
        Ticker:Cancel()
        Ticker = nil
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEAVING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        PlayerGUID = UnitGUID("player")
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        print("Entering World!")
        C_Timer.After(2, function()
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            print("Registered COMBAT_LOG_EVENT_UNFILTERED!")
        end)
        return
    end
    if event == "PLAYER_LEAVING_WORLD" then
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        return
    end
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        print("Combat log event detected!")
    end
    
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, spellID, spellName, _, auraType = CombatLogGetCurrentEventInfo()
    sourceName = sourceName or COMBATLOG_UNKNOWN_UNIT
    
    if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER and (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH") and auraType == "BUFF" and destGUID == PlayerGUID and sourceGUID ~= PlayerGUID then
        LastTime = debugprofilestop()
        local _, class, _, _, _, _, realm = GetPlayerInfoByGUID(sourceGUID)
        
        if realm == "" then
            realm = GetRealmName()
        end
        
        sourceName = "|c" .. select(4, GetClassColor(class)) .. sourceName
        realm = "|cffffff00[" .. realm .. "]|r"
        local text = format(BuffText, sourceName, realm, spellName)
        print("Attempting to print message:", text)
        
        tinsert(SavedBuffs, { time = LastTime, spell = spellName, msg = text })
        print(text)
        
        if not Ticker then
            Ticker = C_Timer.NewTicker(5, RemoveOldBuffs)
        end
    end
end)

local function SortByTime(a, b)
    return a.time > b.time
end

SLASH_SWARFBUFF1 = "/swb"
SlashCmdList["SWARFBUFF"] = function(msg)
    -- ... rest of the slash command logic ...
end
