-- Currently the Density Graph in SSM doesn't work for Courses.
-- Disable the functionality.
if GAMESTATE:IsCourseMode() then return end

local player = ...
local pn = ToEnumShortString(player)

-- Height and width of the density graph.
local height = 64
local width = IsUsingWideScreen() and 286 or 276

-- In 2-players mode, whether the DensityGraph or PatternInfo is shown
-- Can be toggled by the code "ToggleChartInfo" in metrics.ini
local showPatternInfo = false

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:visible( GAMESTATE:IsHumanPlayer(player) )
		self:xy(_screen.cx-182, _screen.cy+23)

		if player == PLAYER_2 then
			self:addy(height+24)
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
	PlayerProfileSetMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Redraw")
		end
	end,
	CodeMessageCommand=function(self, params)
		-- Toggle between the density graph and the pattern info
		if params.Name == "TogglePatternInfo" and params.PlayerNumber == player then
			-- Only need to toggle in versus since in single player modes, both
			-- panes are already displayed.
			if GAMESTATE:GetNumSidesJoined() == 2 then
				showPatternInfo = not showPatternInfo
				self:queuecommand("TogglePatternInfo")
			end
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
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0.5)
		end
	end
}

af[#af+1] = Def.ActorFrame{
	Name="ChartParser",
	-- Hide when scrolling through the wheel. This also handles the case of
	-- going from song -> folder. It will get unhidden after a chart is parsed
	-- below.
	CurrentSongChangedMessageCommand=function(self)
		self:queuecommand("Hide")
	end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		self:queuecommand("Hide")
		self:stoptweening()
		self:sleep(0.4)
		self:queuecommand("ParseChart")
	end,
	ParseChartCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			MESSAGEMAN:Broadcast(pn.."ChartParsing")
			ParseChartInfo(steps, pn)
			self:queuecommand("Show")
		end
	end,
	ShowCommand=function(self)
		if GAMESTATE:GetCurrentSong() and
				GAMESTATE:GetCurrentSteps(player) then
			MESSAGEMAN:Broadcast(pn.."ChartParsed")
			self:queuecommand("Redraw")
		else
			self:queuecommand("Hide")
		end
	end
}

local af2 = af[#af]

-- The Density Graph itself. It already has a "RedrawCommand".
af2[#af2+1] = NPS_Histogram(player, width, height)..{
	Name="DensityGraph",
	OnCommand=function(self)
		self:addx(-width/2):addy(height/2)
	end,
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(not showPatternInfo)
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not showPatternInfo)
	end
}
-- Don't let the density graph parse the chart.
-- We do this in parent actorframe because we want to "stall" before we parse.
af2[#af2]["CurrentSteps"..pn.."ChangedMessageCommand"] = nil

-- The Peak NPS text
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="NPS",
	Text="Peak NPS: ",
	InitCommand=function(self)
		self:horizalign(left):zoom(0.8)
		if player == PLAYER_1 then
			self:addx(60):addy(-41)
		else
			self:addx(-136):addy(-41)
		end
		-- We want black text in Rainbow mode except during HolidayCheer(), white otherwise.
		self:diffuse((ThemePrefs.Get("RainbowMode") and not HolidayCheer()) and {0, 0, 0, 1} or {1, 1, 1, 1})
	end,
	HideCommand=function(self)
		self:settext("Peak NPS: ")
		self:visible(false)
	end,
	RedrawCommand=function(self)
		if SL[pn].Streams.PeakNPS ~= 0 then
			self:settext(("Peak NPS: %.1f"):format(SL[pn].Streams.PeakNPS * SL.Global.ActiveModifiers.MusicRate))
			self:visible(not showPatternInfo)
		end
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not showPatternInfo)
	end
}

-- Breakdown
af2[#af2+1] = Def.ActorFrame{
	Name="Breakdown",
	InitCommand=function(self)
		local actorHeight = 17
		self:addy(height/2 - actorHeight/2)
	end,
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(not showPatternInfo)
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not showPatternInfo)
	end,
	Def.Quad{
		InitCommand=function(self)
			local bgHeight = 17
			self:diffuse(color("#000000")):zoomto(width, bgHeight):diffusealpha(0.5)
		end
	},

	LoadFont("Common Normal")..{
		Text="",
		Name="BreakdownText",
		InitCommand=function(self)
			local textZoom = 0.8
			self:maxwidth(width/textZoom):zoom(textZoom)
		end,
		HideCommand=function(self)
			self:settext("")
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

af2[#af2+1] = Def.ActorFrame{
	Name="PatternInfo",
	InitCommand=function(self)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(0)
		else
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(0)
		else
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(0)
		else
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(showPatternInfo)
	end,
	
	-- Background for the additional chart info.
	-- Only shown in 1 Player mode
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#1e282f")):zoomto(width, height)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end,
	}
}

local af3 = af2[#af2]

local layout = {
	{"Crossovers", "Footswitches"},
	{"Sideswitches", "Jacks"},
	{"Brackets", "Total Stream"},
}

local colSpacing = 150
local rowSpacing = 20

for i, row in ipairs(layout) do
	for j, col in pairs(row) do
		af3[#af3+1] = LoadFont("Common normal")..{
			Text=col ~= "Total Stream" and "0" or "None (0.0%)",
			Name=col .. "Value",
			InitCommand=function(self)
				local textHeight = 17
				local textZoom = 0.8
				self:zoom(textZoom):horizalign(right)
				if col == "Total Stream" then
					self:maxwidth(100)
				end
				self:xy(-width/2 + 40, -height/2 + 13)
				self:addx((j-1)*colSpacing)
				self:addy((i-1)*rowSpacing)
			end,
			HideCommand=function(self)
				if col ~= "Total Stream" then
					self:settext("0")
				else
					self:settext("None (0.0%)")
				end
			end,
			RedrawCommand=function(self)
				if col ~= "Total Stream" then
					self:settext(SL[pn].Streams[col])
				else
					local streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(pn)
					local totalMeasures = streamMeasures + breakMeasures
					if streamMeasures == 0 then
						self:settext("None (0.0%)")
					else
						self:settext(string.format("%d/%d (%0.1f%%)", streamMeasures, totalMeasures, streamMeasures/totalMeasures*100))
					end
				end
			end
		}

		af3[#af3+1] = LoadFont("Common Normal")..{
			Text=col,
			Name=col,
			InitCommand=function(self)
				local textHeight = 17
				local textZoom = 0.8
				self:maxwidth(width/textZoom):zoom(textZoom):horizalign(left)
				self:xy(-width/2 + 50, -height/2 + 13)
				self:addx((j-1)*colSpacing)
				self:addy((i-1)*rowSpacing)
			end,
		}

	end
end

return af
