local numStages = SL.Global.Stages.PlayedThisGame

local page = 1
local pages = math.ceil(numStages/4)
local next_page

-- assume that the player has dedicated MenuButtons
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


local t = Def.ActorFrame{
	CodeMessageCommand=function(self, param)
		if param.Name == "Screenshot" then

			-- organize Screenshots taken using Simply Love into directories, like...
			-- ./Screenshots/Simply_Love/2015/06-June/2015-06-05_121708.png
			local prefix = "Simply_Love/" .. Year() .. "/"
			prefix = prefix .. string.format("%02d", tostring(MonthOfYear()+1)) .. "-" .. THEME:GetString("Months", "Month"..MonthOfYear()+1) .. "/"

			SaveScreenshot(param.PlayerNumber, false, true, prefix)
		end

		if pages > 1 and buttons[param.Name] ~= nil then
			next_page = page + buttons[param.Name]

			if next_page > 0 and next_page < pages+1 then
				page = next_page
				self:stoptweening():queuecommand("Hide")
			end
		end
	end,

	LoadActor( THEME:GetPathB("", "Triangles.lua") ),

	LoadFont("_wendy small")..{
		Name="PageNumber",
		Text=THEME:GetString("ScreenEvaluationSummary", "Page") .. " 1/" .. pages,
		InitCommand=cmd(diffusealpha,0; zoom, WideScale(0.5,0.6); xy, _screen.cx, 15 ),
		OnCommand=cmd(sleep, 0.1; decelerate,0.33; diffusealpha, 1),
		OffCommand=cmd(accelerate,0.33; diffusealpha,0),
		HideCommand=function(self) self:sleep(0.5):settext( THEME:GetString("ScreenEvaluationSummary", "Page").." "..page.."/"..pages ) end
	}
}

if SL.Global.GameMode ~= "StomperZ" then
	t[#t+1] = LoadActor("./LetterGrades.lua")
end

-- i will increment so that we progress down the screen from top to bottom
-- first song of the round at the top, more recently played song at the bottom
for i=1,4 do

	t[#t+1] = LoadActor("StageStats.lua", i)..{
		Name="StageStats_"..i,
		InitCommand=cmd(diffusealpha,0),
		OnCommand=function(self)
			self:xy(_screen.cx, ((_screen.h/4.75) * i))
				:queuecommand("Hide")
		end,
		ShowCommand=function(self)
			self:sleep(i*0.05):linear(0.15):diffusealpha(1)
		end,
		HideCommand=function(self)
			self:playcommand("DrawPage", {Page=page})
		end,
	}

end

return t