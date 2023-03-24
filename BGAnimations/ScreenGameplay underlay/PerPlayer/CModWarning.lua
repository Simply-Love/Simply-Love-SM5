local player = ...
local pn = ToEnumShortString(player)

local mods = SL[pn].ActiveModifiers
if SL.Global.GameMode == "Casual" or GAMESTATE:IsCourseMode() then return end

local style = GAMESTATE:GetCurrentStyle(player)
local width = style:GetWidth(player)
local subtitle = GAMESTATE:GetCurrentSong():GetDisplaySubTitle()
if not string.find(string.upper(subtitle), "(NO CMOD)") or GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod() == nil then return end

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy( GetNotefieldX(player), _screen.h/2)
		local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
		self:zoomx( zoom_factor )
		self:sleep(4):linear(1):diffusealpha(0)
	end,
}

af[#af+1] = Def.ActorFrame{
	Name="CModWarning",
	Def.Quad{
		Name="BGCmodWarning",
		InitCommand=function(self)
			self:diffuse(0,0,0,0.8)
				:x(0)
				:setsize(90, 30)
		end,
	},
	Def.BitmapText {
		Name="CModWarningText",
		Font="Common Normal",
		Text="CMod On",
		InitCommand=function(self)
			self:zoom(1.5)
				:diffuse(1,0,0,1)
				:horizalign(center)
		end,
	}
}

return af