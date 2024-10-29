-- player options objects, used to figure out what mods each player has active
local po = {}
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	po[player] = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Song')
end

local increment = {
	XMod = 0.25,
	MMod = 10,
	CMod = 10,
}

local upper_limit = {
	XMod = 10,
	MMod = 2000,
	CMod = 2000,
}

local fmt = {
	XMod = "mod,%.2fx",
	MMod = "mod,m%d",
	CMod = "mod,c%d",
}

local InputHandler = function( event )
	if not event.PlayerNumber or not event.button then return false end
	if po[event.PlayerNumber] == nil              then return false end
	if event.type == "InputEventType_Release"     then return false end

	-- check event.button instead of event.MenuButton to ensure the player definitely pressed a dedicated MenuButton.
	-- we don't want to change speed mod if a player has OnlyDedicatedMenuButtons=0 and is, for example, tapping out
	-- the beat on their dance pad before the first note.
	if event.button == "MenuRight" or event.button == "MenuLeft" then
		local xmod = po[event.PlayerNumber]:XMod()
		local mmod = po[event.PlayerNumber]:MMod()
		local cmod = po[event.PlayerNumber]:CMod()

		local speedmod     = (cmod ~= nil and cmod)   or (mmod ~= nil and mmod)   or (xmod ~= nil and xmod)
		local speedmod_str = (cmod ~= nil and "CMod") or (mmod ~= nil and "MMod") or (xmod ~= nil and "XMod")

		if event.button == "MenuRight" then
			if speedmod + increment[speedmod_str] <= upper_limit[speedmod_str] then
				speedmod = speedmod + increment[speedmod_str]
			end
		elseif event.button == "MenuLeft" then
			if speedmod - increment[speedmod_str] > 0 then
				speedmod = speedmod - increment[speedmod_str]
			end
		end

		-- update SL table with new speed
		SL[ToEnumShortString(event.PlayerNumber)].ActiveModifiers.SpeedMod = speedmod

		-- format a GameCommand string like "mod,1.75x" or "mod,c460" or "mod,m900"
		local gcString = fmt[speedmod_str]:format(speedmod)

		-- apply the new speed mod to the player immediately
		GAMESTATE:ApplyGameCommand(gcString, event.PlayerNumber)

		-- broadcast which player's mods changed so that ScreenGameplay's DisplayMods.lua
		-- can update its BitmapText string to show the player updated text
		MESSAGEMAN:Broadcast("PlayerOptionsChanged", {Player=event.PlayerNumber})
	end

	return false
end

return Def.Actor{
	OnCommand=function(self)                        self:playcommand("AddInputHandler") end,
	CurrentSongChangedMessageCommand=function(self) self:playcommand("AddInputHandler") end,

	OffCommand=function(self)             self:playcommand("RemoveInputHandler") end,
	JudgmentMessageCommand=function(self) self:playcommand("RemoveInputHandler") end,

	AddInputHandlerCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		if screen then
			screen:AddInputCallback( InputHandler )
		end
	end,
	RemoveInputHandlerCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		if screen then
			screen:RemoveInputCallback( InputHandler )
		end
	end
}