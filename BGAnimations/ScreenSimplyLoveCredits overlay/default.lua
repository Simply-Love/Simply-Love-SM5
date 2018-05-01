local page = 1
local pages = 2
local next_page
local af

-- assume that the player has dedicated MenuButtons
local buttons = {
	-- previous page
	MenuLeft = -1,
	MenuUp = -1,
	-- next page
	MenuRight = 1,
	MenuDown = 1,
}

-- if OnlyDedicatedMenuButtons is disabled, add in support for navigating this screen with gameplay buttons
if not PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
	-- previous page
	buttons.Left=-1
	buttons.Up=-1
	-- next page
	buttons.Right=1
	buttons.Down=1
end


local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		if event.GameButton=="Start" or event.GameButton=="Back" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end

		if buttons[event.GameButton] ~= nil then
			next_page = page + buttons[event.GameButton]

			if next_page > 0 and next_page < pages+1 then
				page = next_page
				af:stoptweening():queuecommand("Hide"):queuecommand("ShowPage"..page)
			end
		end
	end
end

local t = Def.ActorFrame{
	InitCommand=function(self) af = self end,
	OnCommand=function(self)
		self:queuecommand("ShowPage1")
		SCREENMAN:GetTopScreen():AddInputCallback( InputHandler )
	end
}

-- header text
t[#t+1] = Def.BitmapText{
	Name="PageNumber",
	Font="_wendy small",
	Text="Page 1/" .. pages,
	InitCommand=cmd(diffusealpha,0; zoom, WideScale(0.5,0.6); xy, _screen.cx, 15 ),
	OnCommand=cmd(sleep, 0.1; decelerate,0.33; diffusealpha, 1),
	OffCommand=cmd(accelerate,0.33; diffusealpha,0),
	HideCommand=function(self) self:sleep(0.5):settext(THEME:GetString("ScreenEvaluationSummary","Page").." "..page.."/"..pages ) end
}

for i=1,pages do

	t[#t+1] = Def.ActorFrame{
		Name="Page"..i,
		InitCommand=function(self) self:visible(false):Center() end,
		HideCommand=function(self) self:visible(false) end,
		["ShowPage"..i.."Command"]=function(self) self:visible(true) end

	}..LoadActor("./Page"..i..".lua", i)

end

return t