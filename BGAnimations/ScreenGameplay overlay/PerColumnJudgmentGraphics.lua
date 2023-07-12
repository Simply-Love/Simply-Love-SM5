local player = ...
local pn = ToEnumShortString(player)

local mods = SL[pn].ActiveModifiers
if SL.Global.GameMode == "Casual" then return end
if not mods.ColumnCues then return end

local column_mapping = GetColumnMapping(player)

-- Disable column cues if we couldn't compute valid column_mapping
if column_mapping == nil then return end

local playerState = GAMESTATE:GetPlayerState(player)
local columnCues = SL[pn].Streams.ColumnCues

local numColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local style = GAMESTATE:GetCurrentStyle(player)
local width = style:GetWidth(player)

local yOffset = 50
local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)

local available_graphics = GetHeldMissGraphics()

local file_to_load = (FindInTable(mods.HeldGraphic, available_graphics) ~= nil and mods.HeldGraphic or available_graphics[1]) or "None"

if file_to_load == "None" then
	return Def.Actor{
		InitCommand=function(self) self:visible(false) end
	}
end

local af = Def.ActorFrame{
	InitCommand=function(self)
		local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
		self:xy( GetNotefieldX(player), (opts:Reverse() == 1) and yOffset*2+10 or -yOffset)
		self:zoomx( zoom_factor )
	end,
}

local IsReversedColumn = function(player, columnIndex)
	local columns = {}
	for i=1, numColumns do
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
			if column > numColumns / 2 then
				columns[column] = not val
			end
		end
	end

	if opts:Cross() == 1 then
		local firstChunk = numColumns / 4
		local lastChunk = numColumns - firstChunk
		for column,val in ipairs(columns) do
			if column > firstChunk and column <= lastChunk then
				columns[column] = not val
			end
		end
	end

	return columns[columnIndex]
end

for columnIndex=1,numColumns do
	local sprite
	af[#af+1] = Def.ActorFrame{
		Name="Column"..columnIndex,
		InitCommand=function(self)
			self:x((columnIndex - (numColumns/2 + 0.5)) * (width/numColumns))
					:vertalign('VertAlign_Top')
					:setsize(width/numColumns, _screen.h - yOffset)
					
			local kids = self:GetChildren()
			sprite = kids.HeldMiss
		end,
		JudgmentMessageCommand=function(self, param)
			if param.Player ~= player then return end
			if not param.TapNoteScore then return end
			if param.HoldNoteScore then return end

			local tns = ToEnumShortString(param.TapNoteScore)
			
			-- support for "held miss" sprite on the "early miss" column
			-- currently only a few judgment fonts do this... not sure if I should write a toggle
			-- option in the future since turning it on for a judgment without the distinction
			-- would accomplish nothing
			if tns == "Miss" then
				local isHeld = false
				for col,tapnote in pairs(param.Notes) do
					local tnt = ToEnumShortString(tapnote:GetTapNoteType())
					if tnt == "Tap" or tnt == "HoldHead" or tnt == "Lift" then
						local tns = ToEnumShortString(param.TapNoteScore)
						if tnt ~= "Lift" and tns == "Miss" and tapnote:GetTapNoteResult():GetHeld() and ("Column"..col) == self:GetName() then
							sprite:visible(true)
							sprite:finishtweening():stopeffect()
							-- this should match the custom JudgmentTween() from SL for 3.95
							local mini = mods.Mini:gsub("%%","") / 100
							sprite:zoom(0.8):zoomy(0.75 * (1 - mini/2)):decelerate(0.1):zoom(0.75):zoomy(0.75 * (1 - mini/2)):sleep(0.2):accelerate(0.2):zoom(0)
						end
					end
				end
			end
		end,
		Def.Sprite{
			Name="HeldMiss",
			InitCommand=function(self)
				-- animate(false) is needed so that this Sprite does not automatically
				-- animate its way through all available frames; we want to control which
				-- frame displays based on what judgment the player earns
				self:animate(false):visible(false)

				local mini = mods.Mini:gsub("%%","") / 100
				self:addx((mods.NoteFieldOffsetX * (1 + mini)) * 2)
				self:addy((mods.NoteFieldOffsetY * (1 + mini)) * 2)
				
				-- if we are on ScreenEdit, judgment graphic is always "Love"
				-- because ScreenEdit is a mess and not worth bothering with.
				if string.match(tostring(SCREENMAN:GetTopScreen()), "ScreenEdit") then
					self:Load( THEME:GetPathG("", "_HeldMiss/Love") )

				else
					self:Load( THEME:GetPathG("", "_HeldMiss/" .. file_to_load) )
				end
			end,
			ResetCommand=function(self) self:finishtweening():stopeffect():visible(false) end
		},
	}
end

return af