-- filter code rewrite
local player, pn, mods


local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

local filter = Def.Quad{
	InitCommand=function(self)
		self:diffuse(Color.Black):hibernate(math.huge)
	end,
	PlayerStateSetCommand=function(self, param)
		player = param.PlayerNumber
		pn = ToEnumShortString(player)
		mods = SL[pn].ActiveModifiers

		--if not needed, keep sleeping
		if mods.BackgroundFilter == "Off" then
			return
		end

		self:diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
			:setsize( GAMESTATE:GetCurrentStyle(player):GetWidth(player), _screen.h*4096 )
			:hibernate(0)
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

return Def.ActorFrame{filter}