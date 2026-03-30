local numStages = SL.Global.Stages.PlayedThisGame

local page = 1
local pages = math.ceil(numStages/4)
local next_page

-- start by assuming that the player has dedicated MenuButtons
local buttons = {
	-- previous page
	MenuLeft = -1,
	MenuUp = -1,
	-- next page
	MenuRight = 1,
	MenuDown = 1,
}

-- if OnlyDedicatedMenuButtons is disabled, add in support for navigating this screen with gameplay buttons
if not PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
	-- previous page
	buttons.Left=-1
	buttons.Up=-1
	buttons.DownLeft=-1
	-- next page
	buttons.Right=1
	buttons.Down=1
	buttons.DownRight=1
end

local page_text = THEME:GetString("ScreenEvaluationSummary", "Page")

-- -----------------------------------------------------------------------


-- Utility function to collect the names of all unique profiles that played at least one song
-- as player pn this session.
uniqueProfilesUsedForPlayer = function(pn)
	local extractProfile = function(stats)
		return stats.profile
	end
	local profilesUsed = map(extractProfile, SL[pn].Stages.Stats)
	return deduplicate(profilesUsed)
end


-- -----------------------------------------------------------------------

local t = Def.ActorFrame{
	-- this CodeMessage is defined in metrics.ini under [ScreenEvaluationSummary]
	-- it handles both page navigation and screenshot requests
	CodeMessageCommand=function(self, param)

		-- player wants to save a screenshot
		if param.Name == "Screenshot" then
			-- format a localized month string like "06-June" or "12-Diciembre"
			local month = ("%02d-%s"):format(MonthOfYear()+1, THEME:GetString("Months", "Month"..MonthOfYear()+1))

			-- organize screenshots Love into directories, like...
			--      ./Screenshots/Simply_Love/2020/04-April/2020-04-22_175951.png
			-- note that the engine's SaveScreenshot() function will convert whitespace
			-- characters to underscores, so we might as well just use underscores here
			local prefix = "Simply_Love/" .. Year() .. "/" .. month .. "/"

			-- for more info on SaveScreenshot(), see ./BGA/ScreenEvaluation common/ScreenshotHandler.lua
			SaveScreenshot(param.PlayerNumber, false, false, prefix)
		end

		if pages > 1 and buttons[param.Name] ~= nil then
			next_page = page + buttons[param.Name]

			if next_page > 0 and next_page < pages+1 then
				page = next_page
				self:finishtweening():queuecommand("Hide")
			end
		end
	end
}

-- centered text like "Page 2/5" where
-- 2 is the current page the player is viewing, and
-- 5 is the total number of pages
t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Name="PageNumber",
	Text=("%s %i/%i"):format(page_text, page, pages),
	InitCommand=function(self) self:diffusealpha(0):zoom(WideScale(0.5,0.6)):xy(_screen.cx, 15) end,
	OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1) end,
	OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
	HideCommand=function(self) self:sleep(0.5):settext( ("%s %i/%i"):format(page_text, page, pages) ) end
}


t[#t+1] = LoadActor("./LetterGrades.lua")

-- -----------------------------------------------------------------------
-- 4 rows
-- i will increment so that we progress down the screen from top to bottom
-- first song of the round at the top, more recently played song at the bottom

for i=1,4 do

	t[#t+1] = LoadActor("Row.lua", i)..{
		Name="StageStats_"..i,
		InitCommand=function(self) self:diffusealpha(0) end,
		OnCommand=function(self)
			self:xy(_screen.cx, ((_screen.h/4.75) * i))
				:queuecommand("Hide")
		end,
		ShowCommand=function(self)
			self:finishtweening():sleep(i*0.05):linear(0.15):diffusealpha(1)
		end,
		HideCommand=function(self)
			self:playcommand("DrawPage", {Page=page})
		end,
	}

end

-- -----------------------------------------------------------------------

return t