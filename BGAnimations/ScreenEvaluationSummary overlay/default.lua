local numStages = SL.Global.Stages.PlayedThisGame

local page = 1
local pages = math.ceil(numStages/4)
local GCM = GAMESTATE:GetCoinMode()

local MovePageOn = {
	['Global'] = {
		['MenuLeft'] = 1,
		['MenuUp'] = 1,
		['MenuRight'] = -1,
		['MenuDown'] = -1, 
	},
	['CoinMode_Home'] = {
		['Left'] = 1,
		['Up'] = 1,
		['Right'] = -1,
		['Down'] = -1, 
	},
}

local function MovePage(Inp,Pinp)
	for k,v in pairs(Pinp) do
		if k == 'Global' or k == GCM then
			if v[Inp] then
				return v[Inp]
			end
		end	
	end
	return 0
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

		if pages > 1 then
			Reload = true
			nextpage = MovePage(param.Name,MovePageOn)
			page = page + nextpage
			if page > pages then page = pages Reload = false end
			if page < 1 then page = 1 Reload = false end			
			if nextpage ~= 0 and Reload then self:stoptweening():queuecommand("Hide") end
		end
	end,

	LoadActor( THEME:GetPathB("", "Triangles.lua") ),

	Def.BitmapText{
		Name="PageNumber",
		Font="_wendy small",
		Text="Page 1/" .. pages,
		InitCommand=cmd(diffusealpha,0; zoom,0.6; xy, _screen.cx, 14 ),
		OnCommand=cmd(sleep, 0.1; decelerate,0.33; diffusealpha, 1),
		OffCommand=cmd(accelerate,0.33; diffusealpha,0),
		HideCommand=function(self) self:sleep(0.5):settext( "Page "..page.."/"..pages ) end
	}
}

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