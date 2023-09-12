local f = CreateFrame("Frame")

-- Register for buff/debuff changes on the player
f:RegisterEvent("UNIT_AURA")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_AURA" and arg1 == "player" then
        for i = 1, 40 do
            local name, _, _, _, _, _, _, caster = UnitBuff("player", i)
            if name and caster and caster ~= "player" then
                local casterName = UnitName(caster)
                if casterName then
                    print(casterName .. " cast " .. name .. " on you.")
                end
            end
        end
    end
end)
