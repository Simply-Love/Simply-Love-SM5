--HACK: Reset MusicRate to 1.0 every time this screen is accessed
-- because, otherwise, it can persist from editing one song with a
-- ratemod applied into another, different song.
--
-- see: OptionRowSongMusicRate() in ./Scripts/SL-PlayerOptions.lua
GAMESTATE:ApplyGameCommand("mod,1.0xmusic")
SL.Global.ActiveModifiers.MusicRate = 1


-- down lower in this file, we loop seven times to create seven "rows" of grey quads
-- one for each: group, song, type, steps, fill type, fill steps, action
-- in that loop, rowYvalues will be filled with each row's Y value (defined in metrics)
local rowYvalues = {};


local t = Def.ActorFrame{
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(linear,0.15; diffusealpha,1; queuecommand, "Hax");
	--playcommand seems more responsive than queuecommand, so use it here
	--or else we see a frame or two where the cursor color hasn't been applied yet (HAX)
	EditMenuChangeMessageCommand=cmd(playcommand, "Hax");
	HaxCommand=function(self)

		local topscreen = SCREENMAN:GetTopScreen();

		if topscreen then
			local editMenu = topscreen:GetChild("EditMenu");

			local cursor = editMenu:GetChild("");
			local cursorY = cursor:GetY();

			local songTextBanner = editMenu:GetChild("SongTextBanner");
			local rowHighlight = self:GetChild("RowHighlight");


			for i=1,#rowYvalues do

				-- if this row is "active"
				if cursorY == rowYvalues[i] then
					editMenu:GetChild("Label"..i):diffuse( Color.Black )
					editMenu:GetChild("Label"..i):shadowlength(0)
					editMenu:GetChild("Value"..i):diffuse( Color.Black )
					editMenu:GetChild("Value"..i):shadowlength(0)

					-- row2 has a textbanner and needs to be handled differently
					if cursorY == rowYvalues[2] then
						songTextBanner:GetChild("Title"):diffuse( Color.Black )
						songTextBanner:GetChild("Title"):shadowlength(0)
						songTextBanner:GetChild("Subtitle"):diffuse( Color.Black )
						songTextBanner:GetChild("Subtitle"):shadowlength(0)
					end

					if cursorY == rowYvalues[4] then
						editMenu:GetChild("StepsDisplay"):GetChild("Meter"):diffuse( Color.Black )
					end
					if cursorY == rowYvalues[6] then
						editMenu:GetChild("StepsDisplaySource"):GetChild("Meter"):diffuse( Color.Black )
					end

				else
					editMenu:GetChild("Label"..i):diffuse(color("#FFFFFF"))
					editMenu:GetChild("Value"..i):diffuse(color("#FFFFFF"))
					editMenu:GetChild("Label"..i):shadowlength(1)
					editMenu:GetChild("Value"..i):shadowlength(1)

					if cursorY ~= rowYvalues[2] then
						songTextBanner:GetChild("Title"):diffuse(color("#FFFFFF"))
						songTextBanner:GetChild("Title"):shadowlength(1)
						songTextBanner:GetChild("Subtitle"):diffuse(color("#FFFFFF"))
						songTextBanner:GetChild("Subtitle"):shadowlength(1)
					end

					if cursorY ~= rowYvalues[4] then
						editMenu:GetChild("StepsDisplay"):GetChild("Meter"):diffuse(color("#FFFFFF"))
					end
					if cursorY ~= rowYvalues[6] then
						editMenu:GetChild("StepsDisplaySource"):GetChild("Meter"):diffuse(color("#FFFFFF"))
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
					editMenu:GetChild("StepsDisplay"):GetChild("Meter"):diffuse( Color.Black )
				end
			end
		end
	end
}


-- the overall BG
t[#t+1] = Def.Quad {
	InitCommand=cmd(zoomto,_screen.w*0.9,_screen.h*0.725; diffuse,Color.Black),
	OnCommand=cmd(xy,_screen.cx,_screen.cy)
}


-- loop seven times to create seven dark-grey rows
for i=1,7 do
	-- a row
	t[#t+1] = Def.Quad {
		InitCommand=cmd(zoomto,_screen.w*0.745, _screen.h*0.0885; diffuse,color("#071016")),
		OnCommand=cmd(xy, _screen.cx + WideScale(49,65), 40 + (i*45))
	}

	-- fill our table with each row's Y value from the Metrics
	rowYvalues[#rowYvalues+1] = THEME:GetMetric("EditMenu", "Row"..i.."Y")

end

-- the grey BG for row labels
t[#t+1] = Def.Quad {
	InitCommand = cmd(Center;zoomto,_screen.w*0.15,_screen.h*0.725;diffuse,color("#212831"); x, _screen.cx-WideScale(240,320))
}

-- the grey BG for the instructions at the bottom
t[#t+1] = Def.Quad {
	InitCommand=cmd(zoomto,_screen.w*0.745,_screen.h*0.0725; diffuse,color("#212831")),
	OnCommand=cmd(xy, _screen.cx + WideScale(49,65), 396)
}

t[#t+1] = Def.Quad {
	Name="RowHighlight",
	OnCommand=cmd(x, _screen.cx; setsize, _screen.w*0.9 - 4,_screen.h*0.088)
}


-- white border
t[#t+1] = Border(_screen.w*0.9, _screen.h*0.734, 2) .. {
	InitCommand = cmd(xy,_screen.cx, _screen.cy),
}

return t