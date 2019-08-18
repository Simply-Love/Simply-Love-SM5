if SL.Global.GameMode == "Casual" then return end
if not GAMESTATE:IsEventMode() then return end
if not PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then return end

local game = GAMESTATE:GetCurrentGame():GetName()
if not (game=="dance" or game=="pump" or game=="techno") then return end

local player = ...

local pane = Def.ActorFrame{
	Name="Pane5",
	InitCommand=function(self) self:visible(false) end,

	LoadFont("Common normal")..{
		Text=THEME:GetString("ScreenEvaluation",  "TestInput"),
		InitCommand=function(self) self:zoom(1.1):xy(-92, 222):vertalign(top) end
	},

	Def.Quad{
		InitCommand=function(self) self:xy(-140, 245):zoomto(96,1):align(0,0):diffuse(1,1,1,0.33) end
	},

	LoadFont("Common normal")..{
		Text=THEME:GetString("ScreenEvaluation",  "TestInputInstructions"),
		InitCommand=function(self) self:zoom(0.8):xy(-140,255):wrapwidthpixels(100/0.8):align(0,0):vertspacing(-4) end
	},

	LoadActor( THEME:GetPathB("", "_modules/TestInput Pad/default.lua"), player)..{
		InitCommand=function(self) self:xy(50, 338):zoom(0.8) end
	}
}

return pane