local f = CreateFrame("Frame")
local lastBuffApplier

-- This event is fired when a unit's aura (buff or debuff) changes.
f:RegisterEvent("UNIT_AURA")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_AURA" and arg1 == "player" then
        print("UNIT_AURA event detected!")  -- Debugging print
        
        for i = 1, 40 do -- In Classic, a player can have a max of 32 buffs but using 40 for a safer margin.
            local name, _, _, _, _, _, _, caster = UnitBuff("player", i)
            
            if name then
                print("Detected buff:", name)  -- Debugging print
            end
            
            if caster then
                local playerName = UnitName(caster)
                print("Buff caster:", playerName)  -- Debugging print
                
                -- Check if the buff is from another player (and not an NPC or the player themselves).
                if playerName and playerName ~= UnitName("player") and playerName ~= lastBuffApplier then
                    lastBuffApplier = playerName
                    SendChatMessage("Thanks for the buff, " .. playerName .. "!", "SAY")
                    break -- Exit the loop once we've thanked the player.
                end
            end
        end
    end
end)
