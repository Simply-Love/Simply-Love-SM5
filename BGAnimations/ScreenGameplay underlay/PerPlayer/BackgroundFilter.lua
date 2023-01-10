local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

-- if no BackgroundFilter is necessary, it's safe to bail now
if mods.BackgroundFilter == 0 then return end

local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

return Def.Quad{
	InitCommand=function(self)
		self:xy(GetNotefieldX(player), _screen.cy )
			:diffuse(Color.Black)
			:diffusealpha( mods.BackgroundFilter / 100 )
			:zoomto( GetNotefieldWidth() + 80, _screen.h )
			:fadeleft(0.1):faderight(0.1)
		if NoteFieldIsCentered and SL[pn].ActiveModifiers.DataVisualizations ~= "None" then
			if pn == "P1" then
				self:zoomto( GetNotefieldWidth() + 40, _screen.h ):addx(-20):faderight(0)
			else
				self:zoomto( GetNotefieldWidth() + 40, _screen.h ):addx(20):fadeleft(0)
			end
		end
	end,
	OffCommand=function(self) self:queuecommand("ComboFlash") end,
	ComboFlashCommand=function(self)
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		local FlashColor = nil
		local WorstAcceptableFC = SL.Preferences[SL.Global.GameMode].MinTNSToHideNotes:gsub("TapNoteScore_W", "")

		for i=1, tonumber(WorstAcceptableFC) do
			if pss:FullComboOfScore("TapNoteScore_W"..i) then
				FlashColor = SL.JudgmentColors[SL.Global.GameMode][i]
				break
			end
		end

		if (FlashColor ~= nil) then
			self:accelerate(0.25):diffuse( FlashColor )
				:accelerate(0.5):faderight(1):fadeleft(1)
				:accelerate(0.15):diffusealpha(0)
		end
	end
}