local f = CreateFrame("Frame")
local lastBuffApplier

-- event fires when a unit's aura changes
f:RegisterEvent("UNIT_AURA")

f:SetScript("OnEvent", function (self, event, arg1)
    if event == "UNIT_AURA" and arg1 == "player" then
        for i = 1, 40 do
            local name, _, _, _, _, _, _, caster = UnitBuff("player", i)
            if name and caster then
                local playerName = UnitName(caster)

                if playerName and playerName ~= UnitName("player") and playerName ~= lastBuffApplier then
                    lastBuffApplier = playerName
                    SendChatMessage("Thanks for the buff, " .. playerName .."!", "SAY")
                end
            end
        end
    end
    
end)