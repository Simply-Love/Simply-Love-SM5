-- HACK: Reset MusicRate to 1.0 every time this screen is accessed
-- because MusicRate will otherwise persist from one song to another in EditMode
-- due to the way I'm applying it in Edit Mode's PlayerOpions menu.
-- see the MusicRate OptionRow definition in ./Scripts/SL-PlayerOptions.lua
GAMESTATE:ApplyGameCommand("mod,1.0xmusic")
SL.Global.ActiveModifiers.MusicRate = 1

-- down lower in this file, we loop seven times to create seven "rows" of grey quads
-- one for each: group, song, type, steps, fill type, fill steps, action
-- in that loop, rowYvalues will be filled with each row's Y value (defined in metrics)
local rowYvalues = {}
for i=1,7 do
	-- fill our table with each row's Y value from the Metrics
	table.insert(rowYvalues, THEME:GetMetric("EditMenu", "Row"..i.."Y"))
end

local t = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	OnCommand=function(self)
		self:linear(0.15):diffusealpha(1):queuecommand("ApplyColor")
	end,
	EditMenuChangeMessageCommand=function(self) self:playcommand("ApplyColor") end,

	ApplyColorCommand=function(self)

		local topscreen = SCREENMAN:GetTopScreen()

		if topscreen then
			local editMenu = topscreen:GetChild("EditMenu")

			local cursor = editMenu:GetChild("")
			local cursorY = cursor:GetY()

			local songTextBanner = editMenu:GetChild("SongTextBanner")
			local rowHighlight = self:GetChild("RowHighlight")


			for i=1,#rowYvalues do

				-- if this row is "active"
				if cursorY == rowYvalues[i] then
					editMenu:GetChild("Label"..i):diffuse( 0,0,0,1 ):shadowlength(0)
					editMenu:GetChild("Value"..i):diffuse( 0,0,0,1 ):shadowlength(0)

					-- row2 has a textbanner and needs to be handled differently
					if cursorY == rowYvalues[2] then
						songTextBanner:GetChild("Title"):diffuse( 0,0,0,1 ):shadowlength(0)
						songTextBanner:GetChild("Subtitle"):diffuse( 0,0,0,1 ):shadowlength(0)
					end

					if cursorY == rowYvalues[4] then
						editMenu:GetChild("StepsDisplay"):diffuse( 0,0,0,1 )
					end
					if cursorY == rowYvalues[6] then
						editMenu:GetChild("StepsDisplaySource"):GetChild("Meter"):diffuse( 0,0,0,1 )
					end

				else
					editMenu:GetChild("Label"..i):diffuse(1,1,1,1):shadowlength(1)
					editMenu:GetChild("Value"..i):diffuse(1,1,1,1):shadowlength(1)

					if cursorY ~= rowYvalues[2] then
						songTextBanner:GetChild("Title"):diffuse(1,1,1,1):shadowlength(1)
						songTextBanner:GetChild("Subtitle"):diffuse(1,1,1,1):shadowlength(1)
					end

					if cursorY ~= rowYvalues[4] then
						editMenu:GetChild("StepsDisplay"):diffuse(1,1,1,1)
					end
					if cursorY ~= rowYvalues[6] then
						editMenu:GetChild("StepsDisplaySource"):GetChild("Meter"):diffuse(1,1,1,1)
					end
				end

				rowHighlight:y(cursorY+1)

				if cursorY == rowYvalues[7] then
					rowHighlight:diffuse(PlayerColor(PLAYER_2))
				else
					rowHighlight:diffuse(GetCurrentColor())
				end
			end


		end
	end,
	-- MeterSetMessage is broadcast from Metrics under [StepsDisplay] MeterSetCommand
	-- I'm (ab)using it here to force the meter on Row4 to always be black
	-- even when the user is sitting on Row4 flipping between difficulties
	MeterSetMessageCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()

		if topscreen then
			local editMenu = topscreen:GetChild("EditMenu")
			local cursor = editMenu:GetChild("")

			if cursor then
				local cursorY = cursor:GetY()
				if cursorY == rowYvalues[4] then
					editMenu:GetChild("StepsDisplay"):diffuse(0,0,0,1)
				end
			end
		end
	end
}

-- the overall BG
t[#t+1] = Def.Quad {
	InitCommand=function(self) self:zoomto(_screen.w*0.9, _screen.h*0.725):diffuse(0,0,0,1) end,
	OnCommand=function(self) self:Center() end
}


-- loop seven times to create seven dark-grey rows
for i=1,7 do
	-- a row
	t[#t+1] = Def.Quad {
		InitCommand=function(self) self:zoomto(_screen.w*0.745, _screen.h*0.0885):diffuse(color("#071016")) end,
		OnCommand=function(self) self:xy(_screen.cx + WideScale(49,65), 40 + (i*45)) end
	}
end

-- the grey BG for row labels
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:Center():zoomto(_screen.w*0.15,_screen.h*0.725):diffuse(color("#212831")):x(_screen.cx-WideScale(240,320)) end
}

-- the grey BG for the instructions at the bottom
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w*0.745,_screen.h*0.0725):diffuse(color("#212831")) end,
	OnCommand=function(self) self:xy(_screen.cx + WideScale(49,65), 396) end,
}

t[#t+1] = Def.Quad{
	Name="RowHighlight",
	OnCommand=function(self) self:x(_screen.cx):setsize(_screen.w*0.9-4, _screen.h*0.088) end,
}


-- white border
t[#t+1] = Border(_screen.w*0.9, _screen.h*0.734, 2)..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy) end,
}

-- -----------------------------------------------------------------------

t[#t+1] = LoadActor("./LastSeenSong.lua")

-- -----------------------------------------------------------------------


return t