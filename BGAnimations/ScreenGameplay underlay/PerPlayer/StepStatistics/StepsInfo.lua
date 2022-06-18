local player = ...
local pn = ToEnumShortString(player)
local pnum = tonumber(player:sub(-1))

local mods = SL[pn].ActiveModifiers
if (mods.StepInfo == false) then return end

-- Positioning
local c = PREFSMAN:GetPreference("Center1Player")
local ar = GetScreenAspectRatio()
local ws = IsUsingWideScreen()

local x = ws and -190 or -155
local xoffset = pnum == 1 and (ws and 285 or 225) or 0

local y = -8
local yoffset = 0

local zoom = 0.75
local xvalues = (not c and ar < 1.5) and 0 or 45
local maxwidth = ws and 320 or 300

local row_height = 16

if c then -- Center 1 player has different position and zoom for step stats
	xvalues = 0 -- Removes labels
	yoffset = -5
	if ar > 1.7 then -- 16:9
		x = pnum == 1 and -220 or -150
		maxwidth = 240
		zoom = 0.9
	else --16:10
		x = pnum == 1 and -240 or -150
		maxwidth = 210
		zoom = 0.95
	end
end

local SongNumberInCourse = 0
local author_table = {}
	
-- Master position and zoom
local af = Def.ActorFrame { 
	OnCommand=function(self)
		self:xy((x+xoffset)*(pnum*2-3) ,y+yoffset)	
		self:zoom(zoom)
	end,
	CurrentSongChangedMessageCommand=function(self)
		SongNumberInCourse = SongNumberInCourse + 1 
	end,
}  

local s
local sd

local GetSongAndSteps = function(player) 
	-- Return song ID and step data ID
	local song
	local steps
	
	if GAMESTATE:IsCourseMode() then
		local songindex = GAMESTATE:GetCourseSongIndex()
		local trail = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[songindex+1]
		steps = trail:GetSteps()
		song = GAMESTATE:GetCurrentCourse():GetCourseEntry(songindex):GetSong()
	else
		song = GAMESTATE:GetCurrentSong()
		steps = GAMESTATE:GetCurrentSteps(player)			
	end
	
	return song, steps
end

local getAuthorTable = function(steps)
	-- Returns a table of max 3 rows of step data
	-- like step author, chart artist, tech notation, stream breakdown,  meme quotes
	local desc = steps:GetDescription()
	local author_table = {}
	
	if desc ~= "" then author_table[#author_table+1] = desc end

	local cred = steps:GetAuthorCredit()
	if cred ~= "" and (not FindInTable(cred, author_table)) then author_table[#author_table+1] = cred end

	local name = steps:GetChartName()
	if name ~= "" and (not FindInTable(name, author_table)) then author_table[#author_table+1] = name end

	return author_table
end

-- Labels
local labels = { "Song", "Artist", "Pack", "Desc" }
if not c and ar > 1.5 then -- only display labels if using widescreen and not using center 1 player
	for i = 1, #labels do
		af[#af+1] = Def.BitmapText{
			Font="Common Normal",
			OnCommand=function(self)
				self:settext(labels[i])
				self:y(row_height*i)
				self:horizalign("left")
			end
		}
	end
end

-- Course mode now works maybe
af[#af+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:x(xvalues)
	end,
	-- Song name
	Def.BitmapText {
		Font="Common Normal",
		OnCommand=function(self)			
			self:horizalign("left")
			self:y(row_height)
			self:maxwidth(maxwidth)
		end,
		CurrentSongChangedMessageCommand=function(self)
			local song, steps = GetSongAndSteps(player)
			self:settext(song:GetTranslitFullTitle())
		end
	},
	-- Artist name
	Def.BitmapText{
		Font="Common Normal",
		OnCommand=function(self)
			self:horizalign("left")
			self:y(row_height*2)
			self:maxwidth(maxwidth)
		end,
		CurrentSongChangedMessageCommand=function(self)
			local song, steps = GetSongAndSteps(player)
			self:settext(song:GetTranslitArtist())
		end
	},
	-- Pack name
	Def.BitmapText{
		Font="Common Normal",
		OnCommand=function(self)
			self:horizalign("left")
			self:y(row_height*3)
			self:maxwidth(maxwidth)
		end,
		CurrentSongChangedMessageCommand=function(self)
			local song, steps = GetSongAndSteps(player)
			self:settext(song:GetGroupName())
		end
	},
	-- Author
	Def.BitmapText{
		Font="Common Normal",
		OnCommand=function(self)
			self:y(row_height*4)
			self:horizalign("left")
			self:maxwidth(maxwidth)
			
			-- Reset the text (mainly for course mode)
			self:settext("")
			author_table = {}
			
			-- it returns an error if I take this part out idk why
			local song, steps = GetSongAndSteps(player)
			
			author_table = getAuthorTable(steps)
			
			marquee_index = 0
			-- Loop the author field
			if #author_table > 0 then
				self:queuecommand("Marquee")
			else
				self:settext("")
			end
			if #author_table > 1 then
				self:queuecommand("Marquee")
			end
		
		end,
		CurrentSongChangedMessageCommand=function(self)
			-- Reset the text (mainly for course mode)	
			self:settext("")
			author_table = {}

			local song, steps = GetSongAndSteps(player)
			
			author_table = getAuthorTable(steps)
			
			marquee_index = 0
			-- Loop the author field
			if #author_table > 0 then
				self:queuecommand("Marquee")
			else
				self:settext("")
			end
			if #author_table > 1 then
				self:queuecommand("Marquee")
			end
			
		end,
		MarqueeCommand=function(self)
			marquee_index = (marquee_index % #author_table) + 1
			local text = author_table[marquee_index]
			self:settext(text)
			DiffuseEmojis(self,text)
			if marquee_index == #author_table then
				marquee_index = 0
			end
			self:sleep(2):queuecommand("Marquee")
		end,
	}
}

return af