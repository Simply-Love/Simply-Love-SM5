local TextColor = ThemePrefs.Get("RainbowMode") and Color.Black or Color.White

local SongStats = SONGMAN:GetNumSongs() .. " songs in "
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, "
SongStats = SongStats .. SONGMAN:GetNumCourses() .. " courses"

-- - - - - - - - - - - - - - - - - - - - -

local game = GAMESTATE:GetCurrentGame():GetName();
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

-- - - - - - - - - - - - - - - - - - - - -
local sm_version = ""

if ProductVersion():find("git") then
	local date = VersionDate()
	local year = date:sub(1,4)
	local month = date:sub(5,6)
	if month:sub(1,1) == "0" then month = month:gsub("0", "") end 
	month = THEME:GetString("Months", "Month"..month)
	local day = date:sub(7,8)
	
	sm_version = ProductID() .. ", Built " .. month .. " " .. day .. ", " .. year
else
	sm_version = ProductID() .. sm_version
end
-- - - - - - - - - - - - - - - - - - - - -

local image = ThemePrefs.Get("VisualTheme")

local af = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Initialize.lua
		InitializeSimplyLove()
	end,
	OnCommand=function(self)
		self:Center()
		
		if image == "Arrows" then
			self:y(_screen.cy + 10)
		end
	end,
	OffCommand=cmd(linear,0.5; diffusealpha, 0),

	Def.ActorFrame{
		InitCommand=function(self)
			self:zoom(0.8):y(-120):diffusealpha(0)
		end,
		OnCommand=function(self)
			self:sleep(0.2):linear(0.4):diffusealpha(1)
		end,
		
		Def.BitmapText{
			Font="_miso",
			Text=sm_version,
			InitCommand=function(self) self:y(-20):diffuse(TextColor) end,
		},
		Def.BitmapText{
			Font="_miso",
			Text=SongStats,
			InitCommand=function(self) self:diffuse(TextColor) end,
		}
	},

	LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
		InitCommand=function(self)
			self:y(-16):zoom( game=="pump" and 0.2 or 0.205 )
		end
	},

	LoadActor("Simply".. image .." (doubleres).png") .. {
		InitCommand=function(self) self:x(2):zoom(0.7):shadowlength(1) end,
		OffCommand=function(self) self:linear(0.5):shadowlength(0) end
	}
}

-- the best way to spread holiday cheer is singing loud for all to hear
if PREFSMAN:GetPreference("EasterEggs") and MonthOfYear()==11 then
	af[#af+1] = Def.Sprite{
		Texture=THEME:GetPathB("ScreenTitleMenu", "underlay/hat.png"),
		InitCommand=function(self) self:zoom(0.225):xy( 130, -self:GetHeight()/2 ):rotationz(15) end,
		OnCommand=function(self) self:decelerate(1.333):y(-110) end
	}
end

return af