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
                    print(casterName .. " cast " .. name .. " on you.")
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
local BuffText = "%s %s Buffed you with: %s" -- %s 1 = player name, %s 2 realm name, %s 3 = buff name
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
local f = CreateFrame("Frame")
f:SetSize(5, 5)
f:SetPoint("TOP", 0, -5)
f.Text = f:CreateFontString()
f.Text:SetFontObject(GameFontNormal)
f.Text:SetPoint("TOP")
f.Text:SetJustifyH("CENTER")
f.Text:SetAlpha(0)
f.ag = f:CreateAnimationGroup()
f.ag.Fade = f.ag:CreateAnimation("Alpha")
f.ag.Fade:SetChildKey("Text")
f.ag.Fade:SetOrder(1)
f.ag.Fade:SetFromAlpha(1)
f.ag.Fade:SetToAlpha(0)
f.ag.Fade:SetDuration(Timers.DisplayDuration)
f.ag:SetToFinalAlpha(true)
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
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, auraType, remainingPoints = CombatLogGetCurrentEventInfo()
	sourceName = sourceName or COMBATLOG_UNKNOWN_UNIT
	if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER and (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH") and auraType == AURA_TYPE_BUFF and destGUID == PlayerGUID and sourceGUID ~= PlayerGUID then
		LastTime = debugprofilestop()
		if subevent == "SPELL_AURA_REFRESH" then
			for i=#SavedBuffs, 1, -1 do
				if SavedBuffs[i].spell == spellName then
					tremove(SavedBuffs, i)
				end
			end
		end
		local _, class, _, _, _, _, realm = GetPlayerInfoByGUID(sourceGUID)
		if realm == "" then
			realm = GetRealmName()
		end
		sourceName = "|c" .. select(4, GetClassColor(class)) .. sourceName
		realm = "|cffffff00[" .. realm .. "]|r"
		local text = format(BuffText, sourceName, realm, spellName)
		tinsert(SavedBuffs, { time=LastTime, spell=spellName, msg=text } )
		self.Text:SetText(text .. ' (' .. #SavedBuffs .. ")") self.Text:GetText()
		f.Text:SetAlpha(1)
		if self.ag:IsPlaying() then  
			self.ag:Restart() 
		else
			self.ag:Play()
			PlaySound(1372)			
		end
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
	msg = msg:trim()
	if msg ~= "" then
		if msg == "Reset" then
			Timers.DisplayDuration = Timers.DefaultDuration 
			f.ag.Fade:SetDuration(Timers.DisplayDuration)
			Timers.SaveTime = Timers.DefaultSaveTime
			return
		end
		local option, newtime = strsplit(" ", strupper(msg))
		if option == "D" then
			local duration = tonumber(newtime)
			if duration then
				Timers.DisplayDuration = duration -- Seconds
				f.ag.Fade:SetDuration(Timers.DisplayDuration)
				print("Display duration is now:", duration, "seconds")
				return
			end
		elseif option == "S" then
			local save = tonumber(newtime)
			if save then
				Timers.SaveTime = save * 60000 -- Minutes
				print("Save time is now:", save, "miunutes")
				return
			end
		end
		print("Not a valid duration or save time format:", msg)
		return
	end
	if #SavedBuffs == 0 then
		print("No Current Buffs.")
		return
	end
	local time = debugprofilestop()
	sort(SavedBuffs, SortByTime) -- sort most recent first
	for k, v in ipairs(SavedBuffs) do
		local since = floor((time - v.time)/1000)
		local suffix = ""
		if since > 59 then
			since = floor(since/60) + 1
			suffix = "s"
		else
			since = 1
		end
		print(v.msg, "(<", since, "minute"..suffix, "ago)")
	end
end