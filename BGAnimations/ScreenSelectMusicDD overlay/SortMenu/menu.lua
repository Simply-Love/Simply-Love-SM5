local SelectedButtonColor = "#3b3b3b"
local DimmedButtonColor = "#222222"
local UnselectedTextColor = "#bdbdbd"
local NoTextColor = "#f23535"
local YesTextColor = "#40d622"
local NoButtonColor = "#222222"
local YesButtonColor = "#222222"

-- This is just the frame and darkened background for the Sort Menu.
-- and also text


----- Favorite filter settings ----- 
--[[local function GetFavoriteFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'FavoriteFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'FavoriteFilter')
	end

	if value == nil then
		value = 'No'
		NoButtonColor = SelectedButtonColor
		YesButtonColor = DimmedButtonColor
	end
	
	if value == "No" then
		NoButtonColor = SelectedButtonColor
		YesButtonColor = DimmedButtonColor
	elseif value == "Yes" then
		NoButtonColor = DimmedButtonColor
		YesButtonColor = SelectedButtonColor
	end

	return value
end--]]


local function SetFavoriteFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'FavoriteFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Groovestats filter settings ----- 
local function GetGroovestatsFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'GroovestatsFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'GroovestatsFilter')
	end

	if value == nil then
		value = 'No'
		NoButtonColor = SelectedButtonColor
		YesButtonColor = DimmedButtonColor
	end
	
	if value == "No" then
		NoButtonColor = SelectedButtonColor
		YesButtonColor = DimmedButtonColor
	elseif value == "Yes" then
		NoButtonColor = DimmedButtonColor
		YesButtonColor = SelectedButtonColor
	end

	return value
end

local t = Def.ActorFrame{
	Name="SortMenu",
	InitCommand=function(self)
		self:draworder(105)
		--[[if GetFavoriteFilter() == 'Yes' then
			MESSAGEMAN:Broadcast('FavoriteFilterYes')
		else
			MESSAGEMAN:Broadcast('FavoriteFilterNo')
		end--]]
		
		if GetGroovestatsFilter() == 'Yes' then
			MESSAGEMAN:Broadcast('GroovestatsFilterYes')
		else
			MESSAGEMAN:Broadcast('GroovestatsFilterNo')
		end
	end,

	SortMenuOptionSelectedMessageCommand=function(self)
		
		if DDSortMenuCursorPosition < 9 then
			MESSAGEMAN:Broadcast('ToggleSortMenuMovement')
		end
		
		--[[if DDSortMenuCursorPosition == 9 then
			if GetFavoriteFilter() == 'No' then
				SetFavoriteFilter('Yes')
				MESSAGEMAN:Broadcast('FavoriteFilterYes')
			else
				SetFavoriteFilter('No')
				MESSAGEMAN:Broadcast('FavoriteFilterNo')
			end
		end--]]
		
		if DDSortMenuCursorPosition == 9 then
			if GetGroovestatsFilter() == 'No' then
				SetGroovestatsFilter('Yes')
				MESSAGEMAN:Broadcast('GroovestatsFilterYes')
			else
				SetGroovestatsFilter('No')
				MESSAGEMAN:Broadcast('GroovestatsFilterNo')
			end
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
				local InitialZoomY = 230
				local InitialAddY = -37.5
				
				if ThemePrefs.Get("AllowSongSearch") then
					InitialZoomY = InitialZoomY + 25
					InitialAddY = InitialAddY + 12.5
				end
				if IsServiceAllowed(SL.GrooveStats.Leaderboard) and SongIsSelected then
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
				local InitialZoomY = 225
				local InitialAddY = -37.5
				
				if ThemePrefs.Get("AllowSongSearch") then
					InitialZoomY = InitialZoomY + 25
					InitialAddY = InitialAddY + 12.5
				end
				if IsServiceAllowed(SL.GrooveStats.Leaderboard) and SongIsSelected then
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
					self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y + 9)
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
		
		----- SUB SORT BOX -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 110)
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
					self:xy(SCREEN_CENTER_X + 35,SCREEN_CENTER_Y - 85)
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
					self:xy(SCREEN_CENTER_X + 115,SCREEN_CENTER_Y - 85)
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
			self:y(SCREEN_CENTER_Y - 85)
			self:zoom(1.25)
			self:settext("to")
		end,
		},
		
		----- BPM FILTER BOX 1 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X - 20,SCREEN_CENTER_Y - 60)
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
					self:xy(SCREEN_CENTER_X + 60,SCREEN_CENTER_Y - 60)
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
			self:xy(SCREEN_CENTER_X + 18,SCREEN_CENTER_Y - 60)
			self:zoom(1.25)
			self:settext("to")
		end,
		},
		
		----- Length FILTER BOX 1 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 16,SCREEN_CENTER_Y - 35)
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
					self:xy(SCREEN_CENTER_X + 115,SCREEN_CENTER_Y - 35)
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
			self:xy(SCREEN_CENTER_X + 64,SCREEN_CENTER_Y - 35)
			self:zoom(1.25)
			self:settext("to")
		end,
		},
		
		
			----- FAVORITE FILTER BOX 1 -----
		--[[Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y - 10)
					self:draworder(0)
					self:diffuse(color(NoButtonColor))
					self:zoomx(28)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(right)
			end,
			FavoriteFilterYesMessageCommand=function(self)
				self:diffuse(color(DimmedButtonColor))
			end,
			FavoriteFilterNoMessageCommand=function(self)
				self:diffuse(color(SelectedButtonColor))
			end,
		},
		
		----- FAVORITE FILTER BOX 2 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 122,SCREEN_CENTER_Y - 10)
					self:draworder(0)
					self:diffuse(color(YesButtonColor))
					self:zoomx(36)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(right)
			end,
			FavoriteFilterYesMessageCommand=function(self)
				self:diffuse(color(SelectedButtonColor))
			end,
			FavoriteFilterNoMessageCommand=function(self)
				self:diffuse(color(DimmedButtonColor))
			end,
		},
		
		----- FAVORITE FILTER NO TEXT -----
		Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			--RED
			--self:diffuse(color("#ff3729"))
			self:diffuse(color(UnselectedTextColor))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 70,SCREEN_CENTER_Y - 10)
			self:zoom(1.25)
			self:settext("NO")
		end,
		FavoriteFilterYesMessageCommand=function(self)
			self:diffuse(color(UnselectedTextColor))
		end,
		FavoriteFilterNoMessageCommand=function(self)
			self:diffuse(color(NoTextColor))
		end,
		},
		
		----- FAVORITE FILTER YES TEXT -----
		Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			-- GREEN
			---self:diffuse(color("#19e326"))
			self:diffuse(color(UnselectedTextColor))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 105,SCREEN_CENTER_Y - 10)
			self:zoom(1.25)
			self:settext("YES")
		end,
		FavoriteFilterYesMessageCommand=function(self)
			self:diffuse(color(YesTextColor))
		end,
		FavoriteFilterNoMessageCommand=function(self)
			self:diffuse(color(UnselectedTextColor))
		end,
		},--]]
		
			----- GROOVESTATS FILTER BOX 1 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y - 10)
					self:draworder(0)
					self:diffuse(color(NoButtonColor))
					self:zoomx(28)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(right)
			end,
			GroovestatsFilterYesMessageCommand=function(self)
				self:diffuse(color(DimmedButtonColor))
			end,
			GroovestatsFilterNoMessageCommand=function(self)
				self:diffuse(color(SelectedButtonColor))
			end,
		},
		
		----- GROOVESTATS FILTER BOX 2 -----
		Def.Quad{
			Name="MenuBackground",
			InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + 122,SCREEN_CENTER_Y - 10)
					self:draworder(0)
					self:diffuse(color(YesButtonColor))
					self:zoomx(36)
					self:zoomy(20)
					self:visible(true)
					self:horizalign(right)
			end,
			GroovestatsFilterYesMessageCommand=function(self)
				self:diffuse(color(SelectedButtonColor))
			end,
			GroovestatsFilterNoMessageCommand=function(self)
				self:diffuse(color(DimmedButtonColor))
			end,
		},
		
		
		----- GROOVESTATS FILTER NO TEXT -----
		Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			--RED
			--self:diffuse(color("#ff3729"))
			self:diffuse(color(UnselectedTextColor))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 70,SCREEN_CENTER_Y - 10)
			self:zoom(1.25)
			self:settext("NO")
		end,
		GroovestatsFilterYesMessageCommand=function(self)
			self:diffuse(color(UnselectedTextColor))
		end,
		GroovestatsFilterNoMessageCommand=function(self)
			self:diffuse(color(NoTextColor))
		end,
		},
		
		----- GROOVESTATS FILTER YES TEXT -----
		Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			-- GREEN
			---self:diffuse(color("#19e326"))
			self:diffuse(color(UnselectedTextColor))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 105,SCREEN_CENTER_Y - 10)
			self:zoom(1.25)
			self:settext("YES")
		end,
		GroovestatsFilterYesMessageCommand=function(self)
			self:diffuse(color(YesTextColor))
		end,
		GroovestatsFilterNoMessageCommand=function(self)
			self:diffuse(color(UnselectedTextColor))
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


SortLabel = {
	"MAIN SORT:",
	"SUB SORT:",
}

FilterLabel = {
	"FILTER DIFFICULTY:",
	"FILTER BPM:",
	"FILTER LENGTH:",
	--"FILTER FAVORITES?",
	"FILTER GROOVESTATS?",
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
			self:y(SCREEN_CENTER_Y - 110 + 25*i)
			self:zoom(1.25)
			self:settext(FilterText)
		end,
	}
end

OtherLabel = {}
if ThemePrefs.Get("AllowSongSearch") then
	OtherLabel[#OtherLabel+1] = "SONG SEARCH"
end
-- OtherLabel[#OtherLabel+1] = "MARK AS FAVORITE"
OtherLabel[#OtherLabel+1] = switchStepsTypeLabel
OtherLabel[#OtherLabel+1] = "LEADERBOARDS"
local leaderboards_label_index = #OtherLabel
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
			local is_leaderboard_enabled = curSong ~= nil and IsServiceAllowed(SL.GrooveStats.Leaderboard)
			local active_index = i

			if not is_leaderboard_enabled and i >= leaderboards_label_index then
				active_index = i - 1
			end
			self:y(SCREEN_CENTER_Y + 5 + 25*active_index)
			if i == leaderboards_label_index then
				self:visible(is_leaderboard_enabled)
			end
		end,
	}
end

return t