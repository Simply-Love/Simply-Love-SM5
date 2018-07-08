local Input = function(event)
	-- if any of these, don't attempt to handle input
	if not event or not event.button then return false end

	if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
		local topscreen = SCREENMAN:GetTopScreen()
		topscreen:SetNextScreenName("ScreenGameOver")
		topscreen:StartTransitioningScreen("SM_GoToNextScreen")
	end
end

local af = Def.ActorFrame{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( Input ) end,

	LoadActor(THEME:GetPathB("ScreenSelectMusicCasual", "overlay/Header.lua"), {h=60} ),

	Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse(0,0,0,0.6) end
	},

	Def.BitmapText{
		Font="_miso",
		Text=ScreenString("NoValidSongs"),
		InitCommand=function(self) self:Center():zoom(1.1):wrapwidthpixels(320) end
	},
}

return af