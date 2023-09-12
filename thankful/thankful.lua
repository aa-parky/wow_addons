local f = CreateFrame("Frame")
local lastBuffApplier

f:RegisterEvent("UNIT_AURA")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_AURA" and arg1 == "player" then
        print("UNIT_AURA event detected!")
        
        for i = 1, 40 do
            local name, _, _, _, _, _, _, caster = UnitBuff("player", i)
            
            if name then
                print("Detected buff:", name, "from caster:", caster)  -- Updated debug print
            end
            
            local playerName = UnitName(caster)
            print("PlayerName from UnitName:", playerName)  -- Debugging print
            
            if playerName then
                print("Condition 1 (is playerName):", playerName ~= nil)
                print("Condition 2 (is not the player):", playerName ~= UnitName("player"))
                print("Condition 3 (is not the lastBuffApplier):", playerName ~= lastBuffApplier)
                
                if playerName and playerName ~= UnitName("player") and playerName ~= lastBuffApplier then
                    lastBuffApplier = playerName
                    SendChatMessage("Thanks for the buff, " .. playerName .. "!", "SAY")
                    break
                end
            end
        end
    end
end)
