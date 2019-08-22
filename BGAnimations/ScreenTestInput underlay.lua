local InputHandler = function(event)
	if not (event and event.PlayerNumber and event.button) then return false end

	-- allow players to back out of ScreenTestInput by pressing Escape on their keyboard
	if event.GameButton == "Back" then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end

	if event.type ~= "InputEventType_Repeat" then
		MESSAGEMAN:Broadcast("TestInputEvent", event)
	end

	return false
end

local af = Def.ActorFrame {
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
	end,
	OffCommand=function(self) self:sleep(0.4) end,

	Def.DeviceList {
		Font=THEME:GetPathF("","Common Normal"),
		InitCommand=function(self) self:xy(_screen.cx,_screen.h-60):zoom(0.8) end
	}
}

local game = GAMESTATE:GetCurrentGame():GetName()

if (game=="dance" or game=="pump" or game=="techno") then
	for player in ivalues( {PLAYER_1, PLAYER_2} ) do
		local pad = LoadActor(THEME:GetPathB("", "_modules/TestInput Pad"), {Player=player, ShowMenuButtons=true, ShowPlayerLabel=true})

		pad.InitCommand=function(self) self:xy(_screen.cx + 150 * (player==PLAYER_1 and -1 or 1), _screen.cy):diffusealpha(0) end
		pad.OnCommand=function(self) self:linear(0.3):diffusealpha(1) end
		pad.OffCommand=function(self) self:linear(0.2):diffusealpha(0) end

		af[#af+1] = pad
	end
else
	af[#af+1] = Def.InputList{
		Font="Common normal",
		InitCommand=function(self) self:xy(_screen.cx-250, 50):horizalign(left):vertalign(0):vertspacing(0) end
	}
end

return af