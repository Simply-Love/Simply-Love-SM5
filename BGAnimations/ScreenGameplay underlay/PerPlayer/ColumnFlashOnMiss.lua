-- don't allow ColumnFlashOnMiss to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then return end

local player = ...
local mods = SL[ToEnumShortString(player)].ActiveModifiers
local metrics = SL.Metrics[SL.Global.GameMode]
-- a flag to determine if we are using a GameMode that utilizes FA+ timing windows
local FAplus = (metrics.PercentScoreWeightW1 == metrics.PercentScoreWeightW2)

if mods.ColumnFlashOnMiss then
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Preferred')
	-- Existing logic already accounts for turn mods but not flip or invert.
	-- Manually try and account for it ourselves here.
	local flip = po:Flip() > 0
	local invert = po:Invert() > 0
	
	if flip and invert then return end

	local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()

	-- Only support flip/invert in modes with 4 or 8 columns.
	if NumColumns ~= 4 and NumColumns ~= 8 and (flip or invert) then return end

	local column_mapping = range((NumColumns==4 or NumColumns==8) and 4 or NumColumns)
	if flip then
		column_mapping = {column_mapping[4], column_mapping[3], column_mapping[2], column_mapping[1]}
	end
	
	if invert then
		column_mapping = {column_mapping[2], column_mapping[1], column_mapping[4], column_mapping[3]}
	end

	if NumColumns == 8 then
		for i=1,4 do
			column_mapping[4+i] = column_mapping[i] + 4
		end

		if flip then
			for i=1,4 do
				column_mapping[i] = column_mapping[i] + 4
				column_mapping[i+4] = column_mapping[i+4] - 4
			end
		end
	end

	local columns = {}
	local style = GAMESTATE:GetCurrentStyle(player)
	local width = style:GetWidth(player)

	local y_offset = 80

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:xy( GetNotefieldX(player), y_offset)
			-- Via empirical observation/testing, it seems that 200% mini is the effective cap.
			-- At 200% mini, arrows are effectively invisible; they reach a zoom_factor of 0.
			-- So, keeping that cap in mind, the spectrum of possible mini values in this theme
			-- becomes 0 to 2, and it becomes necessary to transform...
			-- a mini value like 35% to a zoom factor like 0.825, or
			-- a mini value like 150% to a zoom factor like 0.25
			local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
			self:zoomx( zoom_factor )
		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player == player and (params.Notes or params.Holds) then
				for i,col in pairs(params.Notes or params.Holds) do
					local tns = ToEnumShortString(params.TapNoteScore or params.HoldNoteScore)
					if (tns == "Miss" or tns == "MissedHold") and mods.FlashMiss then
						columns[column_mapping[i]]:playcommand("Flash", {tns=tns})
					elseif not FAplus and tns == "W5" and mods.FlashWayOff then
						columns[column_mapping[i]]:playcommand("Flash", {tns=tns})
					elseif (FAplus and tns == "W5" and mods.FlashDecent) or (not FAplus and tns == "W4" and mods.FlashDecent) then
						columns[column_mapping[i]]:playcommand("Flash", {tns=tns})
					elseif (FAplus and tns == "W4" and mods.FlashGreat) or (not FAplus and tns == "W3" and mods.FlashGreat) then
						columns[column_mapping[i]]:playcommand("Flash", {tns=tns})
					elseif (FAplus and tns == "W3" and mods.FlashExcellent) or (not FAplus and tns == "W2" and mods.FlashExcellent) then
						columns[column_mapping[i]]:playcommand("Flash", {tns=tns})
					elseif (FAplus and tns == "W2" and mods.FlashFantastic) or (tns == "W1" and mods.FlashFantastic) then
						columns[column_mapping[i]]:playcommand("Flash", {tns=tns})
					end
				end
			end
		end
	}

	for ColumnIndex=1,NumColumns do
		af[#af+1] = Def.Quad{
			InitCommand=function(self)
				columns[ColumnIndex] = self

				self:diffuse(0,0,0,0)
					:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
					:vertalign(top)
					:setsize(width/NumColumns, _screen.h - y_offset)
					:fadebottom(0.333)
	        end,
			FlashCommand=function(self, params)
				if params.tns == "Miss" or tns == "MissedHold" then
					self:diffuse(1,0,0,0.66)
				elseif not FAplus and params.tns == "W5" then
					self:diffuse(0.78, 0.52, 0.36, 0.66)
				elseif (FAplus and params.tns == "W5") or (not FAplus and params.tns == "W4") then
					self:diffuse(0.70, 0.36, 1.00, 0.66)
				elseif (FAplus and params.tns == "W4") or (not FAplus and params.tns == "W3") then
					self:diffuse(0.40, 0.79, 0.33, 0.66)
				elseif (FAplus and params.tns == "W3") or (not FAplus and params.tns == "W2") then
					self:diffuse(0.88, 0.61, 0.09, 0.66)
				elseif (FAplus and params.tns == "W2") or params.tns == "W1" then
					self:diffuse(0.13, 0.80, 0.91, 0.66)
				end
				
				if params.tns == "Miss" or tns == "MissedHold" then
					self:accelerate(0.16):diffuse(0,0,0,0)
				else
					self:accelerate(0.33):diffuse(0,0,0,0)
				end
			end
		}
	end

	return af

end