-- Currently the Density Graph in SSM doesn't work for Courses.
-- Disable the functionality.
if GAMESTATE:IsCourseMode() then return end

local player = ...
local pn = ToEnumShortString(player)

-- Height and width of the density graph.
local height = 64
local width = IsUsingWideScreen() and 267 or 276

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:visible( GAMESTATE:IsHumanPlayer(player) )
		self:xy(_screen.cx-288.5, _screen.cy+1)

		if player == PLAYER_2 then
			self:addx(587)
		end

		if IsUsingWideScreen() then
			self:addx(-5)
		end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(true)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(false)
		end
	end,
}

-- Background quad for the density graph
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:diffuse(color("#1e282f")):zoomto(width, height)
		if ThemePrefs.Get("RainbowMode") then
			self:diffusealpha(0.9)
		end
	end
}

af[#af+1] = Def.ActorFrame{
	Name="ChartParser",
	OnCommand=function(self)
		self:queuecommand('ShowDensityGraph')
	end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		self:queuecommand('ShowDensityGraph')
	end,
	CloseThisFolderHasFocusMessageCommand=function(self)
		self:queuecommand('Hide')
	end,
	ShowDensityGraphCommand=function(self)
		self:GetChild("DensityGraph"):visible(false)
		self:GetChild("NPS"):settext("Peak NPS: ")
		self:GetChild("NPS"):visible(false)
		self:GetChild("Breakdown"):GetChild("BreakdownText"):settext("")
		self:GetChild("Breakdown"):visible(false)
		self:stoptweening()
		self:sleep(0.4)
		self:queuecommand("ParseChart")
	end,
	ParseChartCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			MESSAGEMAN:Broadcast(pn.."ChartParsing")
			ParseChartInfo(steps, pn)
			self:queuecommand("Unhide")
		end
	end,
	UnhideCommand=function(self)
		if GAMESTATE:GetCurrentSteps(player) then
			MESSAGEMAN:Broadcast(pn.."ChartParsed")
			self:GetChild("DensityGraph"):visible(true)
			self:GetChild("NPS"):visible(true)
			self:GetChild("Breakdown"):visible(true)
			self:queuecommand("Redraw")
		end
	end,
	HideCommand=function(self)
		self:stoptweening()
		self:GetChild("DensityGraph"):visible(false)
		self:GetChild("NPS"):visible(false)
		self:GetChild("Breakdown"):visible(false)
	end,
}

local af2 = af[#af]

-- The Density Graph itself. It already has a "RedrawCommand".
af2[#af2+1] = NPS_Histogram(player, width, height)..{
	Name="DensityGraph",
	OnCommand=function(self)
		self:addx(-width/2):addy(height/2)
	end,
}
-- Don't let the density graph parse the chart.
-- We do this in parent actorframe because we want to "stall" before we parse.
af2[#af2]["CurrentSteps"..pn.."ChangedMessageCommand"] = nil

-- The Peak NPS text
af2[#af2+1] = LoadFont("Miso/_miso")..{
	Name="NPS",
	Text="Peak NPS: ",
	InitCommand=function(self)
		self:horizalign(left):zoom(0.8)
		if player == PLAYER_1 then
			self:addx(54):addy(-41)
		else
			self:addx(-131):addy(-41)
		end
		-- We want black text in Rainbow mode, white otherwise.
		self:diffuse({1, 1, 1, 1})
	end,
	RedrawCommand=function(self)
		if SL[pn].Streams.PeakNPS ~= 0 then
			self:settext(("Peak NPS: %.1f"):format(SL[pn].Streams.PeakNPS))
		end
	end
}

-- Breakdown
af2[#af2+1] = Def.ActorFrame{
	Name="Breakdown",
	InitCommand=function(self)
		local actorHeight = 17
		self:addy(height/2 - actorHeight/2)
	end,

	Def.Quad{
		InitCommand=function(self)
			local bgHeight = 17
			self:diffuse(color("#000000")):zoomto(width, bgHeight):diffusealpha(0.5)
		end
	},
	
	LoadFont("Miso/_miso")..{
		Text="",
		Name="BreakdownText",
		InitCommand=function(self)
			local textHeight = 17
			local textZoom = 0.8
			self:maxwidth(width/textZoom):zoom(textZoom)
		end,
		RedrawCommand=function(self)
			local textZoom = 0.8
			self:settext(GenerateBreakdownText(pn, 0))
			local minimization_level = 1
			while self:GetWidth() > (width/textZoom) and minimization_level < 4 do
				self:settext(GenerateBreakdownText(pn, minimization_level))
				minimization_level = minimization_level + 1
			end
		end,
	}
}

return af