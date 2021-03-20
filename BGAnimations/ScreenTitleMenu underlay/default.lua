-- - - - - - - - - - - - - - - - - - - - -
-- first, reset the global SL table to default values
-- this is defined in:  ./Scripts/SL_Init.lua
InitializeSimplyLove()

-- - - - - - - - - - - - - - - - - - - - -
-- okay, now we can move on to normal actor definitions

local TextColor = (ThemePrefs.Get("RainbowMode") and (not HolidayCheer()) and Color.Black) or Color.White

-- generate a string like "7741 songs in 69 groups, 10 courses"
local SongStats = ("%i %s %i %s, %i %s"):format(
	SONGMAN:GetNumSongs(),
	THEME:GetString("ScreenTitleMenu", "songs in"),
	SONGMAN:GetNumSongGroups(),
	THEME:GetString("ScreenTitleMenu", "groups"),
	#SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses")),
	THEME:GetString("ScreenTitleMenu", "courses")
)

-- - - - - - - - - - - - - - - - - - - - -
-- People commonly have multiple copies of SL installed – sometimes different forks with unique features
-- sometimes due to concern that an update will cause them to lose data, sometimes accidentally, etc.

-- It is important to display the current theme's name to help users quickly assess what version of SL
-- they are using right now.  THEME:GetCurThemeName() provides the name of the theme folder from the
-- filesystem, so we'll show that.  It is guaranteed to be unique and users are likely to recognize it.
local sl_name = THEME:GetCurThemeName()

-- - - - - - - - - - - - - - - - - - - - -
-- ProductFamily() returns "StepMania"
-- ProductVersion() returns the (stringified) version number (like "5.0.12" or "5.1.0")
-- so, start with a string like "StepMania 5.0.12" or "StepMania 5.1.0"
local sm_version = ("%s %s"):format(ProductFamily(), ProductVersion())

-- GetThemeVersion() is defined in ./Scripts/SL-Helpers.lua and returns the SL version from ThemeInfo.ini
local sl_version = GetThemeVersion()

-- "git" appears in ProductVersion() for non-release builds of StepMania.
-- If a non-release executable is being used, append date information about when it
-- was built to potentially help non-technical cabinet owners submit bug reports.
if ProductVersion():find("git") then
	local date = VersionDate()
	local year = date:sub(1,4)
	local month = date:sub(5,6)
	if month:sub(1,1) == "0" then month = month:gsub("0", "") end
	month = THEME:GetString("Months", "Month"..month)
	local day = date:sub(7,8)

	sm_version = ("%s, Built %s %s %s"):format(sm_version, day, month, year)
end


-- -----------------------------------------------------------------------
-- preliminary Lua setup is done
-- now define actors to be passed back to the SM engine

local af = Def.ActorFrame{}
af.InitCommand=function(self) self:Center() end


if IsSpooky() then
	af[#af+1] = LoadActor("./Spooky.lua")
end

-- -----------------------------------------------------------------------
-- af2 contains things that should fade out during the OffCommand
local af2 = Def.ActorFrame{}
af2.OffCommand=function(self) self:smooth(0.65):diffusealpha(0) end
af2.Name="SLInfo"


-- the big blocky Wendy text that says SIMPLY LOVE (or SIMPLY THONK, or SIMPLY DUCKS, etc.)
-- and the arrows graphic that appears between the two words
af2[#af2+1] = LoadActor("./SimplySomething.lua")

-- SM version, SL version, song stats
af2[#af2+1] = Def.ActorFrame{
	InitCommand=function(self) self:zoom(0.8):y(-120):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.2):linear(0.4):diffusealpha(1) end,

	LoadFont("Common Normal")..{
		Text=sl_name .. (sl_version and (" v" .. sl_version) or "") .. "\n" .. sm_version,
		InitCommand=function(self) self:y(-36):diffuse(TextColor) end,
	},
	LoadFont("Common Normal")..{
		Text=SongStats,
		InitCommand=function(self) self:diffuse(TextColor) end,
	}
}

-- "The chills, I have them down my spine."
if IsSpooky() then
	af2[#af2+1] = LoadActor("./SpookyButFadeOut.lua")
end

-- the best way to spread holiday cheer is singing loud for all to hear
if HolidayCheer() then
	af2[#af2+1] = Def.Sprite{
		Texture=THEME:GetPathB("ScreenTitleMenu", "underlay/hat.png"),
		InitCommand=function(self) self:zoom(0.225):xy( 130, -self:GetHeight()/2 ):rotationz(15):queuecommand("Drop") end,
		DropCommand=function(self) self:decelerate(1.333):y(-110) end,
	}
end

-- -----------------------------------------------------------------------
-- af3 contains all of the things related to displaying the GrooveStats connection
-- Only added if we were able to successfully identify the launcher.

local NewSessionRequestProcessor = function(res, af3)
	if af3 == nil then return end
	
	local get_scores = af3:GetChild("GetScores")
	local leaderboard = af3:GetChild("Leaderboard")
	local auto_submit = af3:GetChild("AutoSubmit")

	if not res["success"] then
		get_scores:settext("Failed to Load 😞")
		leaderboard:visible(false)
		auto_submit:visible(false)

		-- These default to false, but may have changed throughout the game's lifetime.
		-- It doesn't hurt to explicitly set them to false.
		SL.GrooveStats.GetScores = false
		SL.GrooveStats.Leaderboard = false
		SL.GrooveStats.AutoSubmit = false
		return
	end

	local data = res["data"]
	if data == nil then return end

	if data["servicesAllowed"] ~= nil then
		local services = data["servicesAllowed"]

		if get_scores ~= nil and services["playerScores"] ~= nil then
			if services["playerScores"] then
				get_scores:settext("✔ Get Scores")
				SL.GrooveStats.GetScores = true
			else
				get_scores:settext("❌ Get Scores")
				SL.GrooveStats.GetScores = false
			end
		end

		if leaderboard ~= nil and services["playerLeaderboards"] ~= nil then
			if services["playerLeaderboards"] then
				leaderboard:settext("✔ Leaderboard")
				SL.GrooveStats.Leaderboard = true
			else
				leaderboard:settext("❌ Leaderboard")
				SL.GrooveStats.Leaderboard = false
			end
		end

		if auto_submit ~= nil and services["scoreSubmit"] ~= nil then
			if services["scoreSubmit"] then
				auto_submit:settext("✔ Auto-Submit")
				SL.GrooveStats.AutoSubmit = true
			else
				auto_submit:settext("❌ Auto-Submit")
				SL.GrooveStats.AutoSubmit = false
			end
		end
	end
end

if SL.GrooveStats.Launcher then
	af2[#af2+1] = Def.ActorFrame{
		Name="GrooveStatsInfo",
		InitCommand=function(self)
			self:zoom(0.8):y(-_screen.cy+15):x(_screen.cx-65):diffusealpha(0)
		end,
		OnCommand=function(self)
			self:visible(SL.GrooveStats.Launcher)
			self:sleep(0.2):linear(0.4):diffusealpha(1)
		end,

		LoadFont("Common Normal")..{
			Text="GrooveStats",
			InitCommand=function(self) self:diffuse(TextColor):horizalign(center) end,
		},
	
		LoadFont("Common Normal")..{
			Name="GetScores",
			Text=" ...   Get Scores",
			InitCommand=function(self) self:diffuse(TextColor):visible(true):addx(-40):addy(18):horizalign(left) end,
		},
	
		LoadFont("Common Normal")..{
			Name="Leaderboard",
			Text=" ...   Leaderboard",
			InitCommand=function(self) self:diffuse(TextColor):visible(true):addx(-40):addy(36):horizalign(left) end,
		},
	
		LoadFont("Common Normal")..{
			Name="AutoSubmit",
			Text=" ...   Auto-Submit",
			InitCommand=function(self) self:diffuse(TextColor):visible(true):addx(-40):addy(54):horizalign(left) end,
		},

		RequestResponseActor("NewSession", 10)..{
			OnCommand=function(self)
				MESSAGEMAN:Broadcast("NewSession", {
					data={action="groovestats/new-session", ChartHashVersion=SL.GrooveStats.ChartHashVersion},
					args=SCREENMAN:GetTopScreen():GetChild("Underlay"):GetChild("SLInfo"):GetChild("GrooveStatsInfo"),
					callback=NewSessionRequestProcessor
				})
			end
		}
	}

end

-- ensure that af2 is added as a child of af
af[#af+1] = af2

-- -----------------------------------------------------------------------

return af