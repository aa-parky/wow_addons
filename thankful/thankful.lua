local PlayerGUID
local BuffText = "%s %s Buffed you with: %s"

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
        C_Timer.After(2, function()
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end)
        return
    end
    if event == "PLAYER_LEAVING_WORLD" then
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        return
    end

    local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, _, spellName, _, auraType = CombatLogGetCurrentEventInfo()
    sourceName = sourceName or COMBATLOG_UNKNOWN_UNIT

    -- Direct check to ensure you're not in any group or instance.
    if IsInGroup() or IsInInstance() then
        return
    end

    if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER and (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH") and auraType == "BUFF" and destGUID == PlayerGUID and sourceGUID ~= PlayerGUID then
        local _, class, _, _, _, _, realm = GetPlayerInfoByGUID(sourceGUID)

        if realm == "" then
            realm = GetRealmName()
        end

        sourceName = "|Hplayer:" .. sourceName .. "|h|c" .. select(4, GetClassColor(class)) .. "[" .. sourceName .. "]|r|h"
        realm = "|cffffff00[" .. realm .. "]|r"
        local text = format(BuffText, sourceName, realm, spellName)
        print(text)
    end
end)
