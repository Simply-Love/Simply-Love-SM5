local SelectedButtonColor = "#3b3b3b"
local DimmedButtonColor = "#222222"
local UnselectedTextColor = "#bdbdbd"
local NoTextColor = "#f23535"
local YesTextColor = "#40d622"
local NoButtonColor = "#222222"
local YesButtonColor = "#222222"

-- This is just the frame and darkened background for the Sort Menu.
-- and also text

local t = Def.ActorFrame{
	Name="SortMenu",
	InitCommand=function(self)
		self:draworder(105)
	end,

	SortMenuOptionSelectedMessageCommand=function(self)
		
		if DDSortMenuCursorPosition < 8 then
			MESSAGEMAN:Broadcast('ToggleSortMenuMovement')
		end
		
	end,

--- something to darken the bg
	Def.Quad{
			Name="DarkenBG",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
					self:draworder(0)
					self:diffuse(color("#000000"))
					self:zoomx(SCREEN_WIDTH)
					self:zoomy(SCREEN_HEIGHT)
					self:diffusealpha(0.9)
					self:visible(true)
			end,
		},

	---- a lil border to make it look less plain and give it definition
	Def.Quad{
			Name="MenuBorder",
			InitCommand=function(self)
					self:draworder(0)
					self:diffuse(color("#FFFFFF"))
					self:zoomx(305)
					self:diffusealpha(0.6)
					self:visible(true)
					self:queuecommand('UpdateZoom')
			end,
			InitializeDDSortMenuMessageCommand=function(self)
				self:queuecommand('UpdateZoom')
			end,
			UpdateZoomCommand=function(self)
				local curSong = GAMESTATE:GetCurrentSong()
				local SongIsSelected
				
				if curSong then 
					SongIsSelected = true
				else
					SongIsSelected = false
				end
				self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
				-- initial zoom before additional options are added
				local InitialZoomY = 205
				local InitialAddY = -50
				
				if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
					InitialZoomY = InitialZoomY + 25
					InitialAddY = InitialAddY + 12.5
				end
				
				self:zoomy(InitialZoomY)
				self:addy(InitialAddY)
			end,
		},
		
	---- dark bg to make menu text pop
	Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:draworder(0)
					self:diffuse(color("#111111"))
					self:zoomx(300)
					self:queuecommand('UpdateZoom')
					self:visible(true)
			end,
			InitializeDDSortMenuMessageCommand=function(self)
				self:queuecommand('UpdateZoom')
			end,
			UpdateZoomCommand=function(self)
				local curSong = GAMESTATE:GetCurrentSong()
				local SongIsSelected
				
				if curSong then 
					SongIsSelected = true
				else
					SongIsSelected = false
				end
				
				self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
				-- initial zoom before additional options are added
				local InitialZoomY = 200
				local InitialAddY = -50
				
				if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
					InitialZoomY = InitialZoomY + 25
					InitialAddY = InitialAddY + 12.5
				end
				
				self:zoomy(InitialZoomY)
				self:addy(InitialAddY)
			end,
		},
		
			---- a littler border to seperate the top and bottom half of the menu
	Def.Quad{
			Name="MenuBorder",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y - 41)
					self:draworder(0)
					self:diffuse(color("#FFFFFF"))
					self:zoomx(300)
					self:zoomy(3)
					self:diffusealpha(0.6)
					self:visible(true)
			end,
		},
		--------------- Here be the quads for the text on the right side of the top menu ---------------
		----- MAIN SORT BOX -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 135)
					self:draworder(0)
					self:diffuse(color("#3b3b3b"))
					self:zoomx(190)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(right)
			end,
		},
		
		----- DIFFICULTY FILTER BOX 1 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 35,SCREEN_CENTER_Y - 110)
					self:draworder(0)
					self:diffuse(color("#3b3b3b"))
					self:zoomx(40)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(center)
			end,
		},
		
		----- DIFFICULTY FILTER BOX 2 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 115,SCREEN_CENTER_Y - 110)
					self:draworder(0)
					self:diffuse(color("#3b3b3b"))
					self:zoomx(40)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(center)
			end,
		},
		----- DIFFICULTY FILTER TO
		Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#919191"))
			self:horizalign(center)
			self:x(SCREEN_CENTER_X + 74)
			self:y(SCREEN_CENTER_Y - 110)
			self:zoom(1.25)
			self:settext("to")
		end,
		},
		
		----- BPM FILTER BOX 1 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X - 20,SCREEN_CENTER_Y - 85)
					self:draworder(0)
					self:diffuse(color("#3b3b3b"))
					self:zoomx(40)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(center)
			end,
		},
		
		----- BPM FILTER BOX 2 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 60,SCREEN_CENTER_Y - 85)
					self:draworder(0)
					self:diffuse(color("#3b3b3b"))
					self:zoomx(40)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(center)
			end,
		},
		
		----- BPM FILTER TO
		Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#919191"))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 18,SCREEN_CENTER_Y - 85)
			self:zoom(1.25)
			self:settext("to")
		end,
		},
		
		----- Length FILTER BOX 1 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 16,SCREEN_CENTER_Y - 60)
					self:draworder(0)
					self:diffuse(color("#3b3b3b"))
					self:zoomx(65)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(center)
			end,
		},
		
		----- Length FILTER BOX 2 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 115,SCREEN_CENTER_Y - 60)
					self:draworder(0)
					self:diffuse(color("#3b3b3b"))
					self:zoomx(65)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(center)
			end,
		},
		
		----- BPM FILTER TO
		Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#919191"))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 64,SCREEN_CENTER_Y - 60)
			self:zoom(1.25)
			self:settext("to")
		end,
		},
}

--- When changing between single/double show the correct mode to switch to.
local stepsType = GAMESTATE:GetCurrentStyle():GetStepsType()
switchStepsTypeLabel = ""
if stepsType == 'StepsType_Dance_Single' then
	switchStepsTypeLabel = 'SWITCH TO DOUBLE'
else
	switchStepsTypeLabel = 'SWITCH TO SINGLE'
end

--- When changing between Song/Course select show the correct mode to switch to.
local currentPlayMode = GAMESTATE:GetPlayMode()
switchCourseSongSelectLabel = ""

if currentPlayMode == 'PlayMode_Regular' then
	switchCourseSongSelectLabel = "GO TO COURSE MODE"
else
	switchCourseSongSelectLabel = "GO TO SONG SELECT"
end

SortLabel = {
	"MAIN SORT:",
}

FilterLabel = {
	"FILTER DIFFICULTY:",
	"FILTER BPM:",
	"FILTER LENGTH:",
}

for i,SortText in ipairs(SortLabel) do
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(right)
			self:x(SCREEN_CENTER_X - 50)
			self:y(SCREEN_CENTER_Y - 160 + 25*i)
			self:zoom(1.25)
			self:settext(SortText)
		end,
	}
end

for i,FilterText in ipairs(FilterLabel) do
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(left)
			self:x(SCREEN_CENTER_X - 140)
			self:y(SCREEN_CENTER_Y - 135 + 25*i)
			self:zoom(1.25)
			self:settext(FilterText)
		end,
	}
end

OtherLabel = {}
OtherLabel[#OtherLabel+1] = "RESET SORT/FILTERS"
OtherLabel[#OtherLabel+1] = switchCourseSongSelectLabel

-- OtherLabel[#OtherLabel+1] = "MARK AS FAVORITE"
if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
	OtherLabel[#OtherLabel+1] = switchStepsTypeLabel
end
OtherLabel[#OtherLabel+1] = "TEST INPUT"


for i,OtherText in ipairs(OtherLabel) do
	t[#t+1] = Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(center)
			self:x(SCREEN_CENTER_X)
			self:zoom(1.25)
			self:settext(OtherText)
			self:queuecommand('Update')
		end,
		InitializeDDSortMenuMessageCommand=function(self)
			self:queuecommand('Update')
		end,
		UpdateCommand=function(self)
			local curSong = GAMESTATE:GetCurrentSong()
			local active_index = i

			active_index = i - 1
			self:y(SCREEN_CENTER_Y - 20 + 25*active_index)
		end,
	}
end

return t