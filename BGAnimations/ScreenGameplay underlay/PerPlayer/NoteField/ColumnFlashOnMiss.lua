-- don't allow ColumnFlashOnMiss to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then return end

local player = ...
local mods = SL[ToEnumShortString(player)].ActiveModifiers

local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local IsReversedColumn = function(player, columnIndex)
	local columns = {}
	for i=1, NumColumns do
		columns[#columns + 1] = false
	end

	local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
	if opts:Reverse() == 1 then
		for column,val in ipairs(columns) do
			columns[column] = not val
		end
	end

	if opts:Alternate() == 1 then
		for column,val in ipairs(columns) do
			if column % 2 == 0 then
				columns[column] = not val
			end
		end
	end

	if opts:Split() == 1 then
		for column,val in ipairs(columns) do
			if column > NumColumns / 2 then
				columns[column] = not val
			end
		end
	end

	if opts:Cross() == 1 then
		local firstChunk = NumColumns / 4
		local lastChunk = NumColumns - firstChunk
		for column,val in ipairs(columns) do
			if column > firstChunk and column <= lastChunk then
				columns[column] = not val
			end
		end
	end

	return columns[columnIndex]
end

if mods.ColumnFlashOnMiss then
	local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Preferred')
	-- Existing logic already accounts for turn mods but not flip or invert.
	-- Manually try and account for it ourselves here.
	local flip = po:Flip() > 0
	local invert = po:Invert() > 0
	
	if flip and invert then return end

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
	local reverseOffset = THEME:GetMetric("Player", "ReceptorArrowsYReverse")

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
					if tns == "Miss" or tns == "MissedHold" then
						columns[column_mapping[i]]:playcommand("Flash")
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

				if IsReversedColumn(player, ColumnIndex) then
					self:rotationz(180)
					self:y(y_offset * 2 + reverseOffset + (width/NumColumns)/2)
				end
	        end,
			FlashCommand=function(self)
				self:diffuse(1,0,0,0.66)
					:accelerate(0.165):diffuse(0,0,0,0)
			end
		}
	end

	return af

end