-- filter code rewrite
local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- if no BackgroundFilter is necessary, it's safe to bail now
if mods.BackgroundFilter == "Off" then
	return Def.Actor{}
end


local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

local filter = Def.Quad{
	InitCommand=function(self)
		self:diffuse(Color.Black)
			:diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
			:xy( GetNotefieldX(player), _screen.cy )
			:zoomto( GetNotefieldWidth(), _screen.h )
	end,
	OffCommand=function(self) self:queuecommand("ComboFlash") end,
	ComboFlashCommand=function(self)
		local StageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		if StageStats:FullCombo() then
			local comboColor

			if SL.Global.GameMode == "StomperZ" then
				if StageStats:FullComboOfScore('TapNoteScore_W1') then
					comboColor = color("#e29c18") -- gold
				elseif StageStats:FullComboOfScore('TapNoteScore_W2') then
					comboColor = color("#e29c18") -- gold
				elseif StageStats:FullComboOfScore('TapNoteScore_W3') then
					comboColor = color("#66c955") -- green
				else
					comboColor = color("#FFFFFF") -- white
				end
			elseif SL.Global.GameMode == "ECFA" then
				if StageStats:FullComboOfScore('TapNoteScore_W1') then
					comboColor = color("#21CCE8") -- blue
				elseif StageStats:FullComboOfScore('TapNoteScore_W2') then
					comboColor = color("#21CCE8") -- blue
				elseif StageStats:FullComboOfScore('TapNoteScore_W3') then
					comboColor = color("#e29c18") -- gold
				else
					comboColor = color("#66c955") -- green
				end
			else
				if StageStats:FullComboOfScore('TapNoteScore_W1') then
					comboColor = color("#6BF0FF") -- ITG blue
				elseif StageStats:FullComboOfScore('TapNoteScore_W2') then
					comboColor = color("#FDDB85") -- ITG gold
				else
					comboColor = color("#94FEC1") -- ITG green
				end
			end
			self:accelerate(0.25):diffuse( comboColor )
				:decelerate(0.75):diffusealpha( 0 )
		end
	end
}

return filter