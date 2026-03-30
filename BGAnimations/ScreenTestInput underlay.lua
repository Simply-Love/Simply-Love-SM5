local held = {}
local unmapped_list
local game = GAMESTATE:GetCurrentGame():GetName()

-- -----------------------------------------------------------------------

local InputHandler = function(event)
	if not (event and event.button) then return false end

	-- allow players to back out of ScreenTestInput by pressing Escape on their keyboard
	if event.GameButton == "Back" then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end

	if event.type ~= "InputEventType_Repeat" then
		MESSAGEMAN:Broadcast("TestInputEvent", event)
	end

	if event.button == "" then
		local key = ("%s %s"):format(ToEnumShortString(event.DeviceInput.device), ToEnumShortString(event.DeviceInput.button))

		if event.type == "InputEventType_Release" then
			held[key] = false
		else
			held[key] = true
		end

		unmapped_list:playcommand("Update")
	end

	return false
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame {
	OnCommand=function(self)
		-- only add a Lua input callback handler for dance, pump, and techno
		-- where we load in custom visuals
		if (game=="dance" or game=="pump" or game=="techno") then
			SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
		end
	end,
	OffCommand=function(self) self:sleep(0.4) end,

	Def.DeviceList {
		Font=THEME:GetPathF("",ThemePrefs.Get("ThemeFont") .. " Normal"),
		InitCommand=function(self)
			if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,1) end
			self:xy(_screen.cx,_screen.h-60):zoom(0.8)
		end
	}
}

-- for these specific games
if (game=="dance" or game=="pump" or game=="techno") then

	-- load custom visuals to show which inputs are mapped to game buttons
	for player in ivalues( PlayerNumber ) do
		local pad = LoadActor(THEME:GetPathB("", "_modules/TestInput Pad"), {Player=player, ShowMenuButtons=true, ShowPlayerLabel=true})

		pad.InitCommand=function(self) self:xy(_screen.cx + 150 * (player==PLAYER_1 and -1 or 1), _screen.cy):diffusealpha(0) end
		pad.OnCommand=function(self) self:linear(0.3):diffusealpha(1) end
		pad.OffCommand=function(self) self:linear(0.2):diffusealpha(0) end

		af[#af+1] = pad
	end

	-- and add a custom BitmapText to show which inputs are not mapped to any game buttons
	af[#af+1] = Def.BitmapText{
		Font=ThemePrefs.Get("ThemeFont") .. " Normal",
		InitCommand=function(self)
			if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,1) end
			self:xy(_screen.cx, _screen.cy+32):vertalign(top):vertspacing(-3)
			unmapped_list = self
		end,
		UpdateCommand=function(self)
			local s = ""
			for k, v in pairs(held) do
				if v then
					s = s .. ("%s (%s)\n"):format(k, THEME:GetString("ScreenTestInput", "not mapped"))
				end
			end
			self:settext(s)
		end

	}

-- for other games (para, kb7), just use a standard InputList provided by the engine
else
	af[#af+1] = Def.InputList{
		Font=ThemePrefs.Get("ThemeFont") .. " Normal",
		InitCommand=function(self)
			if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,1) end
			self:xy(_screen.cx-250, 50):horizalign(left):vertalign(top):vertspacing(0)
		end
	}
end

return af