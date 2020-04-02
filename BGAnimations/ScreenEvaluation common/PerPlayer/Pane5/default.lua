-- Pane5 displays TestInput.

if SL.Global.GameMode == "Casual" then return end

-- DedicatedMenu buttons are necessary here to prevent players from getting stuck in this pane
if not PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then return end

local game = GAMESTATE:GetCurrentGame():GetName()
if not (game=="dance" or game=="pump" or game=="techno") then return end

local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
local player = ...

local pane = Def.ActorFrame{
	Name="Pane5",
	InitCommand=function(self)
		self:visible(false)
		if style == "OnePlayerTwoSides" then
			if IsUsingWideScreen() then
				self:x( -107 )
			else
				self:x( -_screen.w/6 )
			end
		end
	end,
	-- ExpandForDoubleCommand() does not do anything here, but we check for its presence in
	-- this ActorFrame in ./InputHandler to determine which panes to expand the background for
	ExpandForDoubleCommand=function() end,
}

-- for single style, show one pad and some help text
if style == "OnePlayerOneSide" or style == "TwoPlayersTwoSides" then
	pane[#pane+1] = LoadActor( THEME:GetPathB("", "_modules/TestInput Pad/default.lua"), {Player=player, ShowMenuButtons=false, ShowPlayerLabel=false})..{
		InitCommand=function(self) self:xy(50, 338):zoom(0.8) end
	}
	pane[#pane+1] = LoadFont("Common normal")..{
		Text=THEME:GetString("ScreenEvaluation",  "TestInput"),
		InitCommand=function(self) self:zoom(1.1):xy(-92, 222):vertalign(top):maxwidth(100/self:GetZoom()) end
	}
	pane[#pane+1] = Def.Quad{
		InitCommand=function(self) self:xy(-140, 245):zoomto(96,1):align(0,0):diffuse(1,1,1,0.33) end
	}
	pane[#pane+1] = LoadFont("Common normal")..{
		Text=THEME:GetString("ScreenEvaluation",  "TestInputInstructions"),
		InitCommand=function(self) self:zoom(0.8):xy(-140,255):_wrapwidthpixels(100/0.8):align(0,0):vertspacing(-4) end
	}

-- for everything else (double, routine, couple), show two pads
else
	pane[#pane+1] = LoadActor( THEME:GetPathB("", "_modules/TestInput Pad/default.lua"), {Player=PLAYER_1, ShowMenuButtons=false, ShowPlayerLabel=false})..{
		InitCommand=function(self) self:xy(22, 338):zoom(0.8) end
	}
	pane[#pane+1] = LoadActor( THEME:GetPathB("", "_modules/TestInput Pad/default.lua"), {Player=PLAYER_2, ShowMenuButtons=false, ShowPlayerLabel=false})..{
		InitCommand=function(self) self:xy(188, 338):zoom(0.8) end
	}
end

return pane