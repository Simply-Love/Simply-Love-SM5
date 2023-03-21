local num_items = THEME:GetMetric("MusicWheel", "NumWheelItems")
-- subtract 2 from the total number of MusicWheelItems
-- one MusicWheelItem will be offsceen above, one will be offscreen below
local num_visible_items = num_items - 2

local item_width = _screen.w / 2.125

local af =  Def.ActorFrame{
	-- the MusicWheel is centered via metrics under [ScreenSelectMusic]; offset by a slight amount to the right here
	InitCommand=function(self) self:x(WideScale(28,33)) end,

	Def.Quad{ InitCommand=function(self) self:horizalign(left):diffuse(0, 10/255, 17/255, 0.5):zoomto(item_width, _screen.h/num_visible_items) end },
	Def.Quad{ InitCommand=function(self)
		self:horizalign(left):diffuse(DarkUI() and {1,1,1,0.5} or {10/255, 20/255, 27/255, 1}):zoomto(item_width, (_screen.h/num_visible_items)-1)
		if ThemePrefs.Get("VisualStyle") == "SRPG6" or ThemePrefs.Get("VisualStyle") == "Technique" then self:diffusealpha(0.5) end
	end }
}


local players = GAMESTATE:GetHumanPlayers()

for i in ivalues(players) do
	af[#af+1] = LoadActor(THEME:GetPathG("", "MusicWheelItem RPGRate.lua"), i)
end

return af