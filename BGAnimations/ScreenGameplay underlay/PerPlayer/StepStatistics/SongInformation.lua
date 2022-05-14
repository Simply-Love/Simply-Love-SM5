local player = ...
local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)
local CurSongName
local ArtistName
local course_index
local TotalCourseSongs
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)
local MaxWidth = NoteFieldIsCentered and 134 or 195
local count = 0

-- initalize song/course info
if GAMESTATE:IsCourseMode() then
	course_index = 0
	TotalCourseSongs = GAMESTATE:GetCurrentCourse():GetNumCourseEntries()
	CurSongName = GAMESTATE:GetCurrentCourse():AllSongsAreFixed() and GAMESTATE:GetCurrentCourse():GetCourseEntry(0):GetSong():GetDisplayFullTitle() or "???"
	ArtistName = GAMESTATE:GetCurrentCourse():AllSongsAreFixed() and GAMESTATE:GetCurrentCourse():GetCourseEntry(0):GetSong():GetDisplayArtist() or "???"	
else
	CurSongName =  GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
	ArtistName = GAMESTATE:GetCurrentSong():GetDisplayArtist()
end
-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}
af.InitCommand=function(self)
	self:xy((P1 and -340 or 35),-50)
	if NoteFieldIsCentered then
		self:x(P1 and -275 or 35)
		self:y(-45)
		self:zoom(0.9)
	end
end

if GAMESTATE:IsCourseMode() then

-- in course mode show the song # out of the total # of songs in the course

-- Song # Label
af[#af+1] = LoadFont("Common Normal")..{
	Text=("%s "):format( THEME:GetString("Stage", "Stage").." # "),
	InitCommand=function(self) self:horizalign(right):xy(20, 0):zoom(1.2)
		if P1 then
			self:x(206)
		end
	end,
	CurrentSongChangedMessageCommand=function(self)
		self:sleep(0.2):queuecommand('UpdateJawn')
	end,
	UpdateJawnCommand=function(self)
		self:settext(("%s "):format( THEME:GetString("Stage", "Stage").."  # "))
	end,
}

-- # song out of total songs in course
af[#af+1] = LoadFont("Common Normal")..{
	Text=("%s "):format( tonumber(course_index).." / " .. tonumber(TotalCourseSongs)),
	InitCommand=function(self) self:horizalign(left):xy(16, 0):zoom(1.2) 
		if P1 then
			self:x(200)
		end
	end,
	CurrentSongChangedMessageCommand=function(self)
		course_index = course_index + 1
		self:sleep(0.2):queuecommand('UpdateJawn')
	end,
	UpdateJawnCommand=function(self)
		CurSongName = GAMESTATE:GetCurrentCourse():AllSongsAreFixed() and GAMESTATE:GetCurrentCourse():GetCourseEntry(course_index - 1):GetSong():GetDisplayFullTitle() or "???"
		ArtistName = GAMESTATE:GetCurrentCourse():AllSongsAreFixed() and GAMESTATE:GetCurrentCourse():GetCourseEntry(course_index - 1):GetSong():GetDisplayArtist() or "???"
		self:settext(("%s "):format( tonumber(course_index).." / " .. tonumber(TotalCourseSongs)))
	end,
}
end

-- -----------------------------------------------------------------------
-- current song label

af[#af+1] = LoadFont("Common Normal")..{
	Text=("%s "):format( THEME:GetString("ScreenGameplay", "Song")..":" ),
	InitCommand=function(self) self:horizalign(right):xy(-6, 18):zoom(0.7) 
		if P1 then
			self:x(180)
		end
	end,
	
}

-- current song name
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:horizalign(left):xy(0,18)
		:zoom(0.9)
		:maxwidth(MaxWidth)
		:settext(CurSongName)
		if P1 then
			self:x(180)
		end
	end,
	CurrentSongChangedMessageCommand=function(self)
		self:sleep(0.2):queuecommand('UpdateJawn')
	end,
	UpdateJawnCommand=function(self)
		self:settext(CurSongName)
	end,
}

-- Artist label
af[#af+1] = LoadFont("Common Normal")..{
	Text=("%s "):format( THEME:GetString("ScreenGameplay", "Artist")..":"	),
	InitCommand=function(self) 
		self:horizalign(right)
		:xy(-6, 36)
		:zoom(0.7)
		if P1 then
			self:x(180)
		end
	end
	
}


-- Artist name
af[#af+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:settext(ArtistName)
		:horizalign(left):xy(0,36)
		:zoom(0.9)
		:maxwidth(MaxWidth)
		if P1 then
			self:x(180)
		end
	end,
	
	CurrentSongChangedMessageCommand=function(self)
		self:sleep(0.2):queuecommand('UpdateJawn')
	end,
	UpdateJawnCommand=function(self)
		self:settext(ArtistName)
	end,
	
}

-- -----------------------------------------------------------------------

return af