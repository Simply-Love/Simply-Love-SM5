-- the MusicWheelItem for CourseMode contains the basic colored Quads
-- use that as a common base, and add in a Sprite for "Has Edit"
local af = LoadActor("../MusicWheelItem Course NormalPart.lua")

local stepstype = GAMESTATE:GetCurrentStyle():GetStepsType()

-- using a png in a Sprite ties the visual to a specific rasterized font (currently Miso),
-- but Sprites are cheaper than BitmapTexts, so we should use them where dynamic text is not needed
af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("", "Has Edit (doubleres).png"),
	InitCommand=function(self)
		self:horizalign(left):visible(false):zoom(0.375)
		self:x( _screen.w/(WideScale(2.15, 2.14)) - self:GetWidth()*self:GetZoom() - 8 )

		if DarkUI() then self:diffuse(0,0,0,1) end
	end,
	SetCommand=function(self, params)
		self:visible(params.Song and params.Song:HasEdits(stepstype) or false)
	end
}

for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
	-- Only use lamps if a profile is found
	if PROFILEMAN:IsPersistentProfile(pn) then
		af[#af+1] = LoadActor("GetLamp.lua", pn)..{}
		af[#af+1] = LoadActor("Favorites.lua",pn)..{}
	end
end

return af